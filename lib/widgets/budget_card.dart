import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../models/budget_model.dart';
import '../models/category_model.dart';

/// Reusable budget card widget with progress indicator
class BudgetCard extends StatelessWidget {
  final BudgetModel budget;
  final CategoryModel category;
  final double spent;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const BudgetCard({
    Key? key,
    required this.budget,
    required this.category,
    required this.spent,
    this.onTap,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final percentage = budget.getSpendingPercentage(spent);
    final status = budget.getStatus(spent);
    final statusColor = _getStatusColor(status);

    return InkWell(
      onTap: onTap,
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
                // Category icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(category.color).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    category.icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(width: 12),

                // Budget info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${spent.toStringAsFixed(2)} / \$${budget.amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                // Percentage badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
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

            // Progress bar
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

            // Status and alerts
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  budget.getRemainingBudget(spent) > 0
                      ? '\$${budget.getRemainingBudget(spent).toStringAsFixed(2)} remaining'
                      : '\$${budget.getOverspendingAmount(spent).toStringAsFixed(2)} over budget',
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    if (budget.alertsEnabled)
                      Icon(
                        Icons.notifications_active,
                        size: 16,
                        color: AppColors.textTertiary,
                      ),
                    if (budget.rolloverEnabled) ...[
                      const SizedBox(width: 4),
                      Icon(Icons.sync, size: 16, color: AppColors.textTertiary),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(BudgetStatus status) {
    switch (status) {
      case BudgetStatus.safe:
        return AppColors.budgetSafe;
      case BudgetStatus.warning:
        return AppColors.budgetWarning;
      case BudgetStatus.exceeded:
        return AppColors.budgetExceeded;
    }
  }
}

/// Compact budget card for dashboard
class CompactBudgetCard extends StatelessWidget {
  final BudgetModel budget;
  final CategoryModel category;
  final double spent;
  final VoidCallback? onTap;

  const CompactBudgetCard({
    Key? key,
    required this.budget,
    required this.category,
    required this.spent,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final percentage = budget.getSpendingPercentage(spent);
    final status = budget.getStatus(spent);
    final statusColor = _getStatusColor(status);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(category.icon, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    category.name,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${percentage.toInt()}%',
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: (percentage / 100).clamp(0.0, 1.0),
                backgroundColor: AppColors.surfaceLight,
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(BudgetStatus status) {
    switch (status) {
      case BudgetStatus.safe:
        return AppColors.budgetSafe;
      case BudgetStatus.warning:
        return AppColors.budgetWarning;
      case BudgetStatus.exceeded:
        return AppColors.budgetExceeded;
    }
  }
}

/// Budget progress ring widget
class BudgetProgressRing extends StatelessWidget {
  final double spent;
  final double budget;
  final Color color;
  final double size;

  const BudgetProgressRing({
    Key? key,
    required this.spent,
    required this.budget,
    required this.color,
    this.size = 80,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final percentage = budget > 0 ? (spent / budget).clamp(0.0, 1.0) : 0.0;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: percentage,
            strokeWidth: 8,
            backgroundColor: AppColors.surfaceLight,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${(percentage * 100).toInt()}%',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: size / 4,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'used',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: size / 8,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
