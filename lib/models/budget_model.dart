import 'package:hive/hive.dart';

part 'budget_model.g.dart';

/// Model representing a budget for expense tracking and planning
/// Budgets help users control spending by setting limits per category per month
@HiveType(typeId: 3)
class BudgetModel extends HiveObject {
  /// Unique identifier for the budget
  @HiveField(0)
  final String id;

  /// Category ID this budget applies to
  /// References CategoryModel.id
  @HiveField(1)
  final String categoryId;

  /// Budget amount (monthly limit)
  @HiveField(2)
  final double amount;

  /// Month this budget applies to (stored as first day of month)
  @HiveField(3)
  final DateTime month;

  /// Optional goal/target amount (for savings tracking)
  @HiveField(4)
  final double? targetAmount;

  /// Alert threshold percentage (e.g., 0.80 for 80%)
  /// User gets notified when spending reaches this threshold
  @HiveField(5)
  final double alertThreshold;

  /// Whether alerts are enabled for this budget
  @HiveField(6)
  final bool alertsEnabled;

  /// Whether this budget rolls over unused amount to next month
  @HiveField(7)
  final bool rolloverEnabled;

  /// Carried over amount from previous month
  @HiveField(8)
  final double carriedOverAmount;

  /// Notes about this budget
  @HiveField(9)
  final String? note;

  /// User ID who created this budget
  @HiveField(10)
  final String? userId;

  /// Whether this budget is active
  @HiveField(11)
  final bool isActive;

  /// Timestamp when the budget was created
  @HiveField(12)
  final DateTime createdAt;

  /// Timestamp when the budget was last updated
  @HiveField(13)
  final DateTime updatedAt;

  BudgetModel({
    required this.id,
    required this.categoryId,
    required this.amount,
    required this.month,
    this.targetAmount,
    this.alertThreshold = 0.80, // Default to 80%
    this.alertsEnabled = true,
    this.rolloverEnabled = false,
    this.carriedOverAmount = 0.0,
    this.note,
    this.userId,
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /// Create a copy of this budget with updated fields
  BudgetModel copyWith({
    String? id,
    String? categoryId,
    double? amount,
    DateTime? month,
    double? targetAmount,
    double? alertThreshold,
    bool? alertsEnabled,
    bool? rolloverEnabled,
    double? carriedOverAmount,
    String? note,
    String? userId,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      month: month ?? this.month,
      targetAmount: targetAmount ?? this.targetAmount,
      alertThreshold: alertThreshold ?? this.alertThreshold,
      alertsEnabled: alertsEnabled ?? this.alertsEnabled,
      rolloverEnabled: rolloverEnabled ?? this.rolloverEnabled,
      carriedOverAmount: carriedOverAmount ?? this.carriedOverAmount,
      note: note ?? this.note,
      userId: userId ?? this.userId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Convert budget to JSON format
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'amount': amount,
      'month': month.toIso8601String(),
      'targetAmount': targetAmount,
      'alertThreshold': alertThreshold,
      'alertsEnabled': alertsEnabled,
      'rolloverEnabled': rolloverEnabled,
      'carriedOverAmount': carriedOverAmount,
      'note': note,
      'userId': userId,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create budget from JSON format
  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id'] as String,
      categoryId: json['categoryId'] as String,
      amount: (json['amount'] as num).toDouble(),
      month: DateTime.parse(json['month'] as String),
      targetAmount: json['targetAmount'] != null
          ? (json['targetAmount'] as num).toDouble()
          : null,
      alertThreshold: json['alertThreshold'] != null
          ? (json['alertThreshold'] as num).toDouble()
          : 0.80,
      alertsEnabled: json['alertsEnabled'] as bool? ?? true,
      rolloverEnabled: json['rolloverEnabled'] as bool? ?? false,
      carriedOverAmount: json['carriedOverAmount'] != null
          ? (json['carriedOverAmount'] as num).toDouble()
          : 0.0,
      note: json['note'] as String?,
      userId: json['userId'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Get total available budget (including rollover)
  double get totalAvailableBudget => amount + carriedOverAmount;

  /// Get alert threshold amount
  double get alertThresholdAmount => totalAvailableBudget * alertThreshold;

  /// Calculate spending percentage for given spent amount
  double getSpendingPercentage(double spentAmount) {
    if (totalAvailableBudget == 0) return 0;
    return (spentAmount / totalAvailableBudget * 100).clamp(0, 100);
  }

  /// Calculate remaining budget for given spent amount
  double getRemainingBudget(double spentAmount) {
    return (totalAvailableBudget - spentAmount).clamp(0, totalAvailableBudget);
  }

  /// Calculate overspending amount for given spent amount
  double getOverspendingAmount(double spentAmount) {
    final remaining = totalAvailableBudget - spentAmount;
    return remaining < 0 ? remaining.abs() : 0;
  }

  /// Check if budget is exceeded for given spent amount
  bool isExceeded(double spentAmount) {
    return spentAmount > totalAvailableBudget;
  }

  /// Check if alert threshold is reached for given spent amount
  bool shouldAlert(double spentAmount) {
    if (!alertsEnabled) return false;
    return spentAmount >= alertThresholdAmount && !isExceeded(spentAmount);
  }

  /// Get budget status for given spent amount
  BudgetStatus getStatus(double spentAmount) {
    if (isExceeded(spentAmount)) {
      return BudgetStatus.exceeded;
    } else if (shouldAlert(spentAmount)) {
      return BudgetStatus.warning;
    } else {
      return BudgetStatus.safe;
    }
  }

  /// Get budget health indicator (0-100, higher is better)
  double getHealthScore(double spentAmount) {
    if (totalAvailableBudget == 0) return 0;
    final remainingPercentage =
        getRemainingBudget(spentAmount) / totalAvailableBudget * 100;
    return remainingPercentage.clamp(0, 100);
  }

  /// Format budget amount with currency
  String getFormattedBudget([String currencySymbol = '\$']) {
    return '$currencySymbol${amount.toStringAsFixed(2)}';
  }

  /// Format total available budget with currency
  String getFormattedTotalBudget([String currencySymbol = '\$']) {
    return '$currencySymbol${totalAvailableBudget.toStringAsFixed(2)}';
  }

  /// Format remaining budget with currency
  String getFormattedRemainingBudget(
    double spentAmount, [
    String currencySymbol = '\$',
  ]) {
    final remaining = getRemainingBudget(spentAmount);
    return '$currencySymbol${remaining.toStringAsFixed(2)}';
  }

  /// Check if this is the current month's budget
  bool get isCurrentMonth {
    final now = DateTime.now();
    return month.year == now.year && month.month == now.month;
  }

  /// Check if this budget is for a future month
  bool get isFutureMonth {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    return month.isAfter(currentMonth);
  }

  /// Check if this budget is for a past month
  bool get isPastMonth {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    return month.isBefore(currentMonth);
  }

  /// Check if budget has a target amount set
  bool get hasTargetAmount => targetAmount != null && targetAmount! > 0;

  /// Check if budget has rollover enabled
  bool get hasRollover => rolloverEnabled && carriedOverAmount > 0;

  /// Get month name (e.g., "January 2024")
  String get monthName {
    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${monthNames[month.month - 1]} ${month.year}';
  }

  /// Validate budget data
  bool validate() {
    if (amount <= 0) return false;
    if (categoryId.isEmpty) return false;
    if (alertThreshold < 0 || alertThreshold > 1) return false;
    if (carriedOverAmount < 0) return false;
    if (targetAmount != null && targetAmount! <= 0) return false;
    return true;
  }

  @override
  String toString() {
    return 'Budget(id: $id, category: $categoryId, amount: $amount, month: $monthName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BudgetModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Enum representing budget status
enum BudgetStatus {
  /// Spending is within safe limits (below alert threshold)
  safe,

  /// Spending has reached alert threshold but not exceeded budget
  warning,

  /// Spending has exceeded the budget
  exceeded,
}

/// Extension for BudgetStatus
extension BudgetStatusExtension on BudgetStatus {
  /// Get display name
  String get displayName {
    switch (this) {
      case BudgetStatus.safe:
        return 'On Track';
      case BudgetStatus.warning:
        return 'Warning';
      case BudgetStatus.exceeded:
        return 'Exceeded';
    }
  }

  /// Get color for status
  int get color {
    switch (this) {
      case BudgetStatus.safe:
        return 0xFF7B904B; // Green
      case BudgetStatus.warning:
        return 0xFFFFD93D; // Yellow
      case BudgetStatus.exceeded:
        return 0xFFFF6B6B; // Red
    }
  }

  /// Get icon for status
  String get icon {
    switch (this) {
      case BudgetStatus.safe:
        return '✓';
      case BudgetStatus.warning:
        return '⚠️';
      case BudgetStatus.exceeded:
        return '⚠';
    }
  }

  /// Get message for status
  String getMessage(double spentAmount, double budgetAmount) {
    switch (this) {
      case BudgetStatus.safe:
        final remaining = budgetAmount - spentAmount;
        return 'You have \$${remaining.toStringAsFixed(2)} left';
      case BudgetStatus.warning:
        final remaining = budgetAmount - spentAmount;
        return 'Budget almost reached! \$${remaining.toStringAsFixed(2)} remaining';
      case BudgetStatus.exceeded:
        final overspent = spentAmount - budgetAmount;
        return 'Budget exceeded by \$${overspent.toStringAsFixed(2)}';
    }
  }
}

/// Factory class for creating budgets
class BudgetFactory {
  /// Create a new budget for current month
  static BudgetModel createForCurrentMonth({
    required String categoryId,
    required double amount,
    double? targetAmount,
    double alertThreshold = 0.80,
    bool alertsEnabled = true,
    bool rolloverEnabled = false,
    String? note,
    String? userId,
  }) {
    final now = DateTime.now();
    final month = DateTime(now.year, now.month, 1);

    return BudgetModel(
      id: 'budget_${DateTime.now().millisecondsSinceEpoch}',
      categoryId: categoryId,
      amount: amount,
      month: month,
      targetAmount: targetAmount,
      alertThreshold: alertThreshold,
      alertsEnabled: alertsEnabled,
      rolloverEnabled: rolloverEnabled,
      note: note,
      userId: userId,
    );
  }

  /// Create a new budget for specific month
  static BudgetModel createForMonth({
    required String categoryId,
    required double amount,
    required DateTime month,
    double? targetAmount,
    double alertThreshold = 0.80,
    bool alertsEnabled = true,
    bool rolloverEnabled = false,
    double carriedOverAmount = 0.0,
    String? note,
    String? userId,
  }) {
    // Normalize to first day of month
    final normalizedMonth = DateTime(month.year, month.month, 1);

    return BudgetModel(
      id: 'budget_${DateTime.now().millisecondsSinceEpoch}',
      categoryId: categoryId,
      amount: amount,
      month: normalizedMonth,
      targetAmount: targetAmount,
      alertThreshold: alertThreshold,
      alertsEnabled: alertsEnabled,
      rolloverEnabled: rolloverEnabled,
      carriedOverAmount: carriedOverAmount,
      note: note,
      userId: userId,
    );
  }

  /// Create budget for next month with rollover from current
  static BudgetModel createWithRollover({
    required BudgetModel currentBudget,
    required double unusedAmount,
    double? newAmount,
  }) {
    final nextMonth = DateTime(
      currentBudget.month.year,
      currentBudget.month.month + 1,
      1,
    );

    return BudgetModel(
      id: 'budget_${DateTime.now().millisecondsSinceEpoch}',
      categoryId: currentBudget.categoryId,
      amount: newAmount ?? currentBudget.amount,
      month: nextMonth,
      targetAmount: currentBudget.targetAmount,
      alertThreshold: currentBudget.alertThreshold,
      alertsEnabled: currentBudget.alertsEnabled,
      rolloverEnabled: currentBudget.rolloverEnabled,
      carriedOverAmount: unusedAmount,
      note: currentBudget.note,
      userId: currentBudget.userId,
    );
  }

  /// Create multiple budgets for different categories
  static List<BudgetModel> createMultiple({
    required Map<String, double> categoryBudgets,
    DateTime? month,
    String? userId,
  }) {
    final targetMonth = month ?? DateTime.now();
    final normalizedMonth = DateTime(targetMonth.year, targetMonth.month, 1);

    return categoryBudgets.entries.map((entry) {
      return BudgetModel(
        id: 'budget_${DateTime.now().millisecondsSinceEpoch}_${entry.key}',
        categoryId: entry.key,
        amount: entry.value,
        month: normalizedMonth,
        userId: userId,
      );
    }).toList();
  }

  /// Clone a budget for a different month
  static BudgetModel clone({
    required BudgetModel source,
    required DateTime newMonth,
  }) {
    final normalizedMonth = DateTime(newMonth.year, newMonth.month, 1);

    return BudgetModel(
      id: 'budget_${DateTime.now().millisecondsSinceEpoch}',
      categoryId: source.categoryId,
      amount: source.amount,
      month: normalizedMonth,
      targetAmount: source.targetAmount,
      alertThreshold: source.alertThreshold,
      alertsEnabled: source.alertsEnabled,
      rolloverEnabled: source.rolloverEnabled,
      note: source.note,
      userId: source.userId,
    );
  }
}

/// Budget analytics helper
class BudgetAnalytics {
  /// Calculate total budget across all categories for a month
  static double calculateTotalBudget(List<BudgetModel> budgets) {
    return budgets.fold(
      0.0,
      (sum, budget) => sum + budget.totalAvailableBudget,
    );
  }

  /// Calculate total spent amount across all budgets
  static double calculateTotalSpent(
    List<BudgetModel> budgets,
    Map<String, double> categorySpending,
  ) {
    return budgets.fold(0.0, (sum, budget) {
      final spent = categorySpending[budget.categoryId] ?? 0.0;
      return sum + spent;
    });
  }

  /// Get budgets that need alerts
  static List<BudgetModel> getBudgetsNeedingAlerts(
    List<BudgetModel> budgets,
    Map<String, double> categorySpending,
  ) {
    return budgets.where((budget) {
      final spent = categorySpending[budget.categoryId] ?? 0.0;
      return budget.shouldAlert(spent);
    }).toList();
  }

  /// Get exceeded budgets
  static List<BudgetModel> getExceededBudgets(
    List<BudgetModel> budgets,
    Map<String, double> categorySpending,
  ) {
    return budgets.where((budget) {
      final spent = categorySpending[budget.categoryId] ?? 0.0;
      return budget.isExceeded(spent);
    }).toList();
  }

  /// Get safe budgets
  static List<BudgetModel> getSafeBudgets(
    List<BudgetModel> budgets,
    Map<String, double> categorySpending,
  ) {
    return budgets.where((budget) {
      final spent = categorySpending[budget.categoryId] ?? 0.0;
      return budget.getStatus(spent) == BudgetStatus.safe;
    }).toList();
  }

  /// Calculate average spending percentage across all budgets
  static double calculateAverageSpendingPercentage(
    List<BudgetModel> budgets,
    Map<String, double> categorySpending,
  ) {
    if (budgets.isEmpty) return 0.0;

    final totalPercentage = budgets.fold(0.0, (sum, budget) {
      final spent = categorySpending[budget.categoryId] ?? 0.0;
      return sum + budget.getSpendingPercentage(spent);
    });

    return totalPercentage / budgets.length;
  }

  /// Get budget performance summary
  static BudgetPerformanceSummary getPerformanceSummary(
    List<BudgetModel> budgets,
    Map<String, double> categorySpending,
  ) {
    final totalBudget = calculateTotalBudget(budgets);
    final totalSpent = calculateTotalSpent(budgets, categorySpending);
    final exceededCount = getExceededBudgets(budgets, categorySpending).length;
    final warningCount = getBudgetsNeedingAlerts(
      budgets,
      categorySpending,
    ).length;
    final safeCount = getSafeBudgets(budgets, categorySpending).length;
    final averageSpendingPercentage = calculateAverageSpendingPercentage(
      budgets,
      categorySpending,
    );

    return BudgetPerformanceSummary(
      totalBudget: totalBudget,
      totalSpent: totalSpent,
      totalRemaining: totalBudget - totalSpent,
      exceededCount: exceededCount,
      warningCount: warningCount,
      safeCount: safeCount,
      totalBudgetsCount: budgets.length,
      averageSpendingPercentage: averageSpendingPercentage,
      overallStatus: _determineOverallStatus(
        exceededCount,
        warningCount,
        budgets.length,
      ),
    );
  }

  static BudgetStatus _determineOverallStatus(
    int exceeded,
    int warning,
    int total,
  ) {
    if (exceeded > 0) return BudgetStatus.exceeded;
    if (warning > total / 2) return BudgetStatus.warning;
    return BudgetStatus.safe;
  }
}

/// Budget performance summary data class
class BudgetPerformanceSummary {
  final double totalBudget;
  final double totalSpent;
  final double totalRemaining;
  final int exceededCount;
  final int warningCount;
  final int safeCount;
  final int totalBudgetsCount;
  final double averageSpendingPercentage;
  final BudgetStatus overallStatus;

  BudgetPerformanceSummary({
    required this.totalBudget,
    required this.totalSpent,
    required this.totalRemaining,
    required this.exceededCount,
    required this.warningCount,
    required this.safeCount,
    required this.totalBudgetsCount,
    required this.averageSpendingPercentage,
    required this.overallStatus,
  });

  /// Get formatted total budget
  String getFormattedTotalBudget([String currencySymbol = '\₦']) {
    return '$currencySymbol${totalBudget.toStringAsFixed(2)}';
  }

  /// Get formatted total spent
  String getFormattedTotalSpent([String currencySymbol = '\₦']) {
    return '$currencySymbol${totalSpent.toStringAsFixed(2)}';
  }

  /// Get formatted total remaining
  String getFormattedTotalRemaining([String currencySymbol = '\₦']) {
    return '$currencySymbol${totalRemaining.toStringAsFixed(2)}';
  }

  /// Get overall spending percentage
  double get overallSpendingPercentage {
    if (totalBudget == 0) return 0;
    return (totalSpent / totalBudget * 100).clamp(0, 100);
  }

  /// Check if overall budget is healthy
  bool get isHealthy => overallStatus == BudgetStatus.safe;

  /// Get summary message
  String get summaryMessage {
    if (exceededCount > 0) {
      return '$exceededCount budget(s) exceeded. Review your spending.';
    } else if (warningCount > 0) {
      return '$warningCount budget(s) near limit. Be careful with spending.';
    } else {
      return 'All budgets on track. Great job!';
    }
  }
}
