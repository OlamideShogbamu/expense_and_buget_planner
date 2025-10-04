import 'package:hive/hive.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../models/budget_model.dart';
import '../models/transaction_type.dart';

/// Service for handling all data operations with Hive database
/// This is the core service for income and expense tracking
class DataService {
  // Hive boxes
  static Box<TransactionModel> get _transactionBox =>
      Hive.box<TransactionModel>('transactions');
  static Box<CategoryModel> get _categoryBox =>
      Hive.box<CategoryModel>('categories');
  static Box<BudgetModel> get _budgetBox => Hive.box<BudgetModel>('budgets');
  static Box get _settingsBox => Hive.box('settings');

  // ==================== TRANSACTION OPERATIONS ====================

  /// Add a new transaction (income or expense)
  static Future<void> addTransaction(TransactionModel transaction) async {
    await _transactionBox.add(transaction);
  }

  /// Update an existing transaction
  static Future<void> updateTransaction(
    int index,
    TransactionModel transaction,
  ) async {
    await _transactionBox.putAt(index, transaction);
  }

  /// Delete a transaction
  static Future<void> deleteTransaction(int index) async {
    await _transactionBox.deleteAt(index);
  }

  /// Delete transaction by ID
  static Future<bool> deleteTransactionById(String id) async {
    final index = _transactionBox.values.toList().indexWhere((t) => t.id == id);
    if (index != -1) {
      await _transactionBox.deleteAt(index);
      return true;
    }
    return false;
  }

  /// Get all transactions
  static List<TransactionModel> getAllTransactions() {
    return _transactionBox.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // Sort by date descending
  }

  /// Get transaction by ID
  static TransactionModel? getTransactionById(String id) {
    try {
      return _transactionBox.values.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get transactions by type (income or expense)
  static List<TransactionModel> getTransactionsByType(TransactionType type) {
    return _transactionBox.values.where((t) => t.type == type).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Get income transactions only
  static List<TransactionModel> getIncomeTransactions() {
    return getTransactionsByType(TransactionType.income);
  }

  /// Get expense transactions only
  static List<TransactionModel> getExpenseTransactions() {
    return getTransactionsByType(TransactionType.expense);
  }

  /// Get transactions by date range
  static List<TransactionModel> getTransactionsByDateRange(
    DateTime start,
    DateTime end,
  ) {
    return _transactionBox.values.where((t) {
      return t.date.isAfter(start.subtract(const Duration(days: 1))) &&
          t.date.isBefore(end.add(const Duration(days: 1)));
    }).toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Get transactions for a specific month
  static List<TransactionModel> getTransactionsByMonth(DateTime month) {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
    return getTransactionsByDateRange(start, end);
  }

  /// Get transactions for current month
  static List<TransactionModel> getCurrentMonthTransactions() {
    return getTransactionsByMonth(DateTime.now());
  }

  /// Get transactions by category
  static List<TransactionModel> getTransactionsByCategory(String categoryId) {
    return _transactionBox.values
        .where((t) => t.categoryId == categoryId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Search transactions by keyword
  static List<TransactionModel> searchTransactions(String query) {
    if (query.isEmpty) return getAllTransactions();

    return _transactionBox.values.where((t) => t.matchesSearch(query)).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Get recent transactions (last N transactions)
  static List<TransactionModel> getRecentTransactions({int limit = 10}) {
    final transactions = getAllTransactions();
    return transactions.take(limit).toList();
  }

  /// Get today's transactions
  static List<TransactionModel> getTodayTransactions() {
    return _transactionBox.values.where((t) => t.isToday).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Get this week's transactions
  static List<TransactionModel> getThisWeekTransactions() {
    return _transactionBox.values.where((t) => t.isThisWeek).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // ==================== INCOME & EXPENSE CALCULATIONS ====================

  /// Calculate total income for a given date range
  static double calculateTotalIncome(DateTime start, DateTime end) {
    return getTransactionsByDateRange(start, end)
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Calculate total expenses for a given date range
  static double calculateTotalExpenses(DateTime start, DateTime end) {
    return getTransactionsByDateRange(start, end)
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Calculate total income for a month
  static double getTotalIncome(DateTime month) {
    return getTransactionsByMonth(month)
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Calculate total expenses for a month
  static double getTotalExpenses(DateTime month) {
    return getTransactionsByMonth(month)
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Calculate net balance (income - expenses) for a month
  static double getNetBalance(DateTime month) {
    return getTotalIncome(month) - getTotalExpenses(month);
  }

  /// Calculate total balance (all time income - all time expenses)
  static double getTotalBalance() {
    return _transactionBox.values.fold(0.0, (sum, t) => sum + t.balanceImpact);
  }

  /// Calculate current month's balance
  static double getCurrentMonthBalance() {
    return getNetBalance(DateTime.now());
  }

  // ==================== CATEGORY OPERATIONS ====================

  /// Add a new category
  static Future<void> addCategory(CategoryModel category) async {
    await _categoryBox.add(category);
  }

  /// Update a category
  static Future<void> updateCategory(int index, CategoryModel category) async {
    await _categoryBox.putAt(index, category);
  }

  /// Delete a category
  static Future<void> deleteCategory(int index) async {
    await _categoryBox.deleteAt(index);
  }

  /// Delete category by ID
  static Future<bool> deleteCategoryById(String id) async {
    final index = _categoryBox.values.toList().indexWhere((c) => c.id == id);
    if (index != -1) {
      await _categoryBox.deleteAt(index);
      return true;
    }
    return false;
  }

  /// Get all categories
  static List<CategoryModel> getAllCategories() {
    return _categoryBox.values.where((c) => c.isActive).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  /// Get category by ID
  static CategoryModel? getCategoryById(String id) {
    try {
      return _categoryBox.values.firstWhere((c) => c.id == id);
    } catch (e) {
      return CategoryModel(
        id: '',
        name: 'Unknown',
        icon: '❓',
        color: 0xFF666666,
      );
    }
  }

  /// Get income categories only
  static List<CategoryModel> getIncomeCategories() {
    return _categoryBox.values
        .where((c) => c.canBeUsedForIncome && c.isActive)
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  /// Get expense categories only
  static List<CategoryModel> getExpenseCategories() {
    return _categoryBox.values
        .where((c) => c.canBeUsedForExpense && c.isActive)
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  /// Get cashback eligible categories
  static List<CategoryModel> getCashbackCategories() {
    return _categoryBox.values
        .where((c) => c.isCashbackEligible && c.isActive)
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  /// Search categories by name
  static List<CategoryModel> searchCategories(String query) {
    if (query.isEmpty) return getAllCategories();

    return _categoryBox.values
        .where((c) => c.matchesSearch(query) && c.isActive)
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  // ==================== EXPENSE BY CATEGORY ====================

  /// Get total expenses grouped by category for a month
  static Map<String, double> getExpensesByCategory(DateTime month) {
    final transactions = getTransactionsByMonth(month);
    final expenses = transactions.where(
      (t) => t.type == TransactionType.expense,
    );

    final Map<String, double> result = {};
    for (var transaction in expenses) {
      result[transaction.categoryId] =
          (result[transaction.categoryId] ?? 0) + transaction.amount;
    }
    return result;
  }

  /// Get expense percentage by category
  static Map<String, double> getExpensePercentageByCategory(DateTime month) {
    final expensesByCategory = getExpensesByCategory(month);
    final totalExpenses = getTotalExpenses(month);

    if (totalExpenses == 0) return {};

    final Map<String, double> result = {};
    expensesByCategory.forEach((categoryId, amount) {
      result[categoryId] = (amount / totalExpenses * 100);
    });
    return result;
  }

  /// Get top spending categories for a month
  static List<MapEntry<String, double>> getTopSpendingCategories({
    DateTime? month,
    int limit = 5,
  }) {
    final targetMonth = month ?? DateTime.now();
    final expensesByCategory = getExpensesByCategory(targetMonth);

    final sorted = expensesByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(limit).toList();
  }

  // ==================== BUDGET OPERATIONS ====================

  /// Add or update a budget
  static Future<void> setBudget(BudgetModel budget) async {
    // Remove existing budget for this category and month
    final existingIndex = _budgetBox.values.toList().indexWhere(
      (b) =>
          b.categoryId == budget.categoryId &&
          b.month.year == budget.month.year &&
          b.month.month == budget.month.month,
    );

    if (existingIndex != -1) {
      await _budgetBox.putAt(existingIndex, budget);
    } else {
      await _budgetBox.add(budget);
    }
  }

  /// Delete a budget
  static Future<void> deleteBudget(int index) async {
    await _budgetBox.deleteAt(index);
  }

  /// Delete budget by ID
  static Future<bool> deleteBudgetById(String id) async {
    final index = _budgetBox.values.toList().indexWhere((b) => b.id == id);
    if (index != -1) {
      await _budgetBox.deleteAt(index);
      return true;
    }
    return false;
  }

  /// Get budget for a specific category and month
  static BudgetModel? getBudgetForCategory(String categoryId, DateTime month) {
    try {
      return _budgetBox.values.firstWhere(
        (b) =>
            b.categoryId == categoryId &&
            b.month.year == month.year &&
            b.month.month == month.month &&
            b.isActive,
      );
    } catch (e) {
      return null;
    }
  }

  /// Get all budgets for a specific month
  static List<BudgetModel> getAllBudgetsForMonth(DateTime month) {
    return _budgetBox.values
        .where(
          (b) =>
              b.month.year == month.year &&
              b.month.month == month.month &&
              b.isActive,
        )
        .toList()
      ..sort((a, b) {
        final catA = getCategoryById(a.categoryId);
        final catB = getCategoryById(b.categoryId);
        return (catA?.sortOrder ?? 0).compareTo(catB?.sortOrder ?? 0);
      });
  }

  /// Get current month's budgets
  static List<BudgetModel> getCurrentMonthBudgets() {
    return getAllBudgetsForMonth(DateTime.now());
  }

  /// Get all budgets
  static List<BudgetModel> getAllBudgets() {
    return _budgetBox.values.where((b) => b.isActive).toList()
      ..sort((a, b) => b.month.compareTo(a.month));
  }

  // ==================== BUDGET ANALYTICS ====================

  /// Get budget with spending information
  static Map<String, dynamic> getBudgetWithSpending(BudgetModel budget) {
    final spent = getExpensesByCategory(budget.month)[budget.categoryId] ?? 0.0;
    final category = getCategoryById(budget.categoryId);

    return {
      'budget': budget,
      'spent': spent,
      'remaining': budget.getRemainingBudget(spent),
      'percentage': budget.getSpendingPercentage(spent),
      'status': budget.getStatus(spent),
      'category': category,
    };
  }

  /// Get all budgets with spending information for a month
  static List<Map<String, dynamic>> getBudgetsWithSpending(DateTime month) {
    final budgets = getAllBudgetsForMonth(month);
    return budgets.map((budget) => getBudgetWithSpending(budget)).toList();
  }

  /// Check if any budgets need alerts
  static List<BudgetModel> getBudgetsNeedingAlerts(DateTime month) {
    final budgets = getAllBudgetsForMonth(month);
    final spending = getExpensesByCategory(month);

    return BudgetAnalytics.getBudgetsNeedingAlerts(budgets, spending);
  }

  /// Get exceeded budgets
  static List<BudgetModel> getExceededBudgets(DateTime month) {
    final budgets = getAllBudgetsForMonth(month);
    final spending = getExpensesByCategory(month);

    return BudgetAnalytics.getExceededBudgets(budgets, spending);
  }

  // ==================== CASHBACK OPERATIONS ====================

  /// Calculate total cashback earned for a month
  static double getTotalCashback(DateTime month) {
    return getTransactionsByMonth(month)
        .where((t) => t.hasCashback)
        .fold(0.0, (sum, t) => sum + (t.cashbackEarned ?? 0));
  }

  /// Calculate total cashback earned (all time)
  static double getTotalCashbackAllTime() {
    return _transactionBox.values
        .where((t) => t.hasCashback)
        .fold(0.0, (sum, t) => sum + (t.cashbackEarned ?? 0));
  }

  /// Get cashback by category for a month
  static Map<String, double> getCashbackByCategory(DateTime month) {
    final transactions = getTransactionsByMonth(month);
    final cashbackTransactions = transactions.where((t) => t.hasCashback);

    final Map<String, double> result = {};
    for (var transaction in cashbackTransactions) {
      result[transaction.categoryId] =
          (result[transaction.categoryId] ?? 0) +
          (transaction.cashbackEarned ?? 0);
    }
    return result;
  }

  /// Calculate potential cashback for an amount and category
  static double calculatePotentialCashback(String categoryId, double amount) {
    final category = getCategoryById(categoryId);
    if (category == null || !category.offersCashback) return 0.0;

    return category.calculateCashback(amount);
  }

  // ==================== STATISTICS & ANALYTICS ====================

  /// Get spending trend (day by day) for a month
  static Map<int, double> getDailySpendingTrend(DateTime month) {
    final transactions = getTransactionsByMonth(
      month,
    ).where((t) => t.type == TransactionType.expense);

    final Map<int, double> dailySpending = {};
    for (var transaction in transactions) {
      final day = transaction.date.day;
      dailySpending[day] = (dailySpending[day] ?? 0) + transaction.amount;
    }
    return dailySpending;
  }

  /// Get income trend (day by day) for a month
  static Map<int, double> getDailyIncomeTrend(DateTime month) {
    final transactions = getTransactionsByMonth(
      month,
    ).where((t) => t.type == TransactionType.income);

    final Map<int, double> dailyIncome = {};
    for (var transaction in transactions) {
      final day = transaction.date.day;
      dailyIncome[day] = (dailyIncome[day] ?? 0) + transaction.amount;
    }
    return dailyIncome;
  }

  /// Get monthly summary
  static Map<String, dynamic> getMonthlySummary(DateTime month) {
    final income = getTotalIncome(month);
    final expenses = getTotalExpenses(month);
    final balance = income - expenses;
    final cashback = getTotalCashback(month);
    final transactionCount = getTransactionsByMonth(month).length;
    final budgets = getAllBudgetsForMonth(month);
    final topSpending = getTopSpendingCategories(month: month, limit: 1);

    return {
      'month': month,
      'income': income,
      'expenses': expenses,
      'balance': balance,
      'cashback': cashback,
      'netBalance': balance + cashback,
      'transactionCount': transactionCount,
      'budgetCount': budgets.length,
      'topSpendingCategory': topSpending.isNotEmpty
          ? topSpending.first.key
          : null,
      'topSpendingAmount': topSpending.isNotEmpty
          ? topSpending.first.value
          : 0.0,
    };
  }

  /// Compare two months
  static Map<String, dynamic> compareMonths(DateTime month1, DateTime month2) {
    final summary1 = getMonthlySummary(month1);
    final summary2 = getMonthlySummary(month2);

    return {
      'month1': summary1,
      'month2': summary2,
      'incomeDifference': summary2['income'] - summary1['income'],
      'expenseDifference': summary2['expenses'] - summary1['expenses'],
      'balanceDifference': summary2['balance'] - summary1['balance'],
      'incomePercentageChange': _calculatePercentageChange(
        summary1['income'],
        summary2['income'],
      ),
      'expensePercentageChange': _calculatePercentageChange(
        summary1['expenses'],
        summary2['expenses'],
      ),
    };
  }

  static double _calculatePercentageChange(double oldValue, double newValue) {
    if (oldValue == 0) return newValue > 0 ? 100.0 : 0.0;
    return ((newValue - oldValue) / oldValue * 100);
  }

  /// Get year-to-date summary
  static Map<String, dynamic> getYearToDateSummary() {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);

    final income = calculateTotalIncome(startOfYear, now);
    final expenses = calculateTotalExpenses(startOfYear, now);
    final cashback = _transactionBox.values
        .where((t) => t.date.year == now.year && t.hasCashback)
        .fold(0.0, (sum, t) => sum + (t.cashbackEarned ?? 0));

    return {
      'year': now.year,
      'income': income,
      'expenses': expenses,
      'balance': income - expenses,
      'cashback': cashback,
      'netBalance': (income - expenses) + cashback,
      'averageMonthlyIncome': income / now.month,
      'averageMonthlyExpense': expenses / now.month,
    };
  }

  // ==================== SETTINGS ====================

  /// Save a setting
  static Future<void> saveSetting(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }

  /// Get a setting
  static dynamic getSetting(String key, {dynamic defaultValue}) {
    return _settingsBox.get(key, defaultValue: defaultValue);
  }

  /// Delete a setting
  static Future<void> deleteSetting(String key) async {
    await _settingsBox.delete(key);
  }

  /// Clear all settings
  static Future<void> clearSettings() async {
    await _settingsBox.clear();
  }

  // ==================== DATA MANAGEMENT ====================

  /// Clear all data (transactions, budgets)
  static Future<void> clearAllData() async {
    await _transactionBox.clear();
    await _budgetBox.clear();
  }

  /// Clear all transactions
  static Future<void> clearAllTransactions() async {
    await _transactionBox.clear();
  }

  /// Clear all budgets
  static Future<void> clearAllBudgets() async {
    await _budgetBox.clear();
  }

  /// Get database statistics
  static Map<String, int> getDatabaseStats() {
    return {
      'totalTransactions': _transactionBox.length,
      'totalCategories': _categoryBox.length,
      'totalBudgets': _budgetBox.length,
      'incomeTransactions': getIncomeTransactions().length,
      'expenseTransactions': getExpenseTransactions().length,
    };
  }
}
