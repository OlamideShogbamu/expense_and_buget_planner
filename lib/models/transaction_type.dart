import 'package:hive/hive.dart';

part 'transaction_type.g.dart';

/// Enum representing the type of transaction
/// Used to distinguish between money coming in (income) and money going out (expense)
@HiveType(typeId: 0)
enum TransactionType {
  /// Represents money received (salary, freelance, investment returns, gifts, etc.)
  @HiveField(0)
  income,

  /// Represents money spent (food, bills, shopping, entertainment, etc.)
  @HiveField(1)
  expense,
}

/// Extension methods for TransactionType enum
extension TransactionTypeExtension on TransactionType {
  /// Returns a human-readable name for the transaction type
  String get displayName {
    switch (this) {
      case TransactionType.income:
        return 'Income';
      case TransactionType.expense:
        return 'Expense';
    }
  }

  /// Returns a short name for the transaction type
  String get shortName {
    switch (this) {
      case TransactionType.income:
        return 'IN';
      case TransactionType.expense:
        return 'OUT';
    }
  }

  /// Returns the appropriate icon for the transaction type
  String get icon {
    switch (this) {
      case TransactionType.income:
        return '↓'; // Money coming in
      case TransactionType.expense:
        return '↑'; // Money going out
    }
  }

  /// Returns the appropriate color code for the transaction type
  /// Income: Green (0xFF7B904B from app theme)
  /// Expense: Red for visibility
  int get color {
    switch (this) {
      case TransactionType.income:
        return 0xFF7B904B; // Theme green color
      case TransactionType.expense:
        return 0xFFFF6B6B; // Red color
    }
  }

  /// Returns whether this is an income type
  bool get isIncome => this == TransactionType.income;

  /// Returns whether this is an expense type
  bool get isExpense => this == TransactionType.expense;

  /// Returns the sign multiplier for calculations
  /// Income: +1 (adds to balance)
  /// Expense: -1 (subtracts from balance)
  int get signMultiplier {
    switch (this) {
      case TransactionType.income:
        return 1;
      case TransactionType.expense:
        return -1;
    }
  }

  /// Returns the opposite transaction type
  /// Useful for transfer corrections or reversals
  TransactionType get opposite {
    switch (this) {
      case TransactionType.income:
        return TransactionType.expense;
      case TransactionType.expense:
        return TransactionType.income;
    }
  }
}

/// Helper class for TransactionType operations
class TransactionTypeHelper {
  /// Get TransactionType from string
  static TransactionType fromString(String type) {
    switch (type.toLowerCase()) {
      case 'income':
        return TransactionType.income;
      case 'expense':
        return TransactionType.expense;
      default:
        return TransactionType.expense; // Default to expense for safety
    }
  }

  /// Get all transaction types as a list
  static List<TransactionType> get all => TransactionType.values;

  /// Get transaction types for dropdown/selection
  static List<Map<String, dynamic>> getSelectionList() {
    return TransactionType.values.map((type) {
      return {
        'type': type,
        'name': type.displayName,
        'icon': type.icon,
        'color': type.color,
      };
    }).toList();
  }

  /// Validate if a string represents a valid transaction type
  static bool isValidType(String? type) {
    if (type == null) return false;
    return type.toLowerCase() == 'income' || type.toLowerCase() == 'expense';
  }

  /// Get appropriate message based on transaction type
  static String getSuccessMessage(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return 'Income added successfully!';
      case TransactionType.expense:
        return 'Expense recorded successfully!';
    }
  }

  /// Get appropriate prompt text based on transaction type
  static String getAmountPrompt(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return 'How much did you receive?';
      case TransactionType.expense:
        return 'How much did you spend?';
    }
  }

  /// Get appropriate category prompt based on transaction type
  static String getCategoryPrompt(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return 'Select income source';
      case TransactionType.expense:
        return 'Select expense category';
    }
  }

  /// Calculate the impact on balance
  /// Positive for income, negative for expense
  static double calculateBalanceImpact(TransactionType type, double amount) {
    return amount * type.signMultiplier;
  }

  /// Determine if cashback should be applied
  /// Cashback is only available for expenses (shopping, dining, travel)
  static bool shouldApplyCashback(TransactionType type) {
    return type == TransactionType.expense;
  }

  /// Get analytics label for charts and reports
  static String getAnalyticsLabel(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return 'Total Income';
      case TransactionType.expense:
        return 'Total Expenses';
    }
  }
}

/// Constants for transaction type filtering
class TransactionTypeFilters {
  static const String all = 'all';
  static const String income = 'income';
  static const String expense = 'expense';

  static List<String> get filterOptions => [all, income, expense];

  static String getDisplayName(String filter) {
    switch (filter) {
      case all:
        return 'All Transactions';
      case income:
        return 'Income Only';
      case expense:
        return 'Expenses Only';
      default:
        return 'All Transactions';
    }
  }

  static TransactionType? getTypeFromFilter(String filter) {
    switch (filter) {
      case income:
        return TransactionType.income;
      case expense:
        return TransactionType.expense;
      default:
        return null; // null means show all
    }
  }
}
