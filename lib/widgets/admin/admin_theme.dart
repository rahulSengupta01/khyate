import 'package:flutter/material.dart';

/// Teal/green theme for Admin Dashboard - fitness/wellness management.
/// Modern palette with distinct container backgrounds and white button text.
class AdminTheme {
  AdminTheme._();

  // Primary & accent
  static const Color primary = Color(0xFF0D9488);
  static const Color primaryLight = Color(0xFF14B8A6);
  static const Color primaryDark = Color(0xFF0F766E);
  static const Color accent = Color(0xFF06B6D4);

  // Surfaces - distinct backgrounds for variety
  static const Color surface = Color(0xFFF1F5F9);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color cardBgTint = Color(0xFFF0FDFA);
  static const Color cardBgDark = Color(0xFF334155);
  static const Color filterBarBg = Color(0xFFE2E8F0);
  static const Color filterBarBgDark = Color(0xFF475569);
  static const Color tableHeaderBg = Color(0xFFCCFBF1);
  static const Color tableHeaderBgDark = Color(0xFF134E4A);
  static const Color tableRowAlt = Color(0xFFF8FAFC);

  // Text
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textOnPrimary = Colors.white;

  /// Dark mode: dark blue for input fields, dropdowns, upload sections.
  static const Color fieldBgDark = Color(0xFF1E3A5F);
  static const Color fieldBorderDark = Color(0xFF2D4A6F);
  static const Color fieldTextDark = Color(0xFFE2E8F0);
  static const Color fieldTextMutedDark = Color(0xFF94A3B8);

  /// Theme-dependent field colors: dark blue in dark mode, scheme-based in light mode.
  static Color fieldBg(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? fieldBgDark : Theme.of(context).colorScheme.surfaceContainerHighest;
  }
  static Color fieldBorder(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? fieldBorderDark : Theme.of(context).colorScheme.outline;
  }
  static Color fieldText(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? fieldTextDark : Theme.of(context).colorScheme.onSurface;
  }
  static Color fieldTextMuted(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? fieldTextMutedDark : Theme.of(context).colorScheme.onSurfaceVariant;
  }

  /// Overlay color for edit icon on photos: no grey in dark mode (use white24); light mode black54.
  static Color editOverlayColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.white24 : Colors.black54;
  }

  // Semantic
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderDark = Color(0xFF475569);

  static const double radiusCard = 16;
  static const double radiusButton = 10;
  static const double elevationCard = 4;
  static const double sidebarWidth = 260;
  static const double sidebarWidthCollapsed = 72;

  /// Use for all primary action buttons so text is always white.
  static ButtonStyle get primaryButtonStyle => FilledButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: textOnPrimary,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusButton)),
      );

  /// Form container decoration matching promo code style (tinted card, border, shadow).
  static BoxDecoration formCardDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark ? cardBgDark : cardBgTint,
      borderRadius: BorderRadius.circular(radiusCard),
      border: Border.all(color: primary.withOpacity(0.2), width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(isDark ? 0.2 : 0.06),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// Input decoration for admin forms – theme-dependent (dark blue in dark mode, scheme in light).
  static InputDecoration inputDecoration(
    BuildContext context, {
    String? labelText,
    String? hintText,
    Widget? prefixIcon,
    bool isDense = false,
  }) {
    final muted = fieldTextMuted(context);
    final borderColor = fieldBorder(context);
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon != null
          ? IconTheme.merge(
              data: IconThemeData(color: muted),
              child: prefixIcon,
            )
          : null,
      filled: true,
      fillColor: fieldBg(context),
      labelStyle: TextStyle(color: muted),
      hintStyle: TextStyle(color: muted),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusButton),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusButton),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusButton),
        borderSide: BorderSide(color: primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusButton),
        borderSide: const BorderSide(color: error),
      ),
      isDense: isDense,
    );
  }

  /// Text style for text inside inputs/dropdowns – theme-dependent.
  static TextStyle fieldTextStyle(BuildContext context) =>
      TextStyle(color: fieldText(context), fontSize: 16);

  /// Decoration for upload / dropzone sections – theme-dependent.
  static BoxDecoration uploadSectionDecoration(BuildContext context) => BoxDecoration(
        color: fieldBg(context),
        borderRadius: BorderRadius.circular(radiusCard),
        border: Border.all(color: fieldBorder(context), width: 2),
      );

  /// Decoration for SearchableDropdown trigger – theme-dependent.
  static BoxDecoration dropdownTriggerDecoration(BuildContext context) => BoxDecoration(
        color: fieldBg(context),
        borderRadius: BorderRadius.circular(radiusButton),
        border: Border.all(color: fieldBorder(context)),
      );

  /// Label and value styles for SearchableDropdown in admin – theme-dependent.
  static TextStyle dropdownLabelStyle(BuildContext context) => TextStyle(
        color: fieldTextMuted(context),
        fontSize: 12,
        fontWeight: FontWeight.w500,
      );
  static TextStyle dropdownValueStyle(BuildContext context) => TextStyle(
        color: fieldText(context),
        fontSize: 16,
      );
}
