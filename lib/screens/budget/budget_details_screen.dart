import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/colors.dart';
import '../../models/budget_model.dart';
import '../../services/data_service.dart';

/// Screen showing detailed budget information and related transactions
class BudgetDetailsScreen extends StatelessWidget {
  final BudgetModel budget;
  final DateTime month;

  const BudgetDetailsScreen({
    Key? key,
    required this.budget,
    required this.month,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final category = DataService.getCategoryById(budget.categoryId);
    final transactions =
        DataService.getTransactionsByCategory(budget.categoryId)
            .where(
              (t) => t.date.year == month.year && t.date.month == month.month,
            )
            .toList();
    final spent =
        DataService.getExpensesByCategory(month)[budget.categoryId] ?? 0.0;
    final percentage = budget.getSpendingPercentage(spent);
    final status = budget.getStatus(spent);

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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(category?.name ?? 'Budget Details')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderCard(
                category?.icon ?? '❓',
                category?.name ?? 'Unknown',
                spent,
                budget.amount,
                percentage,
                statusColor,
                Color(category?.color ?? 0xFF666666),
              ),
              const SizedBox(height: 24),
              _buildStatsCards(spent, budget.amount, transactions.length),
              const SizedBox(height: 24),
              _buildSettingsInfo(budget),
              const SizedBox(height: 24),
              _buildTransactionsList(transactions, context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(
    String icon,
    String name,
    double spent,
    double budgetAmount,
    double percentage,
    Color statusColor,
    Color categoryColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [categoryColor, categoryColor.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: categoryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(icon, style: const TextStyle(fontSize: 40)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMMM yyyy').format(month),
                      style: TextStyle(
                        color: AppColors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Spent',
                style: TextStyle(
                  color: AppColors.white.withOpacity(0.9),
                  fontSize: 14,
                ),
              ),
              Text(
                "\$${spent.toStringAsFixed(2)}",
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Budget',
                style: TextStyle(
                  color: AppColors.white.withOpacity(0.9),
                  fontSize: 14,
                ),
              ),
              Text(
                '\${budgetAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: AppColors.white.withOpacity(0.9),
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (percentage / 100).clamp(0.0, 1.0),
              backgroundColor: AppColors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.white),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${percentage.toInt()}% used',
                style: TextStyle(
                  color: AppColors.white.withOpacity(0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                budget.getRemainingBudget(spent) > 0
                    ? '\${budget.getRemainingBudget(spent).toStringAsFixed(2)} left'
                    : '\${budget.getOverspendingAmount(spent).toStringAsFixed(2)} over',
                style: TextStyle(
                  color: AppColors.white.withOpacity(0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(
    double spent,
    double budgetAmount,
    int transactionCount,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Daily Avg',
            '\${(spent / DateTime.now().day).toStringAsFixed(2)}',
            Icons.calendar_today,
            AppColors.info,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Transactions',
            transactionCount.toString(),
            Icons.receipt,
            AppColors.secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsInfo(BudgetModel budget) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Budget Settings',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildSettingRow(
            Icons.notifications_active,
            'Alert Threshold',
            '${(budget.alertThreshold * 100).toInt()}%',
          ),
          const Divider(height: 24),
          _buildSettingRow(
            Icons.notifications,
            'Alerts',
            budget.alertsEnabled ? 'Enabled' : 'Disabled',
          ),
          const Divider(height: 24),
          _buildSettingRow(
            Icons.sync,
            'Rollover',
            budget.rolloverEnabled ? 'Enabled' : 'Disabled',
          ),
          if (budget.note != null && budget.note!.isNotEmpty) ...[
            const Divider(height: 24),
            _buildSettingRow(Icons.note, 'Note', budget.note!),
          ],
        ],
      ),
    );
  }

  Widget _buildSettingRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.secondary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionsList(
    List<dynamic> transactions,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transactions',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (transactions.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 48,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No transactions yet',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...transactions.map((transaction) {
            final category = DataService.getCategoryById(
              transaction.categoryId,
            );
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color(
                        category?.color ?? 0xFF666666,
                      ).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      category?.icon ?? '❓',
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction.note.isEmpty
                              ? category?.name ?? 'Transaction'
                              : transaction.note,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat(
                            'MMM dd, yyyy • HH:mm',
                          ).format(transaction.date),
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '\${transaction.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: AppColors.expense,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
      ],
    );
  }
}
