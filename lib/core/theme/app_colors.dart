import 'package:flutter/material.dart';

class AppColors {
  // Primary Reference Color Palette
  static const Color navyPrimary = Color(0xFF0B2D4D);     // PRIMARY DARK NAVY #0B2D4D
  static const Color navyHeader = Color(0xFF12385C);      // DARK NAVY HEADER #12385C
  static const Color navySidebar = Color(0xFF082945);     // SIDEBAR #082945
  static const Color navySecondary = Color(0xFF163D63);   // SECONDARY NAVY #163D63
  static const Color tealAccent = Color(0xFF20BFAE);      // TEAL ACCENT #20BFAE
  static const Color greenSuccess = Color(0xFF3AA66F);    // GREEN SUCCESS #3AA66F
  static const Color bgMain = Color(0xFFEEF3F7);          // LIGHT BACKGROUND #EEF3F7
  static const Color bgCard = Color(0xFFF8FAFC);          // CARD BACKGROUND #F8FAFC
  static const Color borderCard = Color(0xFFC9D5E0);      // BORDER #C9D5E0
  static const Color textPrimary = Color(0xFF1D3348);     // PRIMARY TEXT #1D3348
  static const Color textSecondary = Color(0xFF617284);   // SECONDARY TEXT #617284
  static const Color white = Color(0xFFFFFFFF);           // WHITE #FFFFFF

  // Compatibility aliases
  static const Color primary = navyPrimary;
  static const Color primaryHover = navySecondary;
  static const Color primaryGlow = Color(0x3320BFAE);
  static const Color accentCyan = tealAccent;

  // Backgrounds
  static const Color bgDark = navyPrimary;
  static const Color bgCardElevated = Color(0xFFFFFFFF);
  static const Color bgCardHover = Color(0xFFEDF2F7);
  static const Color bgInput = Color(0xFFFFFFFF);
  static const Color cellInactive = Color(0xFFEEF3F7);     // Incomplete habit cell #EEF3F7

  // Sidebar Specific
  static const Color sidebarBg = navySidebar;
  static const Color sidebarSelected = tealAccent;
  static const Color sidebarText = Color(0xFFFFFFFF);
  static const Color sidebarMutedText = Color(0xFF8CA3BA);
  static const Color sidebarBorder = Color(0xFF163D63);

  // Borders
  static const Color borderSubtle = Color(0xFFE2E8F0);
  static const Color borderActive = tealAccent;

  // Text
  static const Color textMuted = Color(0xFF8CA3BA);
  static const Color textOnNavy = Color(0xFFFFFFFF);

  // Status & Priority
  static const Color priorityHigh = Color(0xFFE11D48);
  static const Color priorityMedium = Color(0xFFD97706);
  static const Color priorityLow = Color(0xFF2563EB);

  static const Color success = greenSuccess;
  static const Color warning = Color(0xFFD97706);
  static const Color danger = Color(0xFFE11D48);

  // Category Colors
  static const Color catCoding = Color(0xFF0B2D4D);
  static const Color catWork = Color(0xFF20BFAE);
  static const Color catStudy = Color(0xFF3AA66F);
  static const Color catBrowser = Color(0xFFD97706);
  static const Color catEntertainment = Color(0xFF0284C7);
  static const Color catOther = Color(0xFF475569);

  static Color getCategoryColor(String? category) {
    if (category == null) return catOther;
    switch (category.toLowerCase()) {
      case 'coding':
      case 'development':
        return catCoding;
      case 'work':
      case 'business':
        return catWork;
      case 'study':
      case 'learning':
      case 'reading':
        return catStudy;
      case 'browser':
      case 'research':
        return catBrowser;
      case 'entertainment':
      case 'fun':
        return catEntertainment;
      default:
        return catOther;
    }
  }

  static Color getPriorityColor(String? priority) {
    if (priority == null) return priorityMedium;
    switch (priority.toLowerCase()) {
      case 'high':
        return priorityHigh;
      case 'medium':
        return priorityMedium;
      case 'low':
        return priorityLow;
      default:
        return priorityMedium;
    }
  }
}
