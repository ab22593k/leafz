import 'package:flutter/material.dart';
import 'package:leafz/ui/core/layout/screen_type_helper.dart';

/// Typographic tokens for Leafz.
///
/// Two voices, deliberately contrasted:
///
/// * **Noto Serif** ([displayFontFamily]) — the editorial voice. Mastheads,
///   section titles, the solved-state cover, and the phrase pull-quote.
///   Tight tracking, weight carried by scale rather than boldness.
/// * **Montserrat** ([bodyFontFamily]) — the interface voice. Titles, body,
///   buttons, and metadata. Crisp, geometric, legible at 11–14px.
///
/// Metadata is set as a *kicker*: uppercase, wide tracking, small size.
/// That convention is what makes a screen read as editorial rather than as
/// a settings panel — the caps are applied at the call site
/// (`label.toUpperCase()`) because not every locale has case.
///
/// Methods are getters, not `static final` fields, so each access returns a
/// fresh immutable [TextStyle] and `copyWith` at a call site can never leak
/// into another widget's style.
class AppTextStyles {
  AppTextStyles._();

  static const String displayFontFamily = 'NotoSerif';
  static const String bodyFontFamily = 'Montserrat';

  /// Legacy names kept as aliases: `primaryFontFamily` is the editorial
  /// display face, `secondaryFontFamily` the UI face. Both are referenced
  /// from the theme and from widgets that predate the split.
  static const String primaryFontFamily = displayFontFamily;
  static const String secondaryFontFamily = bodyFontFamily;

  /// Masthead: the largest type in the product. Used once per screen.
  static TextStyle get displayLarge => const TextStyle(
    fontFamily: displayFontFamily,
    fontSize: 56,
    fontWeight: FontWeight.w400,
    height: 1.05,
    letterSpacing: -1.6,
    fontVariations: [FontVariation('wght', 400)],
  );

  static TextStyle get displayMedium => const TextStyle(
    fontFamily: displayFontFamily,
    fontSize: 44,
    fontWeight: FontWeight.w400,
    height: 1.08,
    letterSpacing: -1.2,
    fontVariations: [FontVariation('wght', 400)],
  );

  static TextStyle get displaySmall => const TextStyle(
    fontFamily: displayFontFamily,
    fontSize: 34,
    fontWeight: FontWeight.w400,
    height: 1.12,
    letterSpacing: -0.9,
    fontVariations: [FontVariation('wght', 400)],
  );

  /// Section titles. The working headline of the product.
  static TextStyle get headlineLarge => const TextStyle(
    fontFamily: displayFontFamily,
    fontSize: 30,
    fontWeight: FontWeight.w400,
    height: 1.18,
    letterSpacing: -0.6,
    fontVariations: [FontVariation('wght', 450)],
  );

  static TextStyle get headlineMedium => const TextStyle(
    fontFamily: displayFontFamily,
    fontSize: 25,
    fontWeight: FontWeight.w400,
    height: 1.22,
    letterSpacing: -0.4,
    fontVariations: [FontVariation('wght', 450)],
  );

  static TextStyle get headlineSmall => const TextStyle(
    fontFamily: displayFontFamily,
    fontSize: 21,
    fontWeight: FontWeight.w400,
    height: 1.28,
    letterSpacing: -0.2,
    fontVariations: [FontVariation('wght', 450)],
  );

  /// Wordmark / small-caps masthead line: serif, tracked open, set in caps.
  static TextStyle get wordmark => const TextStyle(
    fontFamily: displayFontFamily,
    fontSize: 19,
    fontWeight: FontWeight.w600,
    height: 1.0,
    letterSpacing: 3.4,
    fontVariations: [FontVariation('wght', 600)],
  );

  /// Editorial pull-quote (phrase bubble). Roman, generous leading.
  static TextStyle get quote => const TextStyle(
    fontFamily: displayFontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: -0.1,
    fontVariations: [FontVariation('wght', 450)],
  );

  /// List-row title in the display voice. Sits between [quote] and
  /// [headlineSmall] so drawers can name options without shouting.
  static TextStyle get listTitle => const TextStyle(
    fontFamily: displayFontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.2,
    letterSpacing: -0.1,
    fontVariations: [FontVariation('wght', 500)],
  );

  static TextStyle get titleLarge => const TextStyle(
    fontFamily: bodyFontFamily,
    fontSize: 19,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.2,
    fontVariations: [FontVariation('wght', 600)],
  );

  static TextStyle get titleMedium => const TextStyle(
    fontFamily: bodyFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.35,
    letterSpacing: -0.1,
    fontVariations: [FontVariation('wght', 600)],
  );

  static TextStyle get titleSmall => const TextStyle(
    fontFamily: bodyFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
    fontVariations: [FontVariation('wght', 600)],
  );

  static TextStyle get bodyLarge => const TextStyle(
    fontFamily: bodyFontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.6,
    fontVariations: [FontVariation('wght', 400)],
  );

  static TextStyle get bodyMedium => const TextStyle(
    fontFamily: bodyFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.6,
    fontVariations: [FontVariation('wght', 400)],
  );

  static TextStyle get bodySmall => const TextStyle(
    fontFamily: bodyFontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.55,
    fontVariations: [FontVariation('wght', 400)],
  );

  /// Smallest body size in the system — metadata captions only.
  static TextStyle get bodyXxs => const TextStyle(
    fontFamily: bodyFontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.2,
    fontVariations: [FontVariation('wght', 500)],
  );

  static TextStyle get labelLarge => const TextStyle(
    fontFamily: bodyFontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.6,
    fontVariations: [FontVariation('wght', 600)],
  );

  static TextStyle get labelMedium => const TextStyle(
    fontFamily: bodyFontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: 1.0,
    fontVariations: [FontVariation('wght', 600)],
  );

  static TextStyle get labelSmall => const TextStyle(
    fontFamily: bodyFontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 1.4,
    fontVariations: [FontVariation('wght', 600)],
  );

  /// Uppercase metadata kicker. Call sites uppercase the string; this token
  /// only owns the size, weight, and tracking. Use above a heading or as a
  /// column label.
  static TextStyle get kicker => const TextStyle(
    fontFamily: bodyFontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: 2.2,
    fontVariations: [FontVariation('wght', 700)],
  );

  /// Section label inside the drawer / sidebar. Same voice as [kicker],
  /// one step larger so it can head a group of controls.
  static TextStyle get sectionLabel => const TextStyle(
    fontFamily: bodyFontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: 1.8,
    fontVariations: [FontVariation('wght', 700)],
  );

  /// Live numerals — timer, move count, tiles solved, score values.
  ///
  /// Serif (so the numbers belong to the editorial voice) with tabular
  /// figures (so the timer does not reflow as digits change width). The
  /// `tnum` feature is requested both as a font feature and through the
  /// variable axis so static and variable builds agree.
  static TextStyle get statValue => const TextStyle(
    fontFamily: displayFontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w500,
    height: 1.1,
    letterSpacing: -0.2,
    fontFeatures: [FontFeature.tabularFigures()],
    fontVariations: [FontVariation('wght', 500)],
  );

  static TextStyle get statValueSmall => const TextStyle(
    fontFamily: displayFontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w500,
    height: 1.15,
    letterSpacing: -0.1,
    fontFeatures: [FontFeature.tabularFigures()],
    fontVariations: [FontVariation('wght', 500)],
  );

  /// Button label — tracked caps, set by the call site.
  static TextStyle get button => const TextStyle(
    fontFamily: bodyFontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 1.0,
    letterSpacing: 1.8,
    fontVariations: [FontVariation('wght', 700)],
  );

  static TextStyle get tile => const TextStyle(
    fontFamily: bodyFontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.0,
    letterSpacing: -1.0,
    fontFeatures: [FontFeature.tabularFigures()],
    fontVariations: [FontVariation('wght', 700)],
  );

  static TextStyle get tileMobile => const TextStyle(
    fontFamily: bodyFontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.0,
    letterSpacing: -0.6,
    fontFeatures: [FontFeature.tabularFigures()],
    fontVariations: [FontVariation('wght', 700)],
  );

  /// Secondary headline used by the phrase bubble before the pull-quote
  /// token existed. Kept so older call sites keep a sane value.
  static TextStyle get h2 => quote;

  static TextStyle tileAdaptive(WindowClass wc) => switch (wc) {
    WindowClass.compact => tileMobile,
    WindowClass.medium => tile,
    WindowClass.expanded ||
    WindowClass.large ||
    WindowClass.extraLarge => tile.copyWith(fontSize: 36),
  };

  static TextStyle titleAdaptive(WindowClass wc) => switch (wc) {
    WindowClass.compact => titleSmall,
    WindowClass.medium => titleMedium,
    WindowClass.expanded ||
    WindowClass.large ||
    WindowClass.extraLarge => titleLarge,
  };

  static TextStyle bodyAdaptive(WindowClass wc) => switch (wc) {
    WindowClass.compact => bodySmall,
    WindowClass.medium => bodyMedium,
    WindowClass.expanded ||
    WindowClass.large ||
    WindowClass.extraLarge => bodyLarge,
  };

  static TextStyle labelAdaptive(WindowClass wc) => switch (wc) {
    WindowClass.compact => labelSmall,
    WindowClass.medium => labelMedium,
    WindowClass.expanded ||
    WindowClass.large ||
    WindowClass.extraLarge => labelLarge,
  };

  /// Stat values scale with the window class but stay serif and tabular.
  static TextStyle statAdaptive(WindowClass wc) => switch (wc) {
    WindowClass.compact => statValueSmall,
    _ => statValue,
  };
}
