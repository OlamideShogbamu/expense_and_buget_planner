import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../models/budget_model.dart';
import '../models/transaction_type.dart';
import 'data_service.dart';

/// Service for analytics, statistics, and data visualization
/// Supports charts, trends, and insights (Feature #6: Analytics & Visualization)
class AnalyticsService {
  // ==================== SPENDING ANALYTICS ====================

  /// Get spending breakdown by category for a month
  static SpendingBreakdown getSpendingBreakdown(DateTime month) {
    final expenses = DataService.getExpensesByCategory(month);
    final totalExpenses = DataService.getTotalExpenses(month);

    final List<CategorySpending> categorySpending = [];

    expenses.forEach((categoryId, amount) {
      final category = DataService.getCategoryById(categoryId);
      if (category != null) {
        final percentage = totalExpenses > 0
            ? (amount / totalExpenses * 100)
            : 0.0;
        categorySpending.add(
          CategorySpending(
            category: category,
            amount: amount,
            percentage: percentage,
          ),
        );
      }
    });

    // Sort by amount descending
    categorySpending.sort((a, b) => b.amount.compareTo(a.amount));

    return SpendingBreakdown(
      totalExpenses: totalExpenses,
      categorySpending: categorySpending,
      month: month,
    );
  }

  /// Get top spending categories
  static List<CategorySpending> getTopSpendingCategories({
    DateTime? month,
    int limit = 5,
  }) {
    final targetMonth = month ?? DateTime.now();
    final breakdown = getSpendingBreakdown(targetMonth);
    return breakdown.categorySpending.take(limit).toList();
  }

  /// Get spending comparison between two months
  static SpendingComparison compareMonthlySpending(
    DateTime month1,
    DateTime month2,
  ) {
    final expenses1 = DataService.getTotalExpenses(month1);
    final expenses2 = DataService.getTotalExpenses(month2);
    final difference = expenses2 - expenses1;
    final percentageChange = expenses1 > 0
        ? ((difference / expenses1) * 100)
        : 0.0;

    return SpendingComparison(
      month1: month1,
      month2: month2,
      amount1: expenses1,
      amount2: expenses2,
      difference: difference,
      percentageChange: percentageChange,
      isIncreased: difference > 0,
    );
  }

  /// Get average daily spending for a month
  static double getAverageDailySpending(DateTime month) {
    final expenses = DataService.getTotalExpenses(month);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    return expenses / daysInMonth;
  }

  /// Get spending velocity (spending rate per day)
  static SpendingVelocity getSpendingVelocity(DateTime month) {
    final now = DateTime.now();
    final currentDay = month.month == now.month && month.year == now.year
        ? now.day
        : DateTime(month.year, month.month + 1, 0).day;

    final totalExpenses = DataService.getTotalExpenses(month);
    final dailyAverage = totalExpenses / currentDay;

    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final projectedMonthlySpending = dailyAverage * daysInMonth;

    return SpendingVelocity(
      currentSpending: totalExpenses,
      dailyAverage: dailyAverage,
      projectedMonthlySpending: projectedMonthlySpending,
      daysElapsed: currentDay,
      daysRemaining: daysInMonth - currentDay,
    );
  }

  // ==================== INCOME ANALYTICS ====================

  /// Get income breakdown by category for a month
  static IncomeBreakdown getIncomeBreakdown(DateTime month) {
    final transactions = DataService.getTransactionsByMonth(
      month,
    ).where((t) => t.type == TransactionType.income);

    final Map<String, double> incomeByCategory = {};
    for (var transaction in transactions) {
      incomeByCategory[transaction.categoryId] =
          (incomeByCategory[transaction.categoryId] ?? 0) + transaction.amount;
    }

    final totalIncome = DataService.getTotalIncome(month);
    final List<CategoryIncome> categoryIncome = [];

    incomeByCategory.forEach((categoryId, amount) {
      final category = DataService.getCategoryById(categoryId);
      if (category != null) {
        final percentage = totalIncome > 0 ? (amount / totalIncome * 100) : 0.0;
        categoryIncome.add(
          CategoryIncome(
            category: category,
            amount: amount,
            percentage: percentage,
          ),
        );
      }
    });

    // Sort by amount descending
    categoryIncome.sort((a, b) => b.amount.compareTo(a.amount));

    return IncomeBreakdown(
      totalIncome: totalIncome,
      categoryIncome: categoryIncome,
      month: month,
    );
  }

  /// Get income comparison between two months
  static IncomeComparison compareMonthlyIncome(
    DateTime month1,
    DateTime month2,
  ) {
    final income1 = DataService.getTotalIncome(month1);
    final income2 = DataService.getTotalIncome(month2);
    final difference = income2 - income1;
    final percentageChange = income1 > 0 ? ((difference / income1) * 100) : 0.0;

    return IncomeComparison(
      month1: month1,
      month2: month2,
      amount1: income1,
      amount2: income2,
      difference: difference,
      percentageChange: percentageChange,
      isIncreased: difference > 0,
    );
  }

  // ==================== BALANCE ANALYTICS ====================

  /// Get balance trend over time
  static BalanceTrend getBalanceTrend({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final List<DailyBalance> dailyBalances = [];
    final currentDate = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
    );
    final end = DateTime(endDate.year, endDate.month, endDate.day);

    double runningBalance = 0.0;

    while (currentDate.isBefore(end) || currentDate.isAtSameMomentAs(end)) {
      final dayStart = DateTime(
        currentDate.year,
        currentDate.month,
        currentDate.day,
      );
      final dayEnd = DateTime(
        currentDate.year,
        currentDate.month,
        currentDate.day,
        23,
        59,
        59,
      );

      final dayIncome = DataService.calculateTotalIncome(dayStart, dayEnd);
      final dayExpenses = DataService.calculateTotalExpenses(dayStart, dayEnd);
      final dayBalance = dayIncome - dayExpenses;

      runningBalance += dayBalance;

      dailyBalances.add(
        DailyBalance(
          date: DateTime(currentDate.year, currentDate.month, currentDate.day),
          income: dayIncome,
          expenses: dayExpenses,
          netBalance: dayBalance,
          cumulativeBalance: runningBalance,
        ),
      );

      currentDate.add(const Duration(days: 1));
    }

    return BalanceTrend(
      startDate: startDate,
      endDate: endDate,
      dailyBalances: dailyBalances,
    );
  }

  /// Get monthly balance trend for a year
  static List<MonthlyBalance> getMonthlyBalanceTrend(int year) {
    final List<MonthlyBalance> monthlyBalances = [];

    for (int month = 1; month <= 12; month++) {
      final date = DateTime(year, month);
      final income = DataService.getTotalIncome(date);
      final expenses = DataService.getTotalExpenses(date);
      final balance = income - expenses;

      monthlyBalances.add(
        MonthlyBalance(
          month: date,
          income: income,
          expenses: expenses,
          balance: balance,
        ),
      );
    }

    return monthlyBalances;
  }

  // ==================== CASHBACK ANALYTICS ====================

  /// Get cashback summary for a month
  static CashbackSummary getCashbackSummary(DateTime month) {
    final totalCashback = DataService.getTotalCashback(month);
    final cashbackByCategory = DataService.getCashbackByCategory(month);

    final List<CategoryCashback> categoryCashback = [];

    cashbackByCategory.forEach((categoryId, amount) {
      final category = DataService.getCategoryById(categoryId);
      if (category != null) {
        final percentage = totalCashback > 0
            ? (amount / totalCashback * 100)
            : 0.0;
        categoryCashback.add(
          CategoryCashback(
            category: category,
            amount: amount,
            percentage: percentage,
          ),
        );
      }
    });

    // Sort by amount descending
    categoryCashback.sort((a, b) => b.amount.compareTo(a.amount));

    return CashbackSummary(
      totalCashback: totalCashback,
      categoryCashback: categoryCashback,
      month: month,
    );
  }

  /// Get cashback trend over months
  static List<MonthlyCashback> getCashbackTrend(int year) {
    final List<MonthlyCashback> monthlyCashback = [];

    for (int month = 1; month <= 12; month++) {
      final date = DateTime(year, month);
      final cashback = DataService.getTotalCashback(date);

      monthlyCashback.add(MonthlyCashback(month: date, amount: cashback));
    }

    return monthlyCashback;
  }

  /// Get potential cashback (if user used cashback categories)
  static double getPotentialCashback(DateTime month) {
    final transactions = DataService.getTransactionsByMonth(
      month,
    ).where((t) => t.type == TransactionType.expense);

    double potentialCashback = 0.0;

    for (var transaction in transactions) {
      final category = DataService.getCategoryById(transaction.categoryId);
      if (category != null && category.offersCashback) {
        potentialCashback += category.calculateCashback(transaction.amount);
      }
    }

    return potentialCashback;
  }

  // ==================== BUDGET ANALYTICS ====================

  /// Get budget performance for a month
  static BudgetPerformance getBudgetPerformance(DateTime month) {
    final budgets = DataService.getAllBudgetsForMonth(month);
    final spending = DataService.getExpensesByCategory(month);

    return BudgetAnalytics.getPerformanceSummary(budgets, spending);
  }

  /// Get budget utilization details
  static List<BudgetUtilization> getBudgetUtilization(DateTime month) {
    final budgets = DataService.getAllBudgetsForMonth(month);
    final spending = DataService.getExpensesByCategory(month);

    final List<BudgetUtilization> utilization = [];

    for (var budget in budgets) {
      final spent = spending[budget.categoryId] ?? 0.0;
      final category = DataService.getCategoryById(budget.categoryId);

      if (category != null) {
        utilization.add(
          BudgetUtilization(
            budget: budget,
            category: category,
            spent: spent,
            remaining: budget.getRemainingBudget(spent),
            percentage: budget.getSpendingPercentage(spent),
            status: budget.getStatus(spent),
          ),
        );
      }
    }

    // Sort by percentage descending
    utilization.sort((a, b) => b.percentage.compareTo(a.percentage));

    return utilization;
  }

  // ==================== TRANSACTION ANALYTICS ====================

  /// Get transaction statistics for a period
  static TransactionStatistics getTransactionStatistics({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final transactions = DataService.getTransactionsByDateRange(
      startDate,
      endDate,
    );

    final incomeTransactions = transactions
        .where((t) => t.type == TransactionType.income)
        .toList();
    final expenseTransactions = transactions
        .where((t) => t.type == TransactionType.expense)
        .toList();

    final totalIncome = incomeTransactions.fold(
      0.0,
      (sum, t) => sum + t.amount,
    );
    final totalExpenses = expenseTransactions.fold(
      0.0,
      (sum, t) => sum + t.amount,
    );

    final averageIncome = incomeTransactions.isNotEmpty
        ? totalIncome / incomeTransactions.length
        : 0.0;
    final averageExpense = expenseTransactions.isNotEmpty
        ? totalExpenses / expenseTransactions.length
        : 0.0;

    // Find largest transactions
    final largestIncome = incomeTransactions.isNotEmpty
        ? incomeTransactions.reduce((a, b) => a.amount > b.amount ? a : b)
        : null;
    final largestExpense = expenseTransactions.isNotEmpty
        ? expenseTransactions.reduce((a, b) => a.amount > b.amount ? a : b)
        : null;

    return TransactionStatistics(
      totalTransactions: transactions.length,
      incomeCount: incomeTransactions.length,
      expenseCount: expenseTransactions.length,
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
      averageIncome: averageIncome,
      averageExpense: averageExpense,
      largestIncome: largestIncome,
      largestExpense: largestExpense,
      netBalance: totalIncome - totalExpenses,
    );
  }

  /// Get daily transaction frequency
  static Map<int, int> getDailyTransactionFrequency(DateTime month) {
    final transactions = DataService.getTransactionsByMonth(month);
    final Map<int, int> frequency = {};

    for (var transaction in transactions) {
      final day = transaction.date.day;
      frequency[day] = (frequency[day] ?? 0) + 1;
    }

    return frequency;
  }

  // ==================== SAVINGS ANALYTICS ====================

  /// Calculate savings rate for a month
  static SavingsAnalysis getSavingsAnalysis(DateTime month) {
    final income = DataService.getTotalIncome(month);
    final expenses = DataService.getTotalExpenses(month);
    final savings = income - expenses;
    final savingsRate = income > 0 ? (savings / income * 100) : 0.0;

    return SavingsAnalysis(
      income: income,
      expenses: expenses,
      savings: savings,
      savingsRate: savingsRate,
      month: month,
    );
  }

  /// Get savings trend over months
  static List<MonthlySavings> getSavingsTrend(int year) {
    final List<MonthlySavings> monthlySavings = [];

    for (int month = 1; month <= 12; month++) {
      final date = DateTime(year, month);
      final analysis = getSavingsAnalysis(date);

      monthlySavings.add(
        MonthlySavings(
          month: date,
          savings: analysis.savings,
          savingsRate: analysis.savingsRate,
        ),
      );
    }

    return monthlySavings;
  }

  // ==================== INSIGHTS & RECOMMENDATIONS ====================

  /// Get financial insights for current month
  static List<FinancialInsight> getFinancialInsights() {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    final lastMonth = DateTime(now.year, now.month - 1);

    final List<FinancialInsight> insights = [];

    // Spending comparison insight
    final spendingComparison = compareMonthlySpending(lastMonth, currentMonth);
    if (spendingComparison.isIncreased &&
        spendingComparison.percentageChange > 10) {
      insights.add(
        FinancialInsight(
          title: 'Spending Increased',
          description:
              'Your spending is ${spendingComparison.percentageChange.toStringAsFixed(1)}% higher than last month.',
          type: InsightType.warning,
          priority: InsightPriority.high,
        ),
      );
    } else if (!spendingComparison.isIncreased &&
        spendingComparison.percentageChange.abs() > 10) {
      insights.add(
        FinancialInsight(
          title: 'Great Job!',
          description:
              'Your spending decreased by ${spendingComparison.percentageChange.abs().toStringAsFixed(1)}% compared to last month.',
          type: InsightType.positive,
          priority: InsightPriority.medium,
        ),
      );
    }

    // Budget alerts
    final exceededBudgets = DataService.getExceededBudgets(currentMonth);
    if (exceededBudgets.isNotEmpty) {
      insights.add(
        FinancialInsight(
          title: 'Budget Alert',
          description:
              'You have ${exceededBudgets.length} budget(s) that exceeded the limit.',
          type: InsightType.alert,
          priority: InsightPriority.high,
        ),
      );
    }

    // Savings rate insight
    final savingsAnalysis = getSavingsAnalysis(currentMonth);
    if (savingsAnalysis.savingsRate < 10) {
      insights.add(
        FinancialInsight(
          title: 'Low Savings Rate',
          description:
              'Your savings rate is ${savingsAnalysis.savingsRate.toStringAsFixed(1)}%. Try to save at least 20% of your income.',
          type: InsightType.suggestion,
          priority: InsightPriority.medium,
        ),
      );
    } else if (savingsAnalysis.savingsRate > 30) {
      insights.add(
        FinancialInsight(
          title: 'Excellent Savings!',
          description:
              'You\'re saving ${savingsAnalysis.savingsRate.toStringAsFixed(1)}% of your income. Keep it up!',
          type: InsightType.positive,
          priority: InsightPriority.low,
        ),
      );
    }

    // Cashback opportunity
    final actualCashback = DataService.getTotalCashback(currentMonth);
    final potentialCashback = getPotentialCashback(currentMonth);
    final missedCashback = potentialCashback - actualCashback;

    if (missedCashback > 10) {
      insights.add(
        FinancialInsight(
          title: 'Cashback Opportunity',
          description:
              'You could have earned \$${missedCashback.toStringAsFixed(2)} more in cashback this month.',
          type: InsightType.suggestion,
          priority: InsightPriority.low,
        ),
      );
    }

    // Sort by priority
    insights.sort((a, b) => a.priority.index.compareTo(b.priority.index));

    return insights;
  }

  // ==================== FORECASTING ====================

  /// Forecast spending for current month based on velocity
  static SpendingForecast getSpendingForecast() {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    final velocity = getSpendingVelocity(currentMonth);

    return SpendingForecast(
      projectedSpending: velocity.projectedMonthlySpending,
      currentSpending: velocity.currentSpending,
      daysRemaining: velocity.daysRemaining,
      confidence: velocity.daysElapsed > 7 ? 'High' : 'Low',
    );
  }
}

// ==================== DATA CLASSES ====================

/// Spending breakdown by category
class SpendingBreakdown {
  final double totalExpenses;
  final List<CategorySpending> categorySpending;
  final DateTime month;

  SpendingBreakdown({
    required this.totalExpenses,
    required this.categorySpending,
    required this.month,
  });
}

class CategorySpending {
  final CategoryModel category;
  final double amount;
  final double percentage;

  CategorySpending({
    required this.category,
    required this.amount,
    required this.percentage,
  });
}

/// Spending comparison between months
class SpendingComparison {
  final DateTime month1;
  final DateTime month2;
  final double amount1;
  final double amount2;
  final double difference;
  final double percentageChange;
  final bool isIncreased;

  SpendingComparison({
    required this.month1,
    required this.month2,
    required this.amount1,
    required this.amount2,
    required this.difference,
    required this.percentageChange,
    required this.isIncreased,
  });
}

/// Spending velocity
class SpendingVelocity {
  final double currentSpending;
  final double dailyAverage;
  final double projectedMonthlySpending;
  final int daysElapsed;
  final int daysRemaining;

  SpendingVelocity({
    required this.currentSpending,
    required this.dailyAverage,
    required this.projectedMonthlySpending,
    required this.daysElapsed,
    required this.daysRemaining,
  });
}

/// Income breakdown by category
class IncomeBreakdown {
  final double totalIncome;
  final List<CategoryIncome> categoryIncome;
  final DateTime month;

  IncomeBreakdown({
    required this.totalIncome,
    required this.categoryIncome,
    required this.month,
  });
}

class CategoryIncome {
  final CategoryModel category;
  final double amount;
  final double percentage;

  CategoryIncome({
    required this.category,
    required this.amount,
    required this.percentage,
  });
}

/// Income comparison between months
class IncomeComparison {
  final DateTime month1;
  final DateTime month2;
  final double amount1;
  final double amount2;
  final double difference;
  final double percentageChange;
  final bool isIncreased;

  IncomeComparison({
    required this.month1,
    required this.month2,
    required this.amount1,
    required this.amount2,
    required this.difference,
    required this.percentageChange,
    required this.isIncreased,
  });
}

/// Balance trend
class BalanceTrend {
  final DateTime startDate;
  final DateTime endDate;
  final List<DailyBalance> dailyBalances;

  BalanceTrend({
    required this.startDate,
    required this.endDate,
    required this.dailyBalances,
  });
}

class DailyBalance {
  final DateTime date;
  final double income;
  final double expenses;
  final double netBalance;
  final double cumulativeBalance;

  DailyBalance({
    required this.date,
    required this.income,
    required this.expenses,
    required this.netBalance,
    required this.cumulativeBalance,
  });
}

class MonthlyBalance {
  final DateTime month;
  final double income;
  final double expenses;
  final double balance;

  MonthlyBalance({
    required this.month,
    required this.income,
    required this.expenses,
    required this.balance,
  });
}

/// Cashback summary
class CashbackSummary {
  final double totalCashback;
  final List<CategoryCashback> categoryCashback;
  final DateTime month;

  CashbackSummary({
    required this.totalCashback,
    required this.categoryCashback,
    required this.month,
  });
}

class CategoryCashback {
  final CategoryModel category;
  final double amount;
  final double percentage;

  CategoryCashback({
    required this.category,
    required this.amount,
    required this.percentage,
  });
}

class MonthlyCashback {
  final DateTime month;
  final double amount;

  MonthlyCashback({required this.month, required this.amount});
}

/// Budget performance
typedef BudgetPerformance = BudgetPerformanceSummary;

class BudgetUtilization {
  final BudgetModel budget;
  final CategoryModel category;
  final double spent;
  final double remaining;
  final double percentage;
  final BudgetStatus status;

  BudgetUtilization({
    required this.budget,
    required this.category,
    required this.spent,
    required this.remaining,
    required this.percentage,
    required this.status,
  });
}

/// Transaction statistics
class TransactionStatistics {
  final int totalTransactions;
  final int incomeCount;
  final int expenseCount;
  final double totalIncome;
  final double totalExpenses;
  final double averageIncome;
  final double averageExpense;
  final TransactionModel? largestIncome;
  final TransactionModel? largestExpense;
  final double netBalance;

  TransactionStatistics({
    required this.totalTransactions,
    required this.incomeCount,
    required this.expenseCount,
    required this.totalIncome,
    required this.totalExpenses,
    required this.averageIncome,
    required this.averageExpense,
    this.largestIncome,
    this.largestExpense,
    required this.netBalance,
  });
}

/// Savings analysis
class SavingsAnalysis {
  final double income;
  final double expenses;
  final double savings;
  final double savingsRate;
  final DateTime month;

  SavingsAnalysis({
    required this.income,
    required this.expenses,
    required this.savings,
    required this.savingsRate,
    required this.month,
  });
}

class MonthlySavings {
  final DateTime month;
  final double savings;
  final double savingsRate;

  MonthlySavings({
    required this.month,
    required this.savings,
    required this.savingsRate,
  });
}

/// Financial insights
class FinancialInsight {
  final String title;
  final String description;
  final InsightType type;
  final InsightPriority priority;

  FinancialInsight({
    required this.title,
    required this.description,
    required this.type,
    required this.priority,
  });
}

enum InsightType { positive, warning, alert, suggestion, info }

enum InsightPriority { high, medium, low }

/// Spending forecast
class SpendingForecast {
  final double projectedSpending;
  final double currentSpending;
  final int daysRemaining;
  final String confidence;

  SpendingForecast({
    required this.projectedSpending,
    required this.currentSpending,
    required this.daysRemaining,
    required this.confidence,
  });
}
