import 'package:flutter/material.dart';

import 'tokens.dart';

/// Builds Kolumn's Material 3 Expressive [ThemeData], adapted from ConvoMail's
/// `AppTheme`, with soft shadows added (Kolumn's cards are raised, not flat).
abstract final class KolumnTheme {
  static ThemeData light() => _build(KolumnColors.light, KolumnPalette.light);
  static ThemeData dark() => _build(KolumnColors.dark, KolumnPalette.dark);

  static ThemeData _build(ColorScheme scheme, KolumnPalette palette) {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: scheme.brightness,
      scaffoldBackgroundColor: scheme.surface,
      splashFactory: InkSparkle.splashFactory,
    );
    final t = base.textTheme;
    final on = scheme.onSurface;
    final text = t.copyWith(
      headlineSmall: t.headlineSmall!.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.3, color: on),
      titleLarge: t.titleLarge!.copyWith(fontWeight: FontWeight.w600, letterSpacing: -0.2, color: on),
      titleMedium: t.titleMedium!.copyWith(fontWeight: FontWeight.w600, color: on),
      titleSmall: t.titleSmall!.copyWith(fontWeight: FontWeight.w600, color: on),
      bodyLarge: t.bodyLarge!.copyWith(color: on),
      bodyMedium: t.bodyMedium!.copyWith(color: on),
      bodySmall: t.bodySmall!.copyWith(color: scheme.onSurfaceVariant),
      labelLarge: t.labelLarge!.copyWith(fontWeight: FontWeight.w600, color: on),
      labelMedium: t.labelMedium!.copyWith(fontWeight: FontWeight.w500, color: scheme.onSurfaceVariant),
    );

    return base.copyWith(
      textTheme: text,
      extensions: [palette],
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: on,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: text.titleLarge,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: palette.card,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: palette.dash,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(KShapes.sheet))),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: palette.card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(KShapes.sheet)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: text.bodyMedium!.copyWith(color: scheme.onInverseSurface),
        actionTextColor: scheme.inversePrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(KShapes.lg)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.lane,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(KShapes.lg), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(KShapes.lg), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KShapes.lg),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(KShapes.lg)),
          minimumSize: const Size(0, 50),
          textStyle: text.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(shape: const StadiumBorder(), textStyle: text.labelLarge, minimumSize: const Size(48, 44)),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: scheme.onSurfaceVariant, minimumSize: const Size(44, 44)),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(style: SegmentedButton.styleFrom(minimumSize: const Size(0, 46))),
      popupMenuTheme: PopupMenuThemeData(
        color: palette.card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(KShapes.md)),
        elevation: 6,
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant, space: 1, thickness: 1),
    );
  }
}
