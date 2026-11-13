import 'package:flutter/material.dart';

/// Kolumn's design tokens.
///
/// Light is ConvoMail's Material 3 Expressive scheme (indigo seed, lilac
/// surfaces), taken from duraleigh/convomail `lib/ui/theme/tokens.dart`.
/// Dark is Kolumn mock-up C (charcoal and violet), from
/// `mockups/project/Main.dc.html`.
abstract final class KolumnColors {
  static const ColorScheme light = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF4653D0),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFDFE0FF),
    onPrimaryContainer: Color(0xFF0B1A7A),
    secondary: Color(0xFF5B5D72),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFE0E1F9),
    onSecondaryContainer: Color(0xFF181A2C),
    tertiary: Color(0xFF77536D),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFFFD7F1),
    onTertiaryContainer: Color(0xFF2D1228),
    error: Color(0xFFBA1A1A),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF410002),
    surface: Color(0xFFFBF8FF),
    onSurface: Color(0xFF1B1B21),
    surfaceDim: Color(0xFFDBD9E0),
    surfaceBright: Color(0xFFFBF8FF),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFF5F2FA),
    surfaceContainer: Color(0xFFEFEDF4),
    surfaceContainerHigh: Color(0xFFE9E7EF),
    surfaceContainerHighest: Color(0xFFE3E1E9),
    onSurfaceVariant: Color(0xFF5B5D72),
    outline: Color(0xFF777680),
    outlineVariant: Color(0xFFC7C5D0),
    inverseSurface: Color(0xFF303036),
    onInverseSurface: Color(0xFFF2EFF7),
    inversePrimary: Color(0xFFBCC2FF),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
  );

  static const ColorScheme dark = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF7C3AED),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFF2E2350),
    onPrimaryContainer: Color(0xFFDDD6FE),
    secondary: Color(0xFFA3AAB8),
    onSecondary: Color(0xFF111318),
    secondaryContainer: Color(0xFF2C313C),
    onSecondaryContainer: Color(0xFFE7E9EE),
    tertiary: Color(0xFFF9A8D4),
    onTertiary: Color(0xFF3B0A24),
    tertiaryContainer: Color(0xFF4A1D35),
    onTertiaryContainer: Color(0xFFFBD5E8),
    error: Color(0xFFEF4444),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFF3B1D22),
    onErrorContainer: Color(0xFFFCA5A5),
    surface: Color(0xFF111318),
    onSurface: Color(0xFFF1F3F7),
    surfaceDim: Color(0xFF0B0D11),
    surfaceBright: Color(0xFF2C313C),
    surfaceContainerLowest: Color(0xFF21252E),
    surfaceContainerLow: Color(0xFF181B22),
    surfaceContainer: Color(0xFF0B0D11),
    surfaceContainerHigh: Color(0xFF21252E),
    surfaceContainerHighest: Color(0xFF2C313C),
    onSurfaceVariant: Color(0xFFA3AAB8),
    outline: Color(0xFF6B7280),
    outlineVariant: Color(0xFF2C313C),
    inverseSurface: Color(0xFFF1F3F7),
    onInverseSurface: Color(0xFF111318),
    inversePrimary: Color(0xFF6D28D9),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
  );
}

/// M3 Expressive shape scale (same steps as ConvoMail).
abstract final class KShapes {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double card = 18;
  static const double lane = 24;
  static const double sheet = 28;
}

/// Colors a column can be given. Index 0 is the default.
class LaneColor {
  const LaneColor(this.name, this.light, this.dark);
  final String name;
  final Color light;
  final Color dark;

  Color of(Brightness b) => b == Brightness.dark ? dark : light;
}

abstract final class LaneColors {
  static const List<LaneColor> all = [
    LaneColor('Indigo', Color(0xFF4653D0), Color(0xFFA78BFA)),
    LaneColor('Green', Color(0xFF1D9E75), Color(0xFF34D399)),
    LaneColor('Amber', Color(0xFFBA7517), Color(0xFFFBBF24)),
    LaneColor('Pink', Color(0xFFB83280), Color(0xFFF472B6)),
    LaneColor('Blue', Color(0xFF1F6FC5), Color(0xFF60A5FA)),
    LaneColor('Orange', Color(0xFFC2410C), Color(0xFFFB923C)),
    LaneColor('Teal', Color(0xFF0F766E), Color(0xFF2DD4BF)),
    LaneColor('Gray', Color(0xFF8E8CA3), Color(0xFF6B7280)),
  ];

  static const LaneColor quiet = LaneColor('Gray', Color(0xFF8E8CA3), Color(0xFF6B7280));

  static LaneColor at(int i) => all[(i < 0 || i >= all.length) ? 0 : i];
}

/// Extra theme values Material's ColorScheme has no slot for: the soft 3D
/// shadows, and the lane and card fills.
@immutable
class KolumnPalette extends ThemeExtension<KolumnPalette> {
  const KolumnPalette({
    required this.lane,
    required this.todoLane,
    required this.card,
    required this.chip,
    required this.dash,
    required this.accentText,
    required this.cardShadow,
    required this.liftShadow,
    required this.trayShadow,
    required this.dangerBg,
    required this.dangerText,
    required this.dueToday,
    required this.lateRow,
    required this.lateRowText,
  });

  final Color lane;
  final Color todoLane;
  final Color card;
  final Color chip;
  final Color dash;
  final Color accentText;
  final List<BoxShadow> cardShadow;
  final List<BoxShadow> liftShadow;
  final List<BoxShadow> trayShadow;
  final Color dangerBg;
  final Color dangerText;

  /// Due today (his rule, 2026-11-13): yellow on dark, a deep readable amber on light.
  final Color dueToday;

  /// Late: a red row with white words.
  final Color lateRow;
  final Color lateRowText;

  static const KolumnPalette light = KolumnPalette(
    lane: Color(0xFFF2EFF8),
    todoLane: Color(0xFFF2EFF8),
    card: Color(0xFFFFFFFF),
    chip: Color(0xFFEAE7F2),
    dash: Color(0xFFC5C7EE),
    accentText: Color(0xFF3442B8),
    cardShadow: [
      BoxShadow(color: Color(0x121B1B21), blurRadius: 2, offset: Offset(0, 1)),
      BoxShadow(color: Color(0x1A4653D0), blurRadius: 16, offset: Offset(0, 6)),
    ],
    liftShadow: [
      BoxShadow(color: Color(0x4D1B1B21), blurRadius: 44, offset: Offset(0, 26)),
      BoxShadow(color: Color(0x404653D0), blurRadius: 14, offset: Offset(0, 8)),
    ],
    trayShadow: [BoxShadow(color: Color(0x244653D0), blurRadius: 34, offset: Offset(0, -14))],
    dangerBg: Color(0xFFFFDAD6),
    dangerText: Color(0xFF93000A),
    dueToday: Color(0xFF92400E),
    lateRow: Color(0xFFB3261E),
    lateRowText: Color(0xFFFFFFFF),
  );

  static const KolumnPalette dark = KolumnPalette(
    lane: Color(0xFF181B22),
    todoLane: Color(0xFF181B22),
    card: Color(0xFF21252E),
    chip: Color(0xFF2C313C),
    dash: Color(0xFF4B5160),
    accentText: Color(0xFFC4B5FD),
    cardShadow: [BoxShadow(color: Color(0x6B000000), blurRadius: 18, offset: Offset(0, 8))],
    liftShadow: [BoxShadow(color: Color(0xA6000000), blurRadius: 48, offset: Offset(0, 26))],
    trayShadow: [BoxShadow(color: Color(0x73000000), blurRadius: 34, offset: Offset(0, -14))],
    dangerBg: Color(0xFF3B1D22),
    dangerText: Color(0xFFFCA5A5),
    dueToday: Color(0xFFFACC15),
    lateRow: Color(0xFFB3261E),
    lateRowText: Color(0xFFFFFFFF),
  );

  @override
  KolumnPalette copyWith() => this;

  @override
  KolumnPalette lerp(ThemeExtension<KolumnPalette>? other, double t) {
    if (other is! KolumnPalette) return this;
    return t < 0.5 ? this : other;
  }
}

extension KolumnThemeX on BuildContext {
  KolumnPalette get palette => Theme.of(this).extension<KolumnPalette>()!;
  ColorScheme get colors => Theme.of(this).colorScheme;
}
