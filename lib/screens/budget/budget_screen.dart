import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../../theme/colors.dart';
import '../../models/budget_model.dart';
import '../../services/data_service.dart';
import 'add_budget_screen.dart';
import 'budget_details_screen.dart';

/// Screen for viewing and managing budgets
class BudgetScreen extends StatefulWidget {
  const BudgetScreen({Key? key}) : super(key: key);

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  DateTime _selectedMonth = DateTime.now();

  Future<void> _selectMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDatePickerMode: DatePickerMode.year,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedMonth = DateTime(picked.year, picked.month);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Budgets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddBudgetScreen(month: _selectedMonth),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildMonthSelector(),
            _buildSummaryCard(),
            Expanded(child: _buildBudgetsList()),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: InkWell(
        onTap: _selectMonth,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_month, color: AppColors.secondary, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    DateFormat('MMMM yyyy').format(_selectedMonth),
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return ValueListenableBuilder(
      valueListenable: Hive.box<BudgetModel>('budgets').listenable(),
      builder: (context, Box<BudgetModel> box, _) {
        final budgets = DataService.getAllBudgetsForMonth(_selectedMonth);
        final spending = DataService.getExpensesByCategory(_selectedMonth);
        
        if (budgets.isEmpty) {
          return const SizedBox.shrink();
        }

        final performance = BudgetAnalytics.getPerformanceSummary(budgets, spending);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _getGradientColors(performance.overallStatus),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Overall Budget',
                      style: TextStyle(
                        color: AppColors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        performance.overallStatus.displayName,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  performance.getFormattedTotalBudget(),
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${performance.getFormattedTotalSpent()} spent',
                  style: TextStyle(
                    color: AppColors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: (performance.overallSpendingPercentage / 100).clamp(0.0, 1.0),
                    backgroundColor: AppColors.white.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.white),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatusItem(
                      '${performance.safeCount}',
                      'On Track',
                      AppColors.white.withOpacity(0.9),
                    ),
                    _buildStatusItem(
                      '${performance.warningCount}',
                      'Warning',
                      AppColors.white.withOpacity(0.9),
                    ),
                    _buildStatusItem(
                      '${performance.exceededCount}',
                      'Exceeded',
                      AppColors.white.withOpacity(0.9),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Color> _getGradientColors(BudgetStatus status) {
    switch (status) {
      case BudgetStatus.safe:
        return [AppColors.budgetSafe, AppColors.successLight];
      case BudgetStatus.warning:
        return [AppColors.budgetWarning, AppColors.warningLight];
      case BudgetStatus.exceeded:
        return [AppColors.budgetExceeded, AppColors.errorLight];
    }
  }

  Widget _buildStatusItem(String count, String label, Color color) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetsList() {
    return ValueListenableBuilder(
      valueListenable: Hive.box<BudgetModel>('budgets').listenable(),
      builder: (context, Box<BudgetModel> box, _) {
        final budgets = DataService.getAllBudgetsForMonth(_selectedMonth);
        
        if (budgets.isEmpty) {
          return _buildEmptyState();
        }

        final spending = DataService.getExpensesByCategory(_selectedMonth);

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: budgets.length,
          itemBuilder: (context, index) {
            final budget = budgets[index];
            final category = DataService.getCategoryById(budget.categoryId);
            final spent = spending[budget.categoryId] ?? 0.0;
            final percentage = budget.getSpendingPercentage(spent);
            final status = budget.getStatus(spent);

            return _buildBudgetCard(
              budget,
              category?.name ?? 'Unknown',
              category?.icon ?? '❓',
              spent,
              budget.amount,
              percentage,
              status,
              Color(category?.color ?? 0xFF666666),
            );
          },
        );
      },
    );
  }

  Widget _buildBudgetCard(
    BudgetModel budget,
    String name,
    String icon,
    double spent,
    double budgetAmount,
    double percentage,
    BudgetStatus status,
    Color color,
  ) {
    Color statusColor;
    switch (status) {
      case BudgetStatus.safe:
        statusColor = AppColors.budgetSafe;
        break;
      case BudgetStatus.warning:
        statusColor = AppColors.budgetWarning;
        break;
      case BudgetStatus.exceeded:
        statusColor = AppColors.budgetExceeded;
        break;
    }

    return Dismissible(
      key: Key(budget.id),
      background: _buildDismissBackground(Alignment.centerLeft, Icons.edit, AppColors.info),
      secondaryBackground: _buildDismissBackground(Alignment.centerRight, Icons.delete, AppColors.error),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Edit
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddBudgetScreen(
                month: _selectedMonth,
                budget: budget,
              ),
            ),
          );
          return false;
        } else {
          // Delete
          return await _confirmDelete(name);
        }
      },
      onDismissed: (direction) async {
        await DataService.deleteBudgetById(budget.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Budget deleted'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      },
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BudgetDetailsScreen(
                budget: budget,
                month: _selectedMonth,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      icon,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\${spent.toStringAsFixed(2)} / \${budgetAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${percentage.toInt()}%',
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: (percentage / 100).clamp(0.0, 1.0),
                  backgroundColor: AppColors.surfaceLight,
                  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    budget.getRemainingBudget(spent) > 0
                        ? '\${budget.getRemainingBudget(spent).toStringAsFixed(2)} remaining'
                        : '\${budget.getOverspendingAmount(spent).toStringAsFixed(2)} over budget',
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (budget.alertsEnabled)
                    Icon(
                      Icons.notifications_active,
                      size: 16,
                      color: AppColors.textTertiary,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDismissBackground(Alignment alignment, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Icon(icon, color: AppColors.white),
    );
  }

  Future<bool> _confirmDelete(String categoryName) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Budget'),
        content: Text('Are you sure you want to delete the budget for $categoryName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    ) ?? false;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 80,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No budgets yet',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Set budgets to track your spending\nand stay on top of your finances',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddBudgetScreen(month: _selectedMonth),
                  ),
                );
              },
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Create Budget'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}