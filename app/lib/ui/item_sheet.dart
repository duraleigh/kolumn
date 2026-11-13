import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../data/due.dart';
import '../planner/days.dart';
import '../theme/tokens.dart';
import 'bits.dart';

/// The pieces a Planner to-do and a Kolumn card are opened with (his ask,
/// 2026-11-13: "look like they came from the same ecosystem"). Both pop-ups
/// are made from these, so they cannot drift apart: the frame that slides up
/// from the bottom, the small line on top, the due pill, the title and note,
/// the checklist, the Photo · Camera · File buttons, the file tiles, and the
/// bottom bar of five buttons. The Planner to-do is the template; a card is
/// the same, plus a part that slides up with its comments and activity.

// ------------------------------------------------------------------ opening

/// A phone: a sheet from the bottom that can be pulled taller. A computer: a
/// panel in the middle.
Future<void> showItemSheet(BuildContext context, Widget Function(bool wide) build) {
  final wide = MediaQuery.sizeOf(context).width >= 840;
  if (wide) {
    return showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(KShapes.sheet)),
        child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 480, maxHeight: 760), child: build(true)),
      ),
    );
  }
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    elevation: 0,
    builder: (context) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: build(false),
    ),
  );
}

/// The frame both pop-ups share. [main] is everything shown at first; [more]
/// (a card's comments and activity) appears only when the sheet is pulled up
/// or the big center button asks for it, with [composer] above the bar.
class ItemSheetFrame extends StatefulWidget {
  const ItemSheetFrame({super.key, required this.wide, required this.main, required this.bar, this.more, this.composer});

  final bool wide;
  final List<Widget> main;
  final Widget bar;
  final List<Widget> Function(BuildContext)? more;
  final Widget? composer;

  static const double startSize = 0.72;
  static const double fullSize = 0.96;

  /// The frame around [context], to open or close its slide-up part.
  static ItemSheetFrameState? of(BuildContext context) => context.findAncestorStateOfType<ItemSheetFrameState>();

  @override
  State<ItemSheetFrame> createState() => ItemSheetFrameState();
}

class ItemSheetFrameState extends State<ItemSheetFrame> {
  final _sheet = DraggableScrollableController();
  final _wideScroll = ScrollController();
  final _moreKey = GlobalKey();
  bool _expanded = false;

  bool get expanded => _expanded;

  @override
  void initState() {
    super.initState();
    _sheet.addListener(() {
      final open = _sheet.size > 0.88;
      if (open != _expanded && widget.more != null) setState(() => _expanded = open);
    });
  }

  @override
  void dispose() {
    _sheet.dispose();
    _wideScroll.dispose();
    super.dispose();
  }

  /// Slides the sheet up to show the hidden part, or back down.
  Future<void> toggle() async {
    if (widget.more == null) return;
    if (widget.wide) {
      setState(() => _expanded = !_expanded);
    } else if (_expanded) {
      await _sheet.animateTo(ItemSheetFrame.startSize, duration: const Duration(milliseconds: 320), curve: Curves.easeOutCubic);
    } else {
      setState(() => _expanded = true);
      await _sheet.animateTo(ItemSheetFrame.fullSize, duration: const Duration(milliseconds: 420), curve: Curves.easeOutCubic);
    }
    if (_expanded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ctx = _moreKey.currentContext;
        if (ctx != null && ctx.mounted) Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 300), curve: Curves.easeOutCubic);
      });
    }
  }

  Widget _body(BuildContext context, ScrollController scroll) {
    final c = context.colors;
    return Material(
      color: Theme.of(context).bottomSheetTheme.backgroundColor ?? c.surfaceContainerLow,
      borderRadius: widget.wide ? null : const BorderRadius.vertical(top: Radius.circular(KShapes.sheet)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              controller: scroll,
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 12),
              children: [
                // The top edge: hold it and pull up to see more (or down to close).
                Semantics(
                  label: 'Pull up for more',
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 10, bottom: 12),
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(color: c.onSurfaceVariant.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                ),
                ...widget.main,
                if (_expanded && widget.more != null) ...[
                  const SizedBox(height: 18),
                  Divider(key: _moreKey, height: 1, color: c.outlineVariant),
                  const SizedBox(height: 14),
                  ...widget.more!(context),
                ],
              ],
            ),
          ),
          if (_expanded && widget.composer != null) widget.composer!,
          widget.bar,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.wide) return _body(context, _wideScroll);
    return DraggableScrollableSheet(
      controller: _sheet,
      expand: false,
      initialChildSize: ItemSheetFrame.startSize,
      minChildSize: 0.3,
      maxChildSize: ItemSheetFrame.fullSize,
      snap: true,
      snapSizes: const [ItemSheetFrame.startSize],
      builder: (context, scroll) => _body(context, scroll),
    );
  }
}

// ------------------------------------------------------------------ the parts

/// The small line at the top: where it lives and when.
class CaptionLine extends StatelessWidget {
  const CaptionLine({super.key, required this.parts, this.dot, this.icon = Icons.calendar_today_outlined});
  final List<String> parts;
  final Color? dot;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          if (dot != null)
            Container(width: 10, height: 10, margin: const EdgeInsets.only(right: 8), decoration: BoxDecoration(color: dot, shape: BoxShape.circle))
          else
            Padding(padding: const EdgeInsets.only(right: 8), child: Icon(icon, size: 16, color: c.onSurfaceVariant)),
          Expanded(
            child: Text(parts.where((p) => p.isNotEmpty).join(' · '), style: TextStyle(fontSize: 14, color: c.onSurfaceVariant)),
          ),
        ],
      ),
    );
  }
}

/// A round button: the due date, and anything else that sits in that row.
class ItemPill extends StatelessWidget {
  const ItemPill({super.key, required this.text, this.icon, this.onTap, this.onClear, this.bg, this.fg, this.bold = false});
  final String text;
  final IconData? icon;
  final VoidCallback? onTap;
  final VoidCallback? onClear;
  final Color? bg;
  final Color? fg;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final color = fg ?? c.onSurface;
    return Material(
      color: bg ?? context.palette.chip,
      shape: const StadiumBorder(),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.fromLTRB(12, 8, onClear == null ? 14 : 4, 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[Icon(icon, size: 17, color: color), const SizedBox(width: 6)],
              Flexible(
                child: Text(
                  text,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, fontWeight: bold ? FontWeight.w800 : FontWeight.w600, color: color),
                ),
              ),
              if (onClear != null)
                InkResponse(
                  radius: 16,
                  onTap: onClear,
                  child: Semantics(
                    label: 'Remove',
                    child: Padding(padding: const EdgeInsets.all(4), child: Icon(Icons.close_rounded, size: 16, color: color)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Fri, 14 Nov" or "Fri, 14 Nov · 3:00 PM", read on this phone.
String dueText(int dueAt, {required bool hasTime, required BuildContext context, String? today}) {
  final day = dueDay(dueAt, hasTime: hasTime);
  final base = friendlyDay(day, today: today);
  if (!hasTime) return base;
  return '$base · ${timeText(DateTime.fromMillisecondsSinceEpoch(dueAt), context)}';
}

/// "3:05 PM", or "15:05" on a 24-hour phone.
String timeText(DateTime d, BuildContext context) {
  if (MediaQuery.alwaysUse24HourFormatOf(context)) return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
  return '$h:${d.minute.toString().padLeft(2, '0')} ${d.hour < 12 ? 'AM' : 'PM'}';
}

/// The due-date pill, the same on cards and to-dos: "Add a due date";
/// "Due Fri, 14 Nov"; amber/yellow on its day; red "LATE" once past.
class DuePill extends StatelessWidget {
  const DuePill({super.key, required this.dueAt, required this.hasTime, required this.state, required this.readOnly, required this.onPick, required this.onClear, this.today});
  final int? dueAt;
  final bool hasTime;
  final DueState state;
  final bool readOnly;
  final VoidCallback onPick;
  final VoidCallback onClear;
  final String? today;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    if (dueAt == null) {
      return ItemPill(icon: Icons.event_outlined, text: readOnly ? 'No due date' : 'Add a due date', onTap: readOnly ? null : onPick);
    }
    final when = dueText(dueAt!, hasTime: hasTime, context: context, today: today);
    final late = state == DueState.late;
    final todayDue = state == DueState.dueToday;
    return ItemPill(
      icon: late ? Icons.error_outline_rounded : Icons.event_outlined,
      text: late ? 'LATE · due $when' : 'Due $when',
      bold: late,
      bg: late ? p.lateRow : null,
      fg: late ? p.lateRowText : (todayDue ? p.dueToday : null),
      onTap: readOnly ? null : onPick,
      onClear: readOnly ? null : onClear,
    );
  }
}

/// The title, full width (no tick beside it: the big button at the bottom does that).
class TitleField extends StatelessWidget {
  const TitleField({super.key, required this.controller, required this.readOnly, required this.onChanged, this.done = false, this.hint = 'Title'});
  final TextEditingController controller;
  final bool readOnly;
  final VoidCallback onChanged;
  final bool done;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return TextField(
      controller: controller,
      readOnly: readOnly,
      onChanged: (_) => onChanged(),
      maxLines: null,
      textCapitalization: TextCapitalization.sentences,
      style: TextStyle(
        fontSize: 23,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        height: 1.2,
        color: done ? c.onSurfaceVariant : c.onSurface,
        decoration: done ? TextDecoration.lineThrough : null,
      ),
      decoration: InputDecoration(isCollapsed: true, filled: false, border: InputBorder.none, enabledBorder: InputBorder.none, focusedBorder: InputBorder.none, hintText: hint),
    );
  }
}

/// The note, full width, lined up with the title. A card's note can hold
/// @mentions and #card links: shown as such until tapped to edit.
class NoteField extends StatefulWidget {
  const NoteField({super.key, required this.controller, required this.readOnly, required this.onChanged, this.onOpenCard});
  final TextEditingController controller;
  final bool readOnly;
  final VoidCallback onChanged;

  /// Set for cards: shows formatting and links until tapped.
  final void Function(String)? onOpenCard;

  @override
  State<NoteField> createState() => _NoteFieldState();
}

class _NoteFieldState extends State<NoteField> {
  final _focus = FocusNode();
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      if (!_focus.hasFocus && _editing) setState(() => _editing = false);
    });
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = widget.controller.text.trim();
    const style = TextStyle(fontSize: 15, height: 1.5);
    if (widget.onOpenCard != null && !_editing && text.isNotEmpty && (markupPattern.hasMatch(text) || text.contains('**') || text.contains('_'))) {
      return InkWell(
        onTap: widget.readOnly
            ? null
            : () => setState(() {
                _editing = true;
                _focus.requestFocus();
              }),
        child: SizedBox(width: double.infinity, child: FormattedText(text, style: style, onOpenCard: widget.onOpenCard)),
      );
    }
    return TextField(
      controller: widget.controller,
      focusNode: _focus,
      readOnly: widget.readOnly,
      onTap: () => _editing = true,
      onChanged: (_) => widget.onChanged(),
      maxLines: null,
      minLines: 1,
      textCapitalization: TextCapitalization.sentences,
      style: style,
      decoration: InputDecoration(
        isCollapsed: true,
        filled: false,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        hintText: widget.readOnly ? '' : 'Add a note',
      ),
    );
  }
}

/// A round tick, Tweek-style.
class CheckCircle extends StatelessWidget {
  const CheckCircle({super.key, required this.done, this.size = 22});
  final bool done;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final done0 = c.onSurfaceVariant.withValues(alpha: 0.55);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done ? done0 : Colors.transparent,
        border: Border.all(color: done ? done0 : c.onSurface, width: 1.6),
      ),
      child: done ? Icon(Icons.check_rounded, size: size * 0.7, color: c.surface) : null,
    );
  }
}

/// One line of a checklist: tap to tick, ⋮ (or hold) for its options.
class ChecklistRow extends StatelessWidget {
  const ChecklistRow({
    super.key,
    required this.content,
    required this.done,
    required this.readOnly,
    required this.onToggle,
    required this.onMenu,
    this.heading = false,
    this.star = false,
    this.indent = 0,
  });
  final String content;
  final bool done;
  final bool heading;
  final bool star;
  final int indent;
  final bool readOnly;
  final VoidCallback onToggle;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    if (heading) {
      return InkWell(
        onLongPress: readOnly ? null : onMenu,
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 4),
                child: Text(content, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
            if (!readOnly)
              IconButton(
                tooltip: 'Step options',
                onPressed: onMenu,
                icon: Icon(Icons.more_vert_rounded, size: 18, color: c.onSurfaceVariant),
              ),
          ],
        ),
      );
    }
    return InkWell(
      onTap: readOnly ? null : onToggle,
      onLongPress: readOnly ? null : onMenu,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: Padding(
          padding: EdgeInsets.only(left: 20.0 * indent),
          child: Row(
            children: [
              CheckCircle(done: done, size: 18),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  content,
                  style: TextStyle(fontSize: 15, color: done ? c.onSurfaceVariant : c.onSurface, decoration: done ? TextDecoration.lineThrough : null),
                ),
              ),
              if (star) Icon(Icons.star_rounded, size: 17, color: context.palette.accentText),
              if (!readOnly)
                IconButton(
                  tooltip: 'Step options',
                  onPressed: onMenu,
                  icon: Icon(Icons.more_vert_rounded, size: 18, color: c.onSurfaceVariant),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Add a step", stretching the full width (no Heading button: a step's own
/// ⋮ menu has "Make it a heading").
class AddStepField extends StatelessWidget {
  const AddStepField({super.key, required this.controller, required this.onAdd});
  final TextEditingController controller;
  final ValueChanged<String> onAdd;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 44),
      child: Row(
        children: [
          Padding(padding: const EdgeInsets.only(right: 12), child: Icon(Icons.add_rounded, size: 20, color: c.onSurfaceVariant)),
          Expanded(
            child: TextField(
              controller: controller,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.next,
              onEditingComplete: () {},
              onSubmitted: (v) {
                if (v.trim().isEmpty) return;
                onAdd(v.trim());
                controller.clear();
              },
              style: const TextStyle(fontSize: 15),
              decoration: const InputDecoration(
                isCollapsed: true,
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintText: 'Add a step',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Photo · Camera · File.
class AttachChips extends StatelessWidget {
  const AttachChips({super.key, required this.onPhoto, required this.onCamera, required this.onFile});
  final VoidCallback onPhoto;
  final VoidCallback onCamera;
  final VoidCallback onFile;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 10),
    child: Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ActionChip(avatar: const Icon(Icons.photo_outlined, size: 18), label: const Text('Photo'), onPressed: onPhoto),
        ActionChip(avatar: const Icon(Icons.photo_camera_outlined, size: 18), label: const Text('Camera'), onPressed: onCamera),
        ActionChip(avatar: const Icon(Icons.attach_file_rounded, size: 18), label: const Text('File'), onPressed: onFile),
      ],
    ),
  );
}

/// A photo or file on a card or to-do, for [FileTiles].
class FileTileData {
  const FileTileData({required this.id, required this.filename, required this.mime, required this.size, this.uploaded = true, this.cover = false});
  final String id;
  final String filename;
  final String mime;
  final int size;
  final bool uploaded;
  final bool cover;
}

/// Photos and files, three across.
class FileTiles extends StatelessWidget {
  const FileTiles({super.key, required this.files, required this.onOpen, this.onHold});
  final List<FileTileData> files;
  final void Function(FileTileData) onOpen;
  final void Function(FileTileData)? onHold;

  @override
  Widget build(BuildContext context) {
    if (files.isEmpty) return const SizedBox.shrink();
    final p = context.palette;
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: LayoutBuilder(
        builder: (context, box) {
          final w = (box.maxWidth - 16) / 3;
          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final f in files)
                GestureDetector(
                  onTap: () => onOpen(f),
                  onLongPress: onHold == null ? null : () => onHold!(f),
                  child: SizedBox(
                    width: w,
                    height: w,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (f.mime.startsWith('image/'))
                            HubPicture(fileId: f.id)
                          else
                            Container(
                              color: p.lane,
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.description_outlined, color: p.accentText, size: 30),
                                  const SizedBox(height: 6),
                                  Text(f.filename, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
                                  Text(sizeText(f.size), style: Theme.of(context).textTheme.bodySmall),
                                ],
                              ),
                            ),
                          if (!f.uploaded)
                            Positioned(
                              right: 6,
                              top: 6,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(color: c.inverseSurface, shape: BoxShape.circle),
                                child: Icon(Icons.cloud_upload_outlined, size: 14, color: c.onInverseSurface),
                              ),
                            ),
                          if (f.cover)
                            Positioned(
                              left: 6,
                              bottom: 6,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(color: c.inverseSurface, borderRadius: BorderRadius.circular(999)),
                                child: Text('Cover', style: TextStyle(fontSize: 11, color: c.onInverseSurface)),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// One of the four small buttons in the bottom bar.
class BarIcon extends StatelessWidget {
  const BarIcon({super.key, required this.icon, required this.label, required this.onTap, this.on = false});
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool on;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Tooltip(
      message: label,
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: on ? c.primary : c.onSurface),
        style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
      ),
    );
  }
}

/// The big round button in the middle of the bottom bar.
class BarCenter extends StatelessWidget {
  const BarCenter({super.key, required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Tooltip(
      message: label,
      child: Material(
        color: c.onSurface,
        shape: const CircleBorder(),
        elevation: 3,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(width: 56, height: 56, child: Icon(icon, color: c.surface)),
        ),
      ),
    );
  }
}

/// The bottom bar: five buttons, the big one in the middle.
class ItemBar extends StatelessWidget {
  const ItemBar({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 12),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: children),
    ),
  );
}

// ------------------------------------------------------------------ pickers

/// What [pickDueMoment] gives back: a moment and whether a time was picked,
/// or [at] null to remove it.
class DueChoice {
  const DueChoice(this.at, {this.hasTime = false});
  final int? at;
  final bool hasTime;
}

/// A calendar, with a wheel for the time only under it, all in one pop-up
/// (his ruling, 2026-11-13). Used by the due pill (time starts at 11:59 PM)
/// and the bell (reminders). Null when closed without choosing.
Future<DueChoice?> pickDueMoment(
  BuildContext context, {
  required String title,
  int? current,
  bool currentHasTime = false,
  required String startDay,
  int startHour = 23,
  int startMinute = 59,
  String? firstDay,
  String setLabel = 'Set',
  String? removeLabel,
  String? note,
}) {
  final first = parseDay(firstDay ?? '2000-01-01');
  final last = DateTime(2099, 12, 31);
  DateTime day;
  int hour = startHour, minute = startMinute;
  if (current != null) {
    final d = DateTime.fromMillisecondsSinceEpoch(current);
    day = parseDay(currentHasTime ? dayKey(d) : dueDay(current));
    if (currentHasTime) {
      hour = d.hour;
      minute = d.minute;
    }
  } else {
    day = parseDay(startDay);
  }
  if (day.isBefore(first)) day = first;
  return showModalBottomSheet<DueChoice>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (context) => StatefulBuilder(
      builder: (context, set) {
        final c = context.colors;
        final use24 = MediaQuery.alwaysUse24HourFormatOf(context);
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
                CalendarDatePicker(initialDate: day, firstDate: first, lastDate: last, onDateChanged: (d) => set(() => day = d)),
                Container(
                  height: 150,
                  decoration: BoxDecoration(color: context.palette.chip, borderRadius: BorderRadius.circular(18)),
                  child: CupertinoTheme(
                    data: CupertinoThemeData(
                      brightness: Theme.of(context).brightness,
                      textTheme: CupertinoTextThemeData(dateTimePickerTextStyle: TextStyle(fontSize: 19, color: c.onSurface)),
                    ),
                    child: CupertinoDatePicker(
                      key: const ValueKey('time-wheel'),
                      mode: CupertinoDatePickerMode.time,
                      use24hFormat: use24,
                      initialDateTime: DateTime(2000, 1, 1, hour, minute),
                      onDateTimeChanged: (v) {
                        hour = v.hour;
                        minute = v.minute;
                      },
                    ),
                  ),
                ),
                if (note != null) ...[
                  const SizedBox(height: 10),
                  Text(note, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: c.onSurfaceVariant)),
                ],
                const SizedBox(height: 12),
                FilledButton(
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50), backgroundColor: c.onSurface, foregroundColor: c.surface),
                  onPressed: () {
                    final at = DateTime(day.year, day.month, day.day, hour, minute);
                    Navigator.pop(context, DueChoice(at.millisecondsSinceEpoch, hasTime: !(hour == 23 && minute == 59)));
                  },
                  child: Text(setLabel),
                ),
                if (removeLabel != null) TextButton(onPressed: () => Navigator.pop(context, const DueChoice(null)), child: Text(removeLabel)),
              ],
            ),
          ),
        );
      },
    ),
  );
}

/// A date wheel that refuses days outside [min]..[max] (it springs back).
/// Used by "Move to a different date".
Future<String?> pickDayWheel(BuildContext context, {required String title, required String initial, String? min, String? max, String? note}) {
  var picked = parseDay(initial);
  final lo = min == null ? null : parseDay(min);
  final hi = max == null ? null : parseDay(max);
  if (lo != null && picked.isBefore(lo)) picked = lo;
  if (hi != null && picked.isAfter(hi)) picked = hi;
  return showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      final c = context.colors;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Container(
                height: 200,
                decoration: BoxDecoration(color: context.palette.chip, borderRadius: BorderRadius.circular(18)),
                child: CupertinoTheme(
                  data: CupertinoThemeData(
                    brightness: Theme.of(context).brightness,
                    textTheme: CupertinoTextThemeData(dateTimePickerTextStyle: TextStyle(fontSize: 19, color: c.onSurface)),
                  ),
                  child: CupertinoDatePicker(
                    key: const ValueKey('day-wheel'),
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: picked,
                    minimumDate: lo,
                    maximumDate: hi == null ? null : DateTime(hi.year, hi.month, hi.day, 23, 59),
                    onDateTimeChanged: (v) => picked = v,
                  ),
                ),
              ),
              if (note != null) ...[
                const SizedBox(height: 10),
                Text(note, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: c.onSurfaceVariant)),
              ],
              const SizedBox(height: 12),
              FilledButton(
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50), backgroundColor: c.onSurface, foregroundColor: c.surface),
                onPressed: () => Navigator.pop(context, dayKey(picked)),
                child: const Text('Move'),
              ),
            ],
          ),
        ),
      );
    },
  );
}
