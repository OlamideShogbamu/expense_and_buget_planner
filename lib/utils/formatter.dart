import 'package:intl/intl.dart';
import 'constants.dart';

/// Utility class for formatting values (currency, dates, numbers, etc.)
class Formatters {
  // Private constructor to prevent instantiation
  Formatters._();

  // ==================== CURRENCY FORMATTING ====================

  /// Format amount as currency with symbol
  static String formatCurrency(
    double amount, {
    String symbol = AppConstants.currencySymbol,
    int decimalPlaces = 2,
    bool showSymbol = true,
  }) {
    final formatted = amount.abs().toStringAsFixed(decimalPlaces);
    final parts = formatted.split('.');
    final integerPart = _addThousandsSeparator(parts[0]);
    final result = decimalPlaces > 0 ? '$integerPart.${parts[1]}' : integerPart;

    if (!showSymbol) return result;
    return amount < 0 ? '-$symbol$result' : '$symbol$result';
  }

  /// Format currency with compact notation (1K, 1M, 1B)
  static String formatCurrencyCompact(
    double amount, {
    String symbol = AppConstants.currencySymbol,
  }) {
    if (amount.abs() >= 1000000000) {
      return '${symbol}${(amount / 1000000000).toStringAsFixed(1)}B';
    } else if (amount.abs() >= 1000000) {
      return '${symbol}${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount.abs() >= 1000) {
      return '${symbol}${(amount / 1000).toStringAsFixed(1)}K';
    }
    return formatCurrency(amount, symbol: symbol);
  }

  /// Format currency for input (removes formatting)
  static String formatCurrencyInput(String input) {
    return input.replaceAll(RegExp(r'[^\d.]'), '');
  }

  /// Parse currency string to double
  static double? parseCurrency(String value) {
    final cleaned = value.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(cleaned);
  }

  // ==================== DATE FORMATTING ====================

  /// Format date with default format
  static String formatDate(DateTime date, {String? format}) {
    final formatter = DateFormat(format ?? AppConstants.dateFormat);
    return formatter.format(date);
  }

  /// Format date as "Today", "Yesterday", or actual date
  static String formatDateRelative(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == yesterday) {
      return 'Yesterday';
    } else if (now.difference(dateOnly).inDays < 7) {
      return DateFormat('EEEE').format(date); // Day name
    }
    return formatDate(date);
  }

  /// Format time
  static String formatTime(DateTime time) {
    return DateFormat(AppConstants.timeFormat).format(time);
  }

  /// Format date and time
  static String formatDateTime(DateTime dateTime) {
    return DateFormat(AppConstants.dateTimeFormat).format(dateTime);
  }

  /// Format month and year
  static String formatMonthYear(DateTime date) {
    return DateFormat(AppConstants.monthYearFormat).format(date);
  }

  /// Format as "3 days ago", "2 hours ago", etc.
  static String formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }

  /// Get date range string
  static String formatDateRange(DateTime start, DateTime end) {
    if (start.year == end.year &&
        start.month == end.month &&
        start.day == end.day) {
      return formatDate(start);
    }
    return '${formatDate(start)} - ${formatDate(end)}';
  }

  // ==================== NUMBER FORMATTING ====================

  /// Add thousands separator to number
  static String _addThousandsSeparator(String number) {
    final reversed = number.split('').reversed.join();
    final chunks = <String>[];

    for (int i = 0; i < reversed.length; i += 3) {
      final end = i + 3;
      chunks.add(
        reversed.substring(i, end > reversed.length ? reversed.length : end),
      );
    }

    return chunks.join(',').split('').reversed.join();
  }

  /// Format number with thousands separator
  static String formatNumber(num number, {int decimalPlaces = 0}) {
    return NumberFormat(
      '#,##0${decimalPlaces > 0 ? '.${'0' * decimalPlaces}' : ''}',
    ).format(number);
  }

  /// Format percentage
  static String formatPercentage(
    double value, {
    int decimalPlaces = 1,
    bool showSign = false,
  }) {
    final formatted = value.toStringAsFixed(decimalPlaces);
    if (showSign && value > 0) {
      return '+$formatted%';
    }
    return '$formatted%';
  }

  /// Format file size
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  // ==================== TEXT FORMATTING ====================

  /// Capitalize first letter
  static String capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  /// Capitalize each word
  static String capitalizeWords(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) => capitalizeFirst(word)).join(' ');
  }

  /// Truncate text with ellipsis
  static String truncate(String text, int maxLength, {String suffix = '...'}) {
    if (text.length <= maxLength) return text;
    return text.substring(0, maxLength - suffix.length) + suffix;
  }

  /// Format phone number
  static String formatPhoneNumber(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length == 10) {
      return '(${cleaned.substring(0, 3)}) ${cleaned.substring(3, 6)}-${cleaned.substring(6)}';
    }
    return phone;
  }

  // ==================== SPECIAL FORMATTERS ====================

  /// Format transaction type display
  static String formatTransactionType(String type) {
    return capitalizeFirst(type);
  }

  /// Format budget status
  static String formatBudgetStatus(String status) {
    switch (status.toLowerCase()) {
      case 'safe':
        return 'On Track';
      case 'warning':
        return 'Warning';
      case 'exceeded':
        return 'Exceeded';
      default:
        return capitalizeFirst(status);
    }
  }

  /// Format duration
  static String formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  /// Format list to readable string
  static String formatList(List<String> items, {int maxItems = 3}) {
    if (items.isEmpty) return '';
    if (items.length == 1) return items[0];
    if (items.length <= maxItems) {
      return items.sublist(0, items.length - 1).join(', ') +
          ' and ${items.last}';
    }
    final visible = items.sublist(0, maxItems);
    final remaining = items.length - maxItems;
    return '${visible.join(', ')} and $remaining more';
  }

  /// Format card number (mask)
  static String formatCardNumber(String cardNumber, {bool maskAll = false}) {
    final cleaned = cardNumber.replaceAll(' ', '');
    if (cleaned.length < 4) return cardNumber;

    if (maskAll) {
      return '**** **** **** ${cleaned.substring(cleaned.length - 4)}';
    }

    final chunks = <String>[];
    for (int i = 0; i < cleaned.length; i += 4) {
      final end = i + 4;
      chunks.add(
        cleaned.substring(i, end > cleaned.length ? cleaned.length : end),
      );
    }
    return chunks.join(' ');
  }

  /// Format email (mask for privacy)
  static String formatEmailMasked(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;

    final username = parts[0];
    final domain = parts[1];

    if (username.length <= 3) {
      return '${username[0]}***@$domain';
    }

    return '${username.substring(0, 3)}***@$domain';
  }

  // ==================== VALIDATION FORMATTERS ====================

  /// Remove non-numeric characters
  static String formatNumericOnly(String value) {
    return value.replaceAll(RegExp(r'[^\d]'), '');
  }

  /// Remove non-alphanumeric characters
  static String formatAlphanumericOnly(String value) {
    return value.replaceAll(RegExp(r'[^\w\s]'), '');
  }

  /// Format decimal input (allow only valid decimal numbers)
  static String formatDecimalInput(String value, {int maxDecimals = 2}) {
    // Remove all non-digit and non-decimal point characters
    final cleaned = value.replaceAll(RegExp(r'[^\d.]'), '');

    // Split by decimal point
    final parts = cleaned.split('.');

    if (parts.length > 2) {
      // More than one decimal point, keep only first
      return '${parts[0]}.${parts.sublist(1).join('')}';
    }

    if (parts.length == 2) {
      // Limit decimal places
      return '${parts[0]}.${parts[1].substring(0, parts[1].length > maxDecimals ? maxDecimals : parts[1].length)}';
    }

    return cleaned;
  }
}
