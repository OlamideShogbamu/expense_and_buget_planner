import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/colors.dart';
import '../models/transaction_model.dart';
import '../models/transaction_type.dart';
import '../services/data_service.dart';

/// Reusable transaction card widget
class TransactionCard extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showDate;
  final bool showCashback;

  const TransactionCard({
    Key? key,
    required this.transaction,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showDate = true,
    this.showCashback = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final category = DataService.getCategoryById(transaction.categoryId);

    return Dismissible(
      key: Key(transaction.id),
      background: _buildDismissBackground(
        Alignment.centerLeft,
        Icons.edit,
        AppColors.info,
      ),
      secondaryBackground: _buildDismissBackground(
        Alignment.centerRight,
        Icons.delete,
        AppColors.error,
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          if (onEdit != null) onEdit!();
          return false;
        } else {
          if (onDelete != null) {
            return await _confirmDelete(context);
          }
          return false;
        }
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart && onDelete != null) {
          onDelete!();
        }
      },
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // Category icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(category?.color ?? 0xFF666666).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  category?.icon ?? '❓',
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(width: 12),

              // Transaction details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category?.name ?? 'Unknown',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (transaction.note.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        transaction.note,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (showCashback && transaction.hasCashback) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.card_giftcard,
                            size: 14,
                            color: AppColors.cashback,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '+${transaction.getFormattedCashback()}',
                            style: TextStyle(
                              color: AppColors.cashback,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (transaction.paymentMethod != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        transaction.paymentMethod!,
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Amount and date
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${transaction.type == TransactionType.income ? '+' : '-'}${transaction.getFormattedAmount()}',
                    style: TextStyle(
                      color: transaction.type == TransactionType.income
                          ? AppColors.income
                          : AppColors.expense,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (showDate) ...[
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('HH:mm').format(transaction.date),
                      style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDismissBackground(
    Alignment alignment,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Icon(icon, color: AppColors.white),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Transaction'),
            content: const Text(
              'Are you sure you want to delete this transaction?',
            ),
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
        ) ??
        false;
  }
}

/// Compact version of transaction card for lists
class CompactTransactionCard extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onTap;

  const CompactTransactionCard({
    Key? key,
    required this.transaction,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final category = DataService.getCategoryById(transaction.categoryId);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(category?.color ?? 0xFF666666).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
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
                    category?.name ?? 'Unknown',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (transaction.note.isNotEmpty)
                    Text(
                      transaction.note,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            Text(
              '${transaction.type == TransactionType.income ? '+' : '-'}${transaction.getFormattedAmount()}',
              style: TextStyle(
                color: transaction.type == TransactionType.income
                    ? AppColors.income
                    : AppColors.expense,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
