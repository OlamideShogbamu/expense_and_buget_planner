import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/colors.dart';
import 'formatters.dart';

/// Utility class for helper functions
class Helpers {
  // Private constructor to prevent instantiation
  Helpers._();

  // ==================== UI HELPERS ====================

  /// Show snackbar with custom styling
  static void showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        action: action,
      ),
    );
  }

  /// Show loading dialog
  static void showLoadingDialog(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
                if (message != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    message,
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Hide loading dialog
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  /// Show confirmation dialog
  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDangerous = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: isDangerous
                ? TextButton.styleFrom(foregroundColor: AppColors.error)
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Show bottom sheet
  static Future<T?> showCustomBottomSheet<T>(
    BuildContext context, {
    required Widget child,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: AppColors.surface,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => child,
    );
  }

  // ==================== DATE HELPERS ====================

  /// Get first day of month
  static DateTime getFirstDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// Get last day of month
  static DateTime getLastDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }

  /// Get days in month
  static int getDaysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Check if date is this week
  static bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return date.isAfter(weekAgo) && date.isBefore(now.add(const Duration(days: 1)));
  }

  /// Check if date is this month
  static bool isThisMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  /// Get month difference between two dates
  static int getMonthDifference(DateTime start, DateTime end) {
    return (end.year - start.year) * 12 + end.month - start.month;
  }

  // ==================== NUMBER HELPERS ====================

  /// Calculate percentage
  static double calculatePercentage(double value, double total) {
    if (total == 0) return 0;
    return (value / total * 100).clamp(0, 100);
  }

  /// Calculate percentage change
  static double calculatePercentageChange(double oldValue, double newValue) {
    if (oldValue == 0) return newValue > 0 ? 100.0 : 0.0;
    return ((newValue - oldValue) / oldValue * 100);
  }

  /// Round to decimal places
  static double roundToDecimal(double value, int places) {
    final mod = pow(10.0, places);
    return ((value * mod).round() / mod).toDouble();
  }

  /// Generate random number in range
  static int randomInRange(int min, int max) {
    return min + (max - min) * (DateTime.now().millisecond % 100) ~/ 100;
  }

  // ==================== STRING HELPERS ====================

  /// Generate initials from name
  static String getInitials(String name, {int maxLength = 2}) {
    final words = name.trim().split(' ');
    if (words.isEmpty) return '';
    
    if (words.length == 1) {
      return words[0].substring(0, min(maxLength, words[0].length)).toUpperCase();
    }
    
    return words
        .take(maxLength)
        .map((word) => word.isNotEmpty ? word[0] : '')
        .join()
        .toUpperCase();
  }

  /// Generate random string
  static String generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(
      length,
      (index) => chars[DateTime.now().microsecond % chars.length],
    ).join();
  }

  // ==================== COLOR HELPERS ====================

  /// Get color from hex string
  static Color colorFromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Convert color to hex string
  static String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  /// Lighten color
  static Color lightenColor(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  /// Darken color
  static Color darkenColor(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  // ==================== CLIPBOARD HELPERS ====================

  /// Copy text to clipboard
  static Future<void> copyToClipboard(String text, BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      showSnackBar(context, 'Copied to clipboard');
    }
  }

  /// Paste from clipboard
  static Future<String?> pasteFromClipboard() async {
    final data = await Clipboard.getData('text/plain');
    return data?.text;
  }

  // ==================== HAPTIC FEEDBACK ====================

  /// Light impact haptic feedback
  static void lightHaptic() {
    HapticFeedback.lightImpact();
  }

  /// Medium impact haptic feedback
  static void mediumHaptic() {
    HapticFeedback.mediumImpact();
  }

  /// Heavy impact haptic feedback
  static void heavyHaptic() {
    HapticFeedback.heavyImpact();
  }

  /// Selection haptic feedback
  static void selectionHaptic() {
    HapticFeedback.selectionClick();
  }

  // ==================== DEBOUNCING ====================

  /// Debounce function calls
  static Function debounce(Function func, Duration delay) {
    Timer? timer;
    return () {
      timer?.cancel();
      timer = Timer(delay, () => func());
    };
  }

  /// Throttle function calls
  static Function throttle(Function func, Duration delay) {
    Timer? timer;
    bool canExecute = true;
    return () {
      if (canExecute) {
        func();
        canExecute = false;
        timer = Timer(delay, () => canExecute = true);
      }
    };
  }

  // ==================== LIST HELPERS ====================

  /// Chunk list into smaller lists
  static List<List<T>> chunkList<T>(List<T> list, int chunkSize) {
    final chunks = <List<T>>[];
    for (var i = 0; i < list.length; i += chunkSize) {
      final end = (i + chunkSize < list.length) ? i + chunkSize : list.length;
      chunks.add(list.sublist(i, end));
    }
    return chunks;
  }

  /// Get unique items from list
  static List<T> getUniqueList<T>(List<T> list) {
    return list.toSet().toList();
  }

  /// Sort map by value
  static Map<K, V> sortMapByValue<K, V>(
    Map<K, V> map, {
    bool ascending = false,
  }) {
    final sortedEntries = map.entries.toList()
      ..sort((a, b) {
        if (ascending) {
          return Comparable.compare(a.value as Comparable, b.value as Comparable);
        }
        return Comparable.compare(b.value as Comparable, a.value as Comparable);
      });
    return Map.fromEntries(sortedEntries);
  }

  // ==================== NAVIGATION HELPERS ====================

  /// Navigate and remove all previous routes
  static Future<void> navigateAndRemoveUntil(
    BuildContext context,
    Widget page,
  ) {
    return Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => page),
      (route) => false,
    );
  }

  /// Navigate with fade transition
  static Future<T?> navigateWithFade<T>(BuildContext context, Widget page) {
    return Navigator.of(context).push<T>(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  // ==================== KEYBOARD HELPERS ====================

  /// Hide keyboard
  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  /// Show keyboard
  static void showKeyboard(BuildContext context, FocusNode focusNode) {
    FocusScope.of(context).requestFocus(focusNode);
  }

  // ==================== DEVICE INFO HELPERS ====================

  /// Check if device is in dark mode
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  /// Get screen size
  static Size getScreenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  /// Check if screen is small
  static bool isSmallScreen(BuildContext context) {
    return getScreenSize(context).width < 600;
  }

  /// Get safe area padding
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  // ==================== MATH HELPERS ====================

  /// Get minimum value
  static T min<T extends Comparable>(T a, T b) {
    return a.compareTo(b) < 0 ? a : b;
  }

  /// Get maximum value
  static T max<T extends Comparable>(T a, T b) {
    return a.compareTo(b) > 0 ? a : b;
  }

  /// Clamp value between min and max
  static T clamp<T extends Comparable>(T value, T minValue, T maxValue) {
    if (value.compareTo(minValue) < 0) return minValue;
    if (value.compareTo(maxValue) > 0) return maxValue;
    return value;
  }

  // ==================== DELAY HELPERS ====================

  /// Delay execution
  static Future<void> delay(Duration duration) {
    return Future.delayed(duration);
  }

  /// Execute after delay
  static Future<T> delayedExecution<T>(
    Duration duration,
    Future<T> Function() callback,
  ) async {
    await delay(duration);
    return callback();
  }
}

/// Math helper imports
import 'dart:math' show pow;
import 'dart:async';