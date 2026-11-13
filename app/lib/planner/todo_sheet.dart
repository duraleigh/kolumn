import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import '../data/database.dart';
import '../data/repository.dart';
import '../state/providers.dart';
import '../theme/tokens.dart';
import '../data/due.dart';
import '../ui/bits.dart';
import '../ui/item_sheet.dart';
import '../ui/sheets.dart';
import 'days.dart';
import 'planner_model.dart';
import 'repeat.dart';

/// Opens a to-do: a sheet from the bottom on a phone, a panel in the middle
/// on a computer. [day] is the day it was opened from (which day of a
/// repeating to-do). Built from the shared pieces in item_sheet.dart: this is
/// the template a Kolumn card follows.
Future<void> showTodoSheet(BuildContext context, WidgetRef ref, {required String todoId, String? day}) =>
    showItemSheet(context, (wide) => _TodoSheet(todoId: todoId, day: day, wide: wide));

class _TodoSheet extends ConsumerStatefulWidget {
  const _TodoSheet({required this.todoId, this.day, required this.wide});
  final String todoId;
  final String? day;
  final bool wide;

  @override
  ConsumerState<_TodoSheet> createState() => _TodoSheetState();
}

class _TodoSheetState extends ConsumerState<_TodoSheet> {
  final _title = TextEditingController();
  final _note = TextEditingController();
  final _step = TextEditingController();
  bool _loaded = false;
  Timer? _save;
  late final KolumnRepository _repo = ref.read(repositoryProvider);

  @override
  void dispose() {
    _flush();
    _title.dispose();
    _note.dispose();
    _step.dispose();
    super.dispose();
  }

  void _changed() {
    _save?.cancel();
    _save = Timer(const Duration(milliseconds: 700), _flush);
  }

  void _flush() {
    _save?.cancel();
    final t = _current;
    if (t == null) return;
    final title = _title.text.trim();
    final note = _note.text;
    if ((title.isNotEmpty && title != t.title) || note != t.note) {
      _repo.updateTodo(t.id, title: title.isNotEmpty && title != t.title ? title : null, note: note != t.note ? note : null);
      _current = t.copyWith(title: title.isEmpty ? t.title : title, note: note);
    }
  }

  KTodo? _current;

  Future<void> _attach({required bool photo, ImageSource source = ImageSource.gallery}) async {
    String path;
    String name;
    if (photo) {
      final x = await ImagePicker().pickImage(source: source, maxWidth: 2400, maxHeight: 2400, imageQuality: 85);
      if (x == null) return;
      path = x.path;
      name = x.name;
    } else {
      final r = await FilePicker.pickFiles();
      if (r.isEmpty || r.first.path == null) return;
      path = r.first.path!;
      name = r.first.name;
    }
    final src = File(path);
    final size = await src.length();
    if (size > 25 * 1024 * 1024) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Files can be up to 25 MB.')));
      return;
    }
    final dir = Directory('${(await getApplicationDocumentsDirectory()).path}/kolumn-uploads');
    if (!dir.existsSync()) dir.createSync(recursive: true);
    final keep = await src.copy('${dir.path}/${DateTime.now().microsecondsSinceEpoch}-$name');
    await _repo.addTodoFile(widget.todoId, localPath: keep.path, filename: name, mime: mimeFor(name), size: size);
  }

  Future<void> _openFile(FileTileData f) async {
    final bytes = await ref.read(fileBytesProvider((f.id, false)).future);
    if (bytes == null) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('That file can\'t be opened right now. Check your connection.')));
      return;
    }
    final dir = Directory('${(await getApplicationCacheDirectory()).path}/kolumn-open/${f.id}');
    if (!dir.existsSync()) dir.createSync(recursive: true);
    final out = File('${dir.path}/${f.filename}');
    if (!out.existsSync()) await out.writeAsBytes(bytes, flush: true);
    await OpenFilex.open(out.path, type: f.mime);
  }

  /// The due pill: straight to the calendar, with the time wheel under it at 11:59 PM.
  Future<void> _pickDue(KTodo t, DueState state) async {
    final today = ref.read(plannerTodayProvider);
    // Never earlier than the day it sits on (a late one: than today).
    final first = state == DueState.late || t.day == null || t.day!.compareTo(today) < 0 && t.doneAt == null ? today : t.day!;
    final r = await pickDueMoment(
      context,
      title: 'Due date',
      current: t.dueAt,
      currentHasTime: t.dueHasTime,
      startDay: first,
      firstDay: first,
      removeLabel: t.dueAt == null ? null : 'Remove the due date',
    );
    if (r == null) return;
    await _repo.setTodoDue(t, r.at, hasTime: r.hasTime);
  }

  Future<void> _repeat(KTodo t) async {
    final String today = ref.read(plannerTodayProvider);
    final start = t.day ?? today;
    final result = await pickRepeat(context, start: start, current: RepeatRule.fromJson(t.repeat));
    if (result == null) return;
    if (result.rule == null) {
      await _repo.updateTodo(t.id, clearRepeat: true);
    } else {
      // A Someday to-do that starts repeating lands on today.
      await _repo.updateTodo(t.id, repeat: result.rule, slot: t.day == null ? TodoSlot.day(start) : null);
    }
  }

  Future<void> _remind(KTodo t) async {
    final current = ref.read(reminderMapProvider)[t.id];
    final String today = ref.read(plannerTodayProvider);
    final day = widget.day ?? t.day ?? today;
    final r = await pickReminder(context, current: current, day: day);
    if (r == null) return;
    await _repo.setReminder(t.id, 'todo', r.at);
  }

  Future<void> _assign(KTodo t, KPlanner? planner) async {
    if (planner == null) return;
    final people = ref.read(plannerPeopleProvider(planner.id)).value ?? const <KPlannerPerson>[];
    final names = ref.read(peopleNamesProvider);
    final ids = <int>{if (planner.creatorId != null) planner.creatorId!, for (final p in people) p.userId}.toList();
    if (ids.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Share this planner with someone first, then you can give them a to-do.')));
      return;
    }
    final picked = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text('Who is it for?', style: Theme.of(context).textTheme.titleLarge),
            ),
            for (final id in ids)
              ListTile(
                leading: PersonAvatar(id: id, name: names[id] ?? '?', size: 32),
                title: Text(names[id] ?? 'Someone'),
                trailing: t.assigneeId == id ? const Icon(Icons.check_rounded) : null,
                onTap: () => Navigator.pop(context, id),
              ),
            if (t.assigneeId != null)
              ListTile(leading: const Icon(Icons.person_off_outlined), title: const Text('Nobody in particular'), onTap: () => Navigator.pop(context, -1)),
          ],
        ),
      ),
    );
    if (picked == null) return;
    await _repo.updateTodo(t.id, assigneeId: picked == -1 ? null : picked, clearAssignee: picked == -1);
  }

  /// ⋮: Follow · Move to a different date · Move to another planner · Delete.
  Future<void> _more(KTodo t, bool following) async {
    final rule = RepeatRule.fromJson(t.repeat);
    final planners = ref.read(plannersProvider).value ?? const <KPlanner>[];
    final choice = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(following ? Icons.notifications_off_outlined : Icons.notifications_active_outlined),
              title: Text(following ? 'Stop following' : 'Follow'),
              subtitle: Text(following ? 'You hear when it\'s finished, its due date changes, or it goes late' : 'Hear when it\'s finished, its due date changes, or it goes late'),
              onTap: () => Navigator.pop(context, 'follow'),
            ),
            if (rule == null)
              ListTile(leading: const Icon(Icons.event_repeat_outlined), title: const Text('Move to a different date'), onTap: () => Navigator.pop(context, 'date')),
            if (planners.length > 1)
              ListTile(
                leading: const Icon(Icons.drive_file_move_outline),
                title: const Text('Move to another planner'),
                onTap: () => Navigator.pop(context, 'move'),
              ),
            if (rule != null && widget.day != null)
              ListTile(leading: const Icon(Icons.event_busy_outlined), title: const Text('Delete this day only'), onTap: () => Navigator.pop(context, 'skip')),
            ListTile(
              leading: Icon(Icons.delete_outline_rounded, color: context.colors.error),
              title: Text(rule != null ? 'Delete every day' : 'Delete to-do', style: TextStyle(color: context.colors.error)),
              onTap: () => Navigator.pop(context, 'delete'),
            ),
          ],
        ),
      ),
    );
    if (!mounted || choice == null) return;
    switch (choice) {
      case 'follow':
        await _repo.setTodoWatch(t.id, !following);
      case 'date':
        final today = ref.read(plannerTodayProvider);
        final finished = t.doneAt != null;
        final due = t.dueAt == null ? null : dueDay(t.dueAt!, hasTime: t.dueHasTime);
        final to = await pickDayWheel(
          context,
          title: 'Move to a different date',
          initial: t.day ?? today,
          min: finished ? null : today,
          max: finished ? today : due,
          note: finished
              ? 'A finished to-do can\'t move to a day that hasn\'t happened yet.'
              : (due == null ? 'An unfinished to-do can\'t move to a day that has passed.' : 'Not before today, and not after its due date.'),
        );
        if (to == null || !canMoveTodo(t, TodoSlot.day(to), today: today)) return;
        await _repo.updateTodo(t.id, slot: TodoSlot.day(to));
      case 'skip':
        await _repo.skipTodoDay(t, widget.day!);
        if (mounted) Navigator.pop(context);
      case 'delete':
        final ok = await confirm(
          context,
          title: rule != null ? 'Delete every day?' : 'Delete this to-do?',
          body: rule != null ? 'This repeating to-do goes from every day it comes up on, for everyone in the planner.' : 'It goes for everyone in the planner.',
          action: 'Delete',
        );
        if (!ok) return;
        await _repo.deleteTodo(t.id);
        if (mounted) Navigator.pop(context);
      case 'move':
        final to = await showModalBottomSheet<String>(
          context: context,
          showDragHandle: true,
          builder: (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final p in planners.where((p) => p.id != t.plannerId))
                  ListTile(leading: const Icon(Icons.calendar_today_outlined), title: Text(p.name), onTap: () => Navigator.pop(context, p.id)),
              ],
            ),
          ),
        );
        if (to == null) return;
        await _repo.updateTodo(t.id, plannerId: to);
        if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _stepMenu(KTodoStep s) async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(leading: const Icon(Icons.edit_outlined), title: const Text('Edit'), onTap: () => Navigator.pop(context, 'edit')),
            if (!s.heading)
              ListTile(
                leading: Icon(s.star ? Icons.star_rounded : Icons.star_outline_rounded),
                title: Text(s.star ? 'Remove the star' : 'Star it'),
                onTap: () => Navigator.pop(context, 'star'),
              ),
            if (!s.heading && s.indent < 3)
              ListTile(leading: const Icon(Icons.format_indent_increase_rounded), title: const Text('Indent'), onTap: () => Navigator.pop(context, 'in')),
            if (!s.heading && s.indent > 0)
              ListTile(leading: const Icon(Icons.format_indent_decrease_rounded), title: const Text('Indent less'), onTap: () => Navigator.pop(context, 'out')),
            ListTile(
              leading: const Icon(Icons.title_rounded),
              title: Text(s.heading ? 'Make it a step' : 'Make it a heading'),
              onTap: () => Navigator.pop(context, 'head'),
            ),
            ListTile(
              leading: Icon(Icons.delete_outline_rounded, color: context.colors.error),
              title: Text('Delete', style: TextStyle(color: context.colors.error)),
              onTap: () => Navigator.pop(context, 'delete'),
            ),
          ],
        ),
      ),
    );
    if (!mounted || choice == null) return;
    switch (choice) {
      case 'edit':
        final n = await askText(context, title: s.heading ? 'Edit heading' : 'Edit step', initial: s.content, action: 'Save');
        if (n != null && n.trim().isNotEmpty) await _repo.updateTodoStep(s, content: n);
      case 'star':
        await _repo.updateTodoStep(s, star: !s.star);
      case 'in':
        await _repo.updateTodoStep(s, indent: s.indent + 1);
      case 'out':
        await _repo.updateTodoStep(s, indent: s.indent - 1);
      case 'head':
        await _repo.updateTodoStep(s, heading: !s.heading, indent: 0);
      case 'delete':
        await _repo.deleteTodoStep(s);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(todoProvider(widget.todoId)).value;
    if (t == null || t.deletedAt != null) {
      return const SizedBox(height: 200, child: Center(child: Text('This to-do is gone.')));
    }
    if (!_loaded) {
      _loaded = true;
      _title.text = t.title;
      _note.text = t.note;
    }
    _current = t;
    final readOnly = ref.watch(readOnlyProvider).value ?? false;
    final today = ref.watch(plannerTodayProvider);
    final now = ref.watch(plannerNowProvider)();
    final rule = RepeatRule.fromJson(t.repeat);
    final steps = ref.watch(todoStepsProvider(t.id)).value ?? const <KTodoStep>[];
    final files = ref.watch(todoFilesProvider(t.id)).value ?? const <KTodoFile>[];
    final reminder = ref.watch(reminderMapProvider)[t.id];
    final names = ref.watch(peopleNamesProvider);
    final me = ref.watch(meIdProvider).value;
    final watch = ref.watch(todoWatchProvider(t.id)).value;
    final following = watch?.watching ?? (t.creatorId == me || t.assigneeId == me);
    KPlanner? planner;
    for (final x in ref.watch(plannersProvider).value ?? const <KPlanner>[]) {
      if (x.id == t.plannerId) planner = x;
    }
    if (planner != null) ref.watch(plannerPeopleProvider(planner.id));
    final marks = ref.watch(todoMarksProvider).value ?? const <KTodoMark>[];
    final done = rule == null
        ? t.doneAt != null
        : widget.day != null && marks.any((m) => m.todoId == t.id && m.day == widget.day && m.mark == 'done' && m.deletedAt == null);
    final state = rule != null ? DueState.none : dueState(dueAt: t.dueAt, hasTime: t.dueHasTime, doneAt: t.doneAt, now: now);

    void toggle() {
      if (rule != null && widget.day == null) return;
      _repo.setTodoDone(t, !done, day: widget.day);
    }

    final caption = <String>[
      planner?.name ?? '',
      t.day == null ? 'Someday' : (rule != null && widget.day != null ? friendlyDay(widget.day!, today: today) : friendlyDay(t.day!, today: today)),
      if (rule != null) rule.describe(t.day!),
      if (reminder != null) 'reminder ${_reminderText(reminder, today)}',
    ];

    return ItemSheetFrame(
      wide: widget.wide,
      main: [
        CaptionLine(parts: caption),
        if (rule == null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: DuePill(
                dueAt: t.dueAt,
                hasTime: t.dueHasTime,
                state: state,
                readOnly: readOnly,
                today: today,
                onPick: () => _pickDue(t, state),
                onClear: () => _repo.setTodoDue(t, null),
              ),
            ),
          ),
        TitleField(controller: _title, readOnly: readOnly, onChanged: _changed, done: done, hint: 'To-do'),
        if (t.assigneeId != null) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              PersonAvatar(id: t.assigneeId!, name: names[t.assigneeId!] ?? '?', size: 24),
              const SizedBox(width: 8),
              Text('For ${names[t.assigneeId!] ?? 'someone'}', style: TextStyle(fontSize: 14, color: context.colors.onSurfaceVariant)),
            ],
          ),
        ],
        const SizedBox(height: 10),
        NoteField(controller: _note, readOnly: readOnly, onChanged: _changed),
        const SizedBox(height: 10),
        for (final s in steps)
          ChecklistRow(
            content: s.content,
            done: s.done,
            heading: s.heading,
            star: s.star,
            indent: s.indent,
            readOnly: readOnly,
            onToggle: () => _repo.updateTodoStep(s, done: !s.done),
            onMenu: () => _stepMenu(s),
          ),
        if (!readOnly) AddStepField(controller: _step, onAdd: (v) => _repo.addTodoStep(t.id, v)),
        if (!readOnly)
          AttachChips(
            onPhoto: () => _attach(photo: true),
            onCamera: () => _attach(photo: true, source: ImageSource.camera),
            onFile: () => _attach(photo: false),
          ),
        FileTiles(
          files: [for (final f in files) FileTileData(id: f.id, filename: f.filename, mime: f.mime, size: f.size, uploaded: f.uploaded)],
          onOpen: _openFile,
          onHold: readOnly
              ? null
              : (f) async {
                  final ok = await confirm(context, title: 'Remove this file?', body: f.filename, action: 'Remove');
                  if (!ok) return;
                  final row = files.where((x) => x.id == f.id).firstOrNull;
                  if (row != null) await _repo.deleteTodoFile(row);
                },
        ),
      ],
      bar: ItemBar(
        children: [
          BarIcon(icon: Icons.person_outline_rounded, label: 'Who it\'s for', onTap: readOnly ? null : () => _assign(t, planner), on: t.assigneeId != null),
          BarIcon(icon: Icons.repeat_rounded, label: 'Repeat', onTap: readOnly ? null : () => _repeat(t), on: rule != null),
          BarCenter(
            icon: done ? Icons.undo_rounded : Icons.check_rounded,
            label: done ? 'Mark not done' : 'Done',
            onTap: readOnly
                ? null
                : () {
                    toggle();
                    if (!done) Navigator.pop(context);
                  },
          ),
          BarIcon(icon: Icons.notifications_none_rounded, label: 'Reminder', onTap: readOnly ? null : () => _remind(t), on: reminder != null),
          BarIcon(icon: Icons.more_horiz_rounded, label: 'More', onTap: readOnly ? null : () => _more(t, following)),
        ],
      ),
    );
  }
}

String _reminderText(int at, String today) {
  final d = DateTime.fromMillisecondsSinceEpoch(at);
  final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final m = d.minute.toString().padLeft(2, '0');
  return '${friendlyDay(dayKey(d), today: today)} at $h:$m ${d.hour < 12 ? 'am' : 'pm'}';
}

String reminderLabel(int at, {String? today}) => _reminderText(at, today ?? todayKey());

// ------------------------------------------------------------------ choosing a day

/// Today, tomorrow, next Monday, a day from the calendar, or Someday.
Future<TodoSlot?> pickTodoDay(BuildContext context, {required TodoSlot current, bool allowSomeday = true, required String today}) async {
  final nextMonday = addDays(mondayOf(today), 7);
  final choice = await showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.today_outlined),
            title: const Text('Today'),
            subtitle: Text(dayLabel(today)),
            onTap: () => Navigator.pop(context, today),
          ),
          ListTile(
            leading: const Icon(Icons.wb_sunny_outlined),
            title: const Text('Tomorrow'),
            subtitle: Text(dayLabel(addDays(today, 1))),
            onTap: () => Navigator.pop(context, addDays(today, 1)),
          ),
          ListTile(
            leading: const Icon(Icons.next_week_outlined),
            title: const Text('Next week'),
            subtitle: Text(dayLabel(nextMonday)),
            onTap: () => Navigator.pop(context, nextMonday),
          ),
          ListTile(leading: const Icon(Icons.calendar_month_outlined), title: const Text('Pick a day'), onTap: () => Navigator.pop(context, 'pick')),
          if (allowSomeday)
            ListTile(
              leading: const Icon(Icons.inbox_outlined),
              title: const Text('Someday'),
              subtitle: const Text('No day; it waits in your Someday list'),
              onTap: () => Navigator.pop(context, 'someday'),
            ),
        ],
      ),
    ),
  );
  if (choice == null || !context.mounted) return null;
  if (choice == 'someday') return current.list != null ? current : const TodoSlot.someday(1);
  if (choice == 'pick') {
    final start = parseDay(current.day ?? today);
    final d = await showDatePicker(context: context, initialDate: start, firstDate: DateTime(2000), lastDate: DateTime(2099, 12, 31));
    return d == null ? null : TodoSlot.day(dayKey(d));
  }
  return TodoSlot.day(choice);
}

// ------------------------------------------------------------------ repeat

class RepeatChoice {
  const RepeatChoice(this.rule);
  final RepeatRule? rule;
}

/// Tweek's repeat wheel: every N days, weeks, months or years; weekdays;
/// monthly on the date or the weekday; an end day. Null when cancelled.
Future<RepeatChoice?> pickRepeat(BuildContext context, {required String start, RepeatRule? current}) {
  var rule = current ?? const RepeatRule();
  return showModalBottomSheet<RepeatChoice>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => StatefulBuilder(
      builder: (context, set) {
        final c = context.colors;
        final p = context.palette;
        Widget seg<T>(T value, T group, String label, ValueChanged<T> onPick) {
          final on = value == group;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: Material(
                color: on ? p.card : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                elevation: on ? 1 : 0,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => set(() => onPick(value)),
                  child: SizedBox(
                    height: 42,
                    child: Center(
                      child: Text(
                        label,
                        style: TextStyle(fontSize: 15, fontWeight: on ? FontWeight.w700 : FontWeight.w400, color: on ? c.onSurface : c.onSurfaceVariant),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        final s = parseDay(start);
        final unitNames = {RepeatUnit.day: 'day', RepeatUnit.week: 'week', RepeatUnit.month: 'month', RepeatUnit.year: 'year'};
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Repeat', textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: p.chip, borderRadius: BorderRadius.circular(18)),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Every', style: TextStyle(fontSize: 15, color: c.onSurfaceVariant)),
                          const SizedBox(width: 8),
                          IconButton(
                            tooltip: 'Fewer',
                            onPressed: rule.every > 1 ? () => set(() => rule = rule.copyWith(every: rule.every - 1)) : null,
                            icon: const Icon(Icons.remove_rounded),
                          ),
                          SizedBox(
                            width: 36,
                            child: Text(
                              '${rule.every}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                            ),
                          ),
                          IconButton(
                            tooltip: 'More',
                            onPressed: rule.every < 99 ? () => set(() => rule = rule.copyWith(every: rule.every + 1)) : null,
                            icon: const Icon(Icons.add_rounded),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          for (final u in RepeatUnit.values)
                            seg<RepeatUnit>(u, rule.unit, rule.every > 1 ? '${unitNames[u]}s' : unitNames[u]!, (v) => rule = rule.copyWith(unit: v)),
                        ],
                      ),
                      if (rule.unit == RepeatUnit.week) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            for (var d = 1; d <= 7; d++)
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(2),
                                  child: FilterChip(
                                    showCheckmark: false,
                                    padding: EdgeInsets.zero,
                                    labelPadding: EdgeInsets.zero,
                                    label: SizedBox(
                                      width: double.infinity,
                                      child: Text(weekdayShort[d - 1].substring(0, 2), textAlign: TextAlign.center),
                                    ),
                                    selected: (rule.weekdays.isEmpty ? [s.weekday] : rule.weekdays).contains(d),
                                    onSelected: (on) => set(() {
                                      final now = {
                                        ...(rule.weekdays.isEmpty ? [s.weekday] : rule.weekdays),
                                      };
                                      on ? now.add(d) : now.remove(d);
                                      if (now.isNotEmpty) rule = rule.copyWith(weekdays: now.toList()..sort());
                                    }),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                      if (rule.unit == RepeatUnit.month) ...[
                        const SizedBox(height: 6),
                        RadioGroup<bool>(
                          groupValue: rule.monthlyByWeekday,
                          onChanged: (v) => set(() => rule = rule.copyWith(monthlyByWeekday: v ?? false)),
                          child: Column(
                            children: [
                              RadioListTile<bool>(value: false, title: Text('On the ${ordinal(s.day)}')),
                              RadioListTile<bool>(
                                value: true,
                                title: Text(
                                  const RepeatRule(
                                    unit: RepeatUnit.month,
                                    monthlyByWeekday: true,
                                  ).describe(start).replaceFirst('Every month on the ', 'On the '),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 6),
                  title: const Text('Ending'),
                  trailing: Text(rule.until == null ? 'Never' : dayLabel(rule.until!), style: TextStyle(color: c.onSurfaceVariant)),
                  onTap: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: rule.until == null ? DateTime(s.year, s.month + 3, s.day) : parseDay(rule.until!),
                      firstDate: s,
                      lastDate: DateTime(2099, 12, 31),
                    );
                    set(() => rule = d == null ? rule.copyWith(clearUntil: true) : rule.copyWith(until: dayKey(d)));
                  },
                ),
                Text(
                  rule.describe(start),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: c.onSurfaceVariant),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50), backgroundColor: c.onSurface, foregroundColor: c.surface),
                  onPressed: () => Navigator.pop(context, RepeatChoice(rule)),
                  child: const Text('Apply'),
                ),
                if (current != null) TextButton(onPressed: () => Navigator.pop(context, const RepeatChoice(null)), child: const Text('Don\'t repeat')),
              ],
            ),
          ),
        );
      },
    ),
  );
}

// ------------------------------------------------------------------ reminder

class ReminderChoice {
  const ReminderChoice(this.at);
  final int? at;
}

/// The bell: the same calendar and time-only wheel as the due pill (his
/// ruling, 2026-11-13). Only the person who sets a reminder gets it.
Future<ReminderChoice?> pickReminder(BuildContext context, {int? current, required String day}) async {
  var start = DateTime(parseDay(day).year, parseDay(day).month, parseDay(day).day, 9);
  if (current == null && start.isBefore(DateTime.now())) {
    final n = DateTime.now().add(const Duration(hours: 1));
    start = DateTime(n.year, n.month, n.day, n.hour);
  }
  final r = await pickDueMoment(
    context,
    title: 'Reminder',
    current: current,
    currentHasTime: true,
    startDay: dayKey(start),
    startHour: start.hour,
    startMinute: 0,
    firstDay: todayKey(),
    setLabel: 'Set reminder',
    removeLabel: current == null ? null : 'Remove reminder',
    note: 'Only you get this reminder.',
  );
  return r == null ? null : ReminderChoice(r.at);
}
