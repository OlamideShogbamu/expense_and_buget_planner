import 'package:flutter/material.dart';

/// App color palette based on the design requirements
/// Primary: #58641D (dark olive green)
/// Secondary: #7B904B (lighter olive green)
class AppColors {
  AppColors._();

  // ==================== PRIMARY COLORS ====================
  
  /// Primary color - Dark olive green (#58641D)
  static const Color primary = Color(0xFF58641D);
  
  /// Secondary color - Light olive green (#7B904B)
  static const Color secondary = Color(0xFF7B904B);
  
  /// Primary color variants
  static const Color primaryLight = Color(0xFF6B7B24);
  static const Color primaryDark = Color(0xFF454D16);
  
  /// Secondary color variants
  static const Color secondaryLight = Color(0xFF8FA055);
  static const Color secondaryDark = Color(0xFF657A3C);

  // ==================== BACKGROUND COLORS ====================
  
  /// Main background color - Dark (#1A1A1A)
  static const Color background = Color(0xFF1A1A1A);
  
  /// Surface color - Cards, containers (#2A2A2A)
  static const Color surface = Color(0xFF2A2A2A);
  
  /// Surface light - Slightly lighter surface (#363636)
  static const Color surfaceLight = Color(0xFF363636);
  
  /// Surface variant - Input fields (#2F2F2F)
  static const Color surfaceVariant = Color(0xFF2F2F2F);

  // ==================== TEXT COLORS ====================
  
  /// Primary text color - White
  static const Color textPrimary = Color(0xFFFFFFFF);
  
  /// Secondary text color - Light gray
  static const Color textSecondary = Color(0xFFB0B0B0);
  
  /// Tertiary text color - Medium gray
  static const Color textTertiary = Color(0xFF808080);
  
  /// Disabled text color - Dark gray
  static const Color textDisabled = Color(0xFF4D4D4D);

  // ==================== FUNCTIONAL COLORS ====================
  
  /// Success color - Green
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFF81C784);
  static const Color successDark = Color(0xFF388E3C);
  
  /// Error color - Red
  static const Color error = Color(0xFFFF6B6B);
  static const Color errorLight = Color(0xFFFF8A80);
  static const Color errorDark = Color(0xFFF44336);
  
  /// Warning color - Yellow/Orange
  static const Color warning = Color(0xFFFFD93D);
  static const Color warningLight = Color(0xFFFFE57F);
  static const Color warningDark = Color(0xFFFFC107);
  
  /// Info color - Blue
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFF64B5F6);
  static const Color infoDark = Color(0xFF1976D2);

  // ==================== INCOME & EXPENSE COLORS ====================
  
  /// Income color - Matches secondary color
  static const Color income = secondary;
  static const Color incomeLight = secondaryLight;
  
  /// Expense color - Red
  static const Color expense = error;
  static const Color expenseLight = errorLight;
  
  /// Balance positive - Green
  static const Color balancePositive = success;
  
  /// Balance negative - Red
  static const Color balanceNegative = error;

  // ==================== BUDGET STATUS COLORS ====================
  
  /// Budget safe - Green
  static const Color budgetSafe = success;
  
  /// Budget warning - Yellow
  static const Color budgetWarning = warning;
  
  /// Budget exceeded - Red
  static const Color budgetExceeded = error;

  // ==================== CATEGORY COLORS ====================
  
  /// Predefined category colors for variety
  static const Color categoryRed = Color(0xFFFF6B6B);
  static const Color categoryOrange = Color(0xFFFF9A3C);
  static const Color categoryYellow = Color(0xFFFFD93D);
  static const Color categoryGreen = Color(0xFF6BCB77);
  static const Color categoryTeal = Color(0xFF4ECDC4);
  static const Color categoryBlue = Color(0xFF4D96FF);
  static const Color categoryPurple = Color(0xFFAA96DA);
  static const Color categoryPink = Color(0xFFFCBAD3);
  static const Color categoryGray = Color(0xFF98C1D9);
  
  /// Get category colors list
  static List<Color> get categoryColors => [
    categoryRed,
    categoryOrange,
    categoryYellow,
    categoryGreen,
    categoryTeal,
    categoryBlue,
    categoryPurple,
    categoryPink,
    primary,
    secondary,
  ];

  // ==================== CHART COLORS ====================
  
  /// Chart colors for pie charts and bar charts
  static const List<Color> chartColors = [
    Color(0xFFFF6B6B), // Red
    Color(0xFF4ECDC4), // Teal
    Color(0xFF95E1D3), // Mint
    Color(0xFFF38181), // Pink
    Color(0xFFAA96DA), // Purple
    Color(0xFFFCBAD3), // Light pink
    Color(0xFFFFD93D), // Yellow
    Color(0xFF6BCB77), // Green
    Color(0xFF4D96FF), // Blue
    Color(0xFFFF9A3C), // Orange
  ];

  // ==================== CASHBACK COLORS ====================
  
  /// Cashback earned color - Gold
  static const Color cashback = Color(0xFFFFD700);
  static const Color cashbackLight = Color(0xFFFFE55C);
  static const Color cashbackDark = Color(0xFFFFC107);

  // ==================== NEUTRAL COLORS ====================
  
  /// White
  static const Color white = Color(0xFFFFFFFF);
  
  /// Black
  static const Color black = Color(0xFF000000);
  
  /// Gray scale
  static const Color gray50 = Color(0xFFF9F9F9);
  static const Color gray100 = Color(0xFFF0F0F0);
  static const Color gray200 = Color(0xFFE0E0E0);
  static const Color gray300 = Color(0xFFB0B0B0);
  static const Color gray400 = Color(0xFF808080);
  static const Color gray500 = Color(0xFF5A5A5A);
  static const Color gray600 = Color(0xFF3D3D3D);
  static const Color gray700 = Color(0xFF2A2A2A);
  static const Color gray800 = Color(0xFF1A1A1A);
  static const Color gray900 = Color(0xFF0D0D0D);

  // ==================== BORDER & DIVIDER ====================
  
  /// Border color
  static const Color border = Color(0xFF3D3D3D);
  
  /// Divider color
  static const Color divider = Color(0xFF2A2A2A);

  // ==================== OVERLAY COLORS ====================
  
  /// Shadow color
  static const Color shadow = Color(0x40000000);
  
  /// Overlay dark
  static const Color overlayDark = Color(0x80000000);
  
  /// Overlay light
  static const Color overlayLight = Color(0x40FFFFFF);

  // ==================== GRADIENTS ====================
  
  /// Primary gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Success gradient
  static const LinearGradient successGradient = LinearGradient(
    colors: [successDark, successLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Error gradient
  static const LinearGradient errorGradient = LinearGradient(
    colors: [errorDark, errorLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ==================== HELPER METHODS ====================
  
  /// Get color with opacity
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
  
  /// Get transaction type color
  static Color getTransactionTypeColor(bool isIncome) {
    return isIncome ? income : expense;
  }
  
  /// Get budget status color
  static Color getBudgetStatusColor(double percentage) {
    if (percentage < 80) return budgetSafe;
    if (percentage < 100) return budgetWarning;
    return budgetExceeded;
  }
  
  /// Get balance color
  static Color getBalanceColor(double balance) {
    return balance >= 0 ? balancePositive : balanceNegative;
  }
  
  /// Get chart color by index
  static Color getChartColor(int index) {
    return chartColors[index % chartColors.length];
  }
  
  /// Get random category color
  static Color getRandomCategoryColor() {
    return categoryColors[(DateTime.now().millisecondsSinceEpoch) % categoryColors.length];
  }
  
  /// Convert hex string to Color
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
  
  /// Convert Color to hex string
  static String toHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }
}

/// Material color swatch for primary color
class AppMaterialColor {
  static const MaterialColor primary = MaterialColor(
    0xFF58641D,
    <int, Color>{
      50: Color(0xFFEBEDE6),
      100: Color(0xFFCDD2C1),
      200: Color(0xFFACB498),
      300: Color(0xFF8B966F),
      400: Color(0xFF727F50),
      500: Color(0xFF58641D), // Base color
      600: Color(0xFF505C1A),
      700: Color(0xFF475216),
      800: Color(0xFF3D4812),
      900: Color(0xFF2D360A),
    },
  );
  
  static const MaterialColor secondary = MaterialColor(
    0xFF7B904B,
    <int, Color>{
      50: Color(0xFFF0F3EA),
      100: Color(0xFFD9E1CB),
      200: Color(0xFFC0CDA8),
      300: Color(0xFFA6B985),
      400: Color(0xFF93AA6A),
      500: Color(0xFF7B904B), // Base color
      600: Color(0xFF738844),
      700: Color(0xFF687D3B),
      800: Color(0xFF5E7333),
      900: Color(0xFF4B6123),
    },
  );
}

/// Color extensions for easier usage
extension ColorExtension on Color {
  /// Lighten color
  Color lighten([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
  }

  /// Darken color
  Color darken([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }
}