import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ─── BASE PALETTE ──────────────────────────────────────────────────────────
  // Warm dark theme — stadium under floodlights feel

  static const Color background    = Color(0xFF12100E); // Very dark warm brown
  static const Color surface       = Color(0xFF1E1B18); // Dark warm grey
  static const Color surfaceRaised = Color(0xFF252220); // Slightly lifted surface
  static const Color surfaceModal  = Color(0xFF2B2825); // Modal / bottom sheet
  static const Color cardGrey      = Color(0xFF2B2825); // Card base
  static const Color cardBorder    = Color(0xFF3A3530); // Subtle card border
  static const Color divider       = Color(0xFF302C28); // Dividers / separators

  // ─── BRAND ────────────────────────────────────────────────────────────────

  static const Color primary       = Color(0xFFFFA000); // Amber — primary CTA
  static const Color primaryLight  = Color(0xFFFFB300); // Hover / lighter amber
  static const Color primaryDark   = Color(0xFFE65100); // Pressed / deeper amber
  static const Color secondary     = Color(0xFFFF5722); // Deep Orange — secondary CTA
  static const Color accent        = Color(0xFFFFD54F); // Warm Yellow — highlights
  static const Color accentMuted   = Color(0xFFFFE0A0); // Soft yellow tint

  // ─── TEXT ─────────────────────────────────────────────────────────────────

  static const Color textPrimary   = Colors.white;
  static const Color textSecondary = Color(0xFFECE0D1); // Warm tinted white
  static const Color textMuted     = Color(0xFF9E948A); // Warm muted grey
  static const Color textDisabled  = Color(0xFF5A524C); // Disabled state text
  static const Color textOnPrimary = Color(0xFF12100E); // Text on amber buttons

  // ─── MATCH STATUS ─────────────────────────────────────────────────────────

  /// Live / In-progress match — red pulse
  static const Color live          = Color(0xFFE53935);
  static const Color liveDark      = Color(0xFFB71C1C);
  static const Color liveTint      = Color(0x1AE53935);
  static const Color liveGlow      = Color(0x40E53935);

  /// Upcoming match — cool blue
  static const Color upcoming      = Color(0xFF2196F3);
  static const Color upcomingTint  = Color(0x1A2196F3);

  /// Completed / result match — neutral green
  static const Color completed     = Color(0xFF43A047);
  static const Color completedTint = Color(0x1A43A047);

  /// Abandoned / No result / Rain delay — muted purple-grey
  static const Color abandoned     = Color(0xFF7E57C2);
  static const Color abandonedTint = Color(0x1A7E57C2);

  /// Postponed — warm orange-grey
  static const Color postponed     = Color(0xFFFF8F00);
  static const Color postponedTint = Color(0x1AFF8F00);

  // ─── INNINGS / SCORE ──────────────────────────────────────────────────────

  /// Batting team highlight
  static const Color batting       = Color(0xFFFFA000);
  static const Color battingTint   = Color(0x1AFFA000);

  /// Bowling team highlight
  static const Color bowling       = Color(0xFF29B6F6);
  static const Color bowlingTint   = Color(0x1A29B6F6);

  /// Required run rate — urgent red when high
  static const Color rrr           = Color(0xFFEF5350);
  static const Color rrrSafe       = Color(0xFF66BB6A);

  /// Current run rate
  static const Color crr           = Color(0xFF42A5F5);

  /// Wicket — red alert
  static const Color wicket        = Color(0xFFFF1744);
  static const Color wicketTint    = Color(0x1AFF1744);

  /// Four — boundary green
  static const Color four          = Color(0xFF00E676);
  static const Color fourTint      = Color(0x1A00E676);

  /// Six — gold celebration
  static const Color six           = Color(0xFFFFD600);
  static const Color sixTint       = Color(0x1AFFD600);

  /// Dot ball — muted
  static const Color dot           = Color(0xFF5A524C);

  /// Wide / No-ball
  static const Color extra         = Color(0xFFFF8F00);
  static const Color extraTint     = Color(0x1AFF8F00);

  // ─── RESULT ───────────────────────────────────────────────────────────────

  /// Win — vibrant green
  static const Color win           = Color(0xFF00C853);
  static const Color winTint       = Color(0x1A00C853);
  static const Color winGlow       = Color(0x3300C853);

  /// Loss — muted red
  static const Color loss          = Color(0xFFD32F2F);
  static const Color lossTint      = Color(0x1AD32F2F);

  /// Draw / Tie
  static const Color draw          = Color(0xFFFFB300);
  static const Color drawTint      = Color(0x1AFFB300);

  // ─── FORMATS ──────────────────────────────────────────────────────────────

  /// Test match — deep maroon / heritage
  static const Color formatTest    = Color(0xFF8D1B2A);
  static const Color formatTestBg  = Color(0x1A8D1B2A);

  /// One Day International (ODI) — royal blue
  static const Color formatOdi     = Color(0xFF1565C0);
  static const Color formatOdiBg   = Color(0x1A1565C0);

  /// T20 / T20I — electric purple
  static const Color formatT20     = Color(0xFF6A1B9A);
  static const Color formatT20Bg   = Color(0x1A6A1B9A);

  /// The Hundred / franchise — teal
  static const Color formatOther   = Color(0xFF00695C);
  static const Color formatOtherBg = Color(0x1A00695C);

  // ─── PITCH / VENUE CONDITIONS ─────────────────────────────────────────────

  /// Good pitch — fresh green
  static const Color pitchGood     = Color(0xFF558B2F);

  /// Worn / dusty pitch — warm brown
  static const Color pitchWorn     = Color(0xFF795548);

  /// Wet / rain affected
  static const Color pitchWet      = Color(0xFF0277BD);

  /// Overcast sky
  static const Color conditionCloud= Color(0xFF546E7A);

  /// Sunny / hot
  static const Color conditionSun  = Color(0xFFFDD835);

  // ─── PLAYER PERFORMANCE ───────────────────────────────────────────────────

  /// Outstanding (century / 5-wicket haul)
  static const Color perfElite     = Color(0xFFFFD600);
  static const Color perfEliteTint = Color(0x1AFFD600);

  /// Good (50+ / 3-4 wickets)
  static const Color perfGood      = Color(0xFF00E676);
  static const Color perfGoodTint  = Color(0x1A00E676);

  /// Average
  static const Color perfAverage   = Color(0xFFFF8F00);
  static const Color perfAvgTint   = Color(0x1AFF8F00);

  /// Poor
  static const Color perfPoor      = Color(0xFFEF5350);
  static const Color perfPoorTint  = Color(0x1AEF5350);

  // ─── CHART / GRAPH ────────────────────────────────────────────────────────

  static const Color chartLine1    = Color(0xFFFFA000); // Primary team
  static const Color chartLine2    = Color(0xFF42A5F5); // Opposition
  static const Color chartGrid     = Color(0xFF302C28);
  static const Color chartDot      = Color(0xFFFFD54F);

  // ─── SEMANTIC / SYSTEM ────────────────────────────────────────────────────

  static const Color error         = Color(0xFFFF5252);
  static const Color errorTint     = Color(0x1AFF5252);
  static const Color success       = Color(0xFF66BB6A);
  static const Color successTint   = Color(0x1A66BB6A);
  static const Color warning       = Color(0xFFFFB300);
  static const Color warningTint   = Color(0x1AFFB300);
  static const Color info          = Color(0xFF29B6F6);
  static const Color infoTint      = Color(0x1A29B6F6);
  static const Color gold          = Color(0xFFFFD700);
  static const Color goldTint      = Color(0x1AFFD700);
  static const Color formatTestDark = Color(0xFF4A0E14);
  static const Color wtcSubtitle   = Color(0xFFECACB4);
  static const Color categoryDomestic = Color(0xFF2E7D32);
  static const Color categoryWomen = Color(0xFFAD1457);
  static const Color categoryAbout = Color(0xFF00695C);
  static const Color categoryNeutral = Color(0xFF37474F);
  static const Color screenWarmHeader = Color(0xFF1A0D00);
  static const Color screenWarmHeaderAlt = Color(0xFF1C0E00);
  static const Color screenWarmHeaderSoft = Color(0xFF1A0B00);
  static const Color screenWarmHeaderDeep = Color(0xFF1A1200);
  static const Color screenWarmHeaderLive = Color(0xFF1A0600);
  static const Color screenCrimsonHeader = Color(0xFF1C0808);
  static const Color screenAboutHeaderTop = Color(0xFF1C1000);
  static const Color screenAboutHeaderMid = Color(0xFF0E0800);
  static const Color screenNavyHeader = Color(0xFF0A1020);
  static const Color screenNavy = Color(0xFF080C14);
  static const Color screenNavyGradient = Color(0xFF0D1520);
  static const Color screenNavySurface = Color(0xFF0F1520);
  static const Color screenNavyCard = Color(0xFF0D1420);
  static const Color screenNavyChip = Color(0xFF141C28);
  static const Color screenNavyBorder = Color(0xFF1A2234);
  static const Color screenNavyBorderAlt = Color(0xFF1E2A3A);
  static const Color screenNavyIcon = Color(0xFF2A3550);
  static const Color surfaceInset   = Color(0xFF1A1714);
  static const Color socialTwitter = Color(0xFF1DA1F2);
  static const Color socialFacebook = Color(0xFF1877F2);
  static const Color socialInstagram = Color(0xFFE1306C);
  static const Color socialYoutube = Color(0xFFFF0000);
  static const Color indiaBlue     = Color(0xFF003580);
  static const Color indiaOrange   = Color(0xFFFF671F);
  static const Color australiaGreen = Color(0xFF00843D);
  static const Color australiaGold = Color(0xFFFFCD00);
  static const Color englandBlue   = Color(0xFF002868);
  static const Color englandRed    = Color(0xFFCF142B);
  static const Color pakistanGreen = Color(0xFF01411C);
  static const Color liveMuted     = Color(0xFF3A2020);
  static const Color liveAccent    = Color(0xFFFF7043);
  static const Color shadowSoft    = Color(0x14000000);
  static const Color shadowMedium  = Color(0x18000000);

  // ─── GRADIENT HELPERS ─────────────────────────────────────────────────────

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFFB300), Color(0xFFFFA000)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF1E1B18), Color(0xFF12100E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient liveGradient = LinearGradient(
    colors: [Color(0xFFE53935), Color(0xFFB71C1C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient winGradient = LinearGradient(
    colors: [Color(0xFF00C853), Color(0xFF1B5E20)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient testGradient = LinearGradient(
    colors: [Color(0xFF8D1B2A), Color(0xFF4A0E14)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient odiGradient = LinearGradient(
    colors: [Color(0xFF1565C0), Color(0xFF0D2E6E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient t20Gradient = LinearGradient(
    colors: [Color(0xFF6A1B9A), Color(0xFF350D4D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ─── CONVENIENCE METHODS ──────────────────────────────────────────────────

  /// Returns the correct status color for a match
  static Color matchStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'live':
      case 'in progress':
        return live;
      case 'upcoming':
      case 'scheduled':
        return upcoming;
      case 'completed':
      case 'result':
        return completed;
      case 'abandoned':
      case 'no result':
        return abandoned;
      case 'postponed':
        return postponed;
      default:
        return textMuted;
    }
  }

  /// Returns tint for a match status
  static Color matchStatusTint(String status) {
    switch (status.toLowerCase()) {
      case 'live':
      case 'in progress':
        return liveTint;
      case 'upcoming':
      case 'scheduled':
        return upcomingTint;
      case 'completed':
      case 'result':
        return completedTint;
      case 'abandoned':
      case 'no result':
        return abandonedTint;
      case 'postponed':
        return postponedTint;
      default:
        return Colors.transparent;
    }
  }

  /// Returns the gradient for a cricket format
  static LinearGradient formatGradient(String format) {
    final f = format.toLowerCase();
    if (f.contains('test')) return testGradient;
    if (f.contains('odi') || f.contains('one day')) return odiGradient;
    if (f.contains('t20') || f.contains('twenty')) return t20Gradient;
    return darkGradient;
  }

  /// Returns the base color for a cricket format
  static Color formatColor(String format) {
    final f = format.toLowerCase();
    if (f.contains('test')) return formatTest;
    if (f.contains('odi') || f.contains('one day')) return formatOdi;
    if (f.contains('t20') || f.contains('twenty')) return formatT20;
    return textMuted;
  }

  /// Ball event color — for scoring widgets
  static Color ballColor(String event) {
    switch (event.toLowerCase()) {
      case '6':     return six;
      case '4':     return four;
      case 'w':     return wicket;
      case 'wd':
      case 'nb':    return extra;
      case '0':     return dot;
      default:      return textSecondary;
    }
  }

  /// Win/loss/draw result color
  static Color resultColor(String result) {
    final r = result.toLowerCase();
    if (r.contains('won') || r.contains('win')) return win;
    if (r.contains('lost') || r.contains('loss')) return loss;
    if (r.contains('draw') || r.contains('tie')) return draw;
    return textMuted;
  }
}
