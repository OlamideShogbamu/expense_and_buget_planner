import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../models/budget_model.dart';
import '../models/transaction_type.dart';
import 'data_service.dart';

/// Service for handling CSV import/export operations
/// Supports data backup and restore functionality (Feature #8)
class CSVService {
  // Date format for CSV
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
  static final DateFormat _fileDateFormat = DateFormat('yyyyMMdd_HHmmss');

  // ==================== EXPORT OPERATIONS ====================

  /// Export all transactions to CSV
  static Future<ExportResult> exportTransactionsToCSV() async {
    try {
      final transactions = DataService.getAllTransactions();

      if (transactions.isEmpty) {
        return ExportResult(
          success: false,
          message: 'No transactions to export',
        );
      }

      // Create CSV data
      final List<List<dynamic>> rows = [];

      // Add header row
      rows.add([
        'Date',
        'Type',
        'Category',
        'Amount',
        'Note',
        'Cashback',
        'Payment Method',
        'Location',
        'Tags',
        'Transaction ID',
      ]);

      // Add transaction rows
      for (var transaction in transactions) {
        final category = DataService.getCategoryById(transaction.categoryId);
        rows.add([
          _dateFormat.format(transaction.date),
          transaction.type.displayName,
          category?.name ?? 'Unknown',
          transaction.amount.toStringAsFixed(2),
          transaction.note,
          transaction.cashbackEarned?.toStringAsFixed(2) ?? '0.00',
          transaction.paymentMethod ?? '',
          transaction.location ?? '',
          transaction.tags?.join(';') ?? '',
          transaction.id,
        ]);
      }

      // Convert to CSV string
      final csvString = const ListToCsvConverter().convert(rows);

      // Save to file
      final file = await _saveToFile(
        csvString,
        'transactions_${_fileDateFormat.format(DateTime.now())}.csv',
      );

      return ExportResult(
        success: true,
        message: 'Transactions exported successfully',
        filePath: file.path,
        recordCount: transactions.length,
      );
    } catch (e) {
      return ExportResult(
        success: false,
        message: 'Failed to export transactions: $e',
      );
    }
  }

  /// Export budgets to CSV
  static Future<ExportResult> exportBudgetsToCSV() async {
    try {
      final budgets = DataService.getAllBudgets();

      if (budgets.isEmpty) {
        return ExportResult(success: false, message: 'No budgets to export');
      }

      // Create CSV data
      final List<List<dynamic>> rows = [];

      // Add header row
      rows.add([
        'Month',
        'Category',
        'Budget Amount',
        'Alert Threshold',
        'Rollover Enabled',
        'Carried Over Amount',
        'Note',
        'Budget ID',
      ]);

      // Add budget rows
      for (var budget in budgets) {
        final category = DataService.getCategoryById(budget.categoryId);
        rows.add([
          _dateFormat.format(budget.month),
          category?.name ?? 'Unknown',
          budget.amount.toStringAsFixed(2),
          (budget.alertThreshold * 100).toStringAsFixed(0),
          budget.rolloverEnabled ? 'Yes' : 'No',
          budget.carriedOverAmount.toStringAsFixed(2),
          budget.note ?? '',
          budget.id,
        ]);
      }

      // Convert to CSV string
      final csvString = const ListToCsvConverter().convert(rows);

      // Save to file
      final file = await _saveToFile(
        csvString,
        'budgets_${_fileDateFormat.format(DateTime.now())}.csv',
      );

      return ExportResult(
        success: true,
        message: 'Budgets exported successfully',
        filePath: file.path,
        recordCount: budgets.length,
      );
    } catch (e) {
      return ExportResult(
        success: false,
        message: 'Failed to export budgets: $e',
      );
    }
  }

  /// Export categories to CSV
  static Future<ExportResult> exportCategoriesToCSV() async {
    try {
      final categories = DataService.getAllCategories();

      if (categories.isEmpty) {
        return ExportResult(success: false, message: 'No categories to export');
      }

      // Create CSV data
      final List<List<dynamic>> rows = [];

      // Add header row
      rows.add([
        'Name',
        'Icon',
        'Color',
        'Type',
        'Cashback Eligible',
        'Cashback Rate',
        'Budget Limit',
        'Description',
        'Category ID',
      ]);

      // Add category rows
      for (var category in categories) {
        rows.add([
          category.name,
          category.icon,
          category.color.toString(),
          category.categoryTypeLabel,
          category.isCashbackEligible ? 'Yes' : 'No',
          category.cashbackRate?.toString() ?? '0',
          category.budgetLimit?.toStringAsFixed(2) ?? '',
          category.description ?? '',
          category.id,
        ]);
      }

      // Convert to CSV string
      final csvString = const ListToCsvConverter().convert(rows);

      // Save to file
      final file = await _saveToFile(
        csvString,
        'categories_${_fileDateFormat.format(DateTime.now())}.csv',
      );

      return ExportResult(
        success: true,
        message: 'Categories exported successfully',
        filePath: file.path,
        recordCount: categories.length,
      );
    } catch (e) {
      return ExportResult(
        success: false,
        message: 'Failed to export categories: $e',
      );
    }
  }

  /// Export all data (transactions, budgets, categories) to CSV
  static Future<ExportResult> exportAllDataToCSV() async {
    try {
      final transactionsResult = await exportTransactionsToCSV();
      final budgetsResult = await exportBudgetsToCSV();
      final categoriesResult = await exportCategoriesToCSV();

      final successCount = [
        transactionsResult.success,
        budgetsResult.success,
        categoriesResult.success,
      ].where((s) => s).length;

      if (successCount == 0) {
        return ExportResult(
          success: false,
          message: 'Failed to export any data',
        );
      }

      return ExportResult(
        success: true,
        message: 'Exported $successCount file(s) successfully',
        filePath: transactionsResult.filePath,
      );
    } catch (e) {
      return ExportResult(success: false, message: 'Failed to export data: $e');
    }
  }

  /// Export transactions for a specific month
  static Future<ExportResult> exportMonthTransactionsToCSV(
    DateTime month,
  ) async {
    try {
      final transactions = DataService.getTransactionsByMonth(month);

      if (transactions.isEmpty) {
        return ExportResult(
          success: false,
          message: 'No transactions found for this month',
        );
      }

      // Create CSV data
      final List<List<dynamic>> rows = [];

      // Add header row
      rows.add([
        'Date',
        'Type',
        'Category',
        'Amount',
        'Note',
        'Cashback',
        'Payment Method',
      ]);

      // Add transaction rows
      for (var transaction in transactions) {
        final category = DataService.getCategoryById(transaction.categoryId);
        rows.add([
          _dateFormat.format(transaction.date),
          transaction.type.displayName,
          category?.name ?? 'Unknown',
          transaction.amount.toStringAsFixed(2),
          transaction.note,
          transaction.cashbackEarned?.toStringAsFixed(2) ?? '0.00',
          transaction.paymentMethod ?? '',
        ]);
      }

      // Convert to CSV string
      final csvString = const ListToCsvConverter().convert(rows);

      // Save to file
      final monthStr = DateFormat('yyyy_MM').format(month);
      final file = await _saveToFile(csvString, 'transactions_${monthStr}.csv');

      return ExportResult(
        success: true,
        message: 'Month transactions exported successfully',
        filePath: file.path,
        recordCount: transactions.length,
      );
    } catch (e) {
      return ExportResult(
        success: false,
        message: 'Failed to export month transactions: $e',
      );
    }
  }

  // ==================== IMPORT OPERATIONS ====================

  /// Import transactions from CSV file
  static Future<ImportResult> importTransactionsFromCSV() async {
    try {
      // Pick CSV file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result == null || result.files.isEmpty) {
        return ImportResult(success: false, message: 'No file selected');
      }

      final filePath = result.files.single.path;
      if (filePath == null) {
        return ImportResult(success: false, message: 'Invalid file path');
      }

      // Read CSV file
      final file = File(filePath);
      final csvString = await file.readAsString();

      // Parse CSV
      final rows = const CsvToListConverter().convert(csvString);

      if (rows.isEmpty || rows.length < 2) {
        return ImportResult(
          success: false,
          message: 'CSV file is empty or invalid',
        );
      }

      // Skip header row
      final dataRows = rows.skip(1);

      int successCount = 0;
      int failedCount = 0;
      final List<String> errors = [];

      // Import each transaction
      for (var row in dataRows) {
        try {
          if (row.length < 4) {
            failedCount++;
            errors.add('Invalid row format: insufficient columns');
            continue;
          }

          // Parse transaction data
          final date = _parseDate(row[0].toString());
          final type = _parseTransactionType(row[1].toString());
          final categoryName = row[2].toString();
          final amount = _parseAmount(row[3].toString());
          final note = row.length > 4 ? row[4].toString() : '';
          final cashback = row.length > 5
              ? _parseAmount(row[5].toString())
              : null;
          final paymentMethod = row.length > 6 ? row[6].toString() : null;
          final location = row.length > 7 ? row[7].toString() : null;
          final tagsStr = row.length > 8 ? row[8].toString() : '';

          // Find or create category
          final category = _findOrCreateCategory(categoryName, type);

          // Parse tags
          final tags = tagsStr.isNotEmpty
              ? tagsStr.split(';').map((t) => t.trim()).toList()
              : null;

          // Create transaction
          final transaction = TransactionFactory.create(
            amount: amount,
            categoryId: category.id,
            type: type,
            date: date,
            note: note,
            cashbackEarned: cashback,
            paymentMethod: paymentMethod,
            location: location,
            tags: tags,
          );

          await DataService.addTransaction(transaction);
          successCount++;
        } catch (e) {
          failedCount++;
          errors.add('Row error: $e');
        }
      }

      if (successCount == 0) {
        return ImportResult(
          success: false,
          message: 'Failed to import any transactions',
          errors: errors,
        );
      }

      return ImportResult(
        success: true,
        message: 'Imported $successCount transaction(s)',
        recordCount: successCount,
        failedCount: failedCount,
        errors: errors,
      );
    } catch (e) {
      return ImportResult(
        success: false,
        message: 'Failed to import transactions: $e',
      );
    }
  }

  /// Import budgets from CSV file
  static Future<ImportResult> importBudgetsFromCSV() async {
    try {
      // Pick CSV file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result == null || result.files.isEmpty) {
        return ImportResult(success: false, message: 'No file selected');
      }

      final filePath = result.files.single.path;
      if (filePath == null) {
        return ImportResult(success: false, message: 'Invalid file path');
      }

      // Read CSV file
      final file = File(filePath);
      final csvString = await file.readAsString();

      // Parse CSV
      final rows = const CsvToListConverter().convert(csvString);

      if (rows.isEmpty || rows.length < 2) {
        return ImportResult(
          success: false,
          message: 'CSV file is empty or invalid',
        );
      }

      // Skip header row
      final dataRows = rows.skip(1);

      int successCount = 0;
      int failedCount = 0;
      final List<String> errors = [];

      // Import each budget
      for (var row in dataRows) {
        try {
          if (row.length < 3) {
            failedCount++;
            errors.add('Invalid row format: insufficient columns');
            continue;
          }

          // Parse budget data
          final month = _parseDate(row[0].toString());
          final categoryName = row[1].toString();
          final amount = _parseAmount(row[2].toString());
          final alertThreshold = row.length > 3
              ? _parseAmount(row[3].toString()) / 100
              : 0.80;
          final rolloverEnabled = row.length > 4
              ? row[4].toString().toLowerCase() == 'yes'
              : false;
          final carriedOverAmount = row.length > 5
              ? _parseAmount(row[5].toString())
              : 0.0;
          final note = row.length > 6 ? row[6].toString() : null;

          // Find category
          final categories = DataService.getAllCategories()
              .where((c) => c.name.toLowerCase() == categoryName.toLowerCase())
              .toList();

          if (categories.isEmpty) {
            failedCount++;
            errors.add('Category not found: $categoryName');
            continue;
          }

          // Create budget
          final budget = BudgetFactory.createForMonth(
            categoryId: categories.first.id,
            amount: amount,
            month: month,
            alertThreshold: alertThreshold,
            rolloverEnabled: rolloverEnabled,
            carriedOverAmount: carriedOverAmount,
            note: note,
          );

          await DataService.setBudget(budget);
          successCount++;
        } catch (e) {
          failedCount++;
          errors.add('Row error: $e');
        }
      }

      if (successCount == 0) {
        return ImportResult(
          success: false,
          message: 'Failed to import any budgets',
          errors: errors,
        );
      }

      return ImportResult(
        success: true,
        message: 'Imported $successCount budget(s)',
        recordCount: successCount,
        failedCount: failedCount,
        errors: errors,
      );
    } catch (e) {
      return ImportResult(
        success: false,
        message: 'Failed to import budgets: $e',
      );
    }
  }

  // ==================== SHARE OPERATIONS ====================

  /// Share transactions CSV file
  static Future<bool> shareTransactionsCSV() async {
    try {
      final result = await exportTransactionsToCSV();

      if (!result.success || result.filePath == null) {
        return false;
      }

      await Share.shareXFiles([
        XFile(result.filePath!),
      ], text: 'My expense transactions');

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Share month transactions CSV file
  static Future<bool> shareMonthTransactionsCSV(DateTime month) async {
    try {
      final result = await exportMonthTransactionsToCSV(month);

      if (!result.success || result.filePath == null) {
        return false;
      }

      final monthName = DateFormat('MMMM yyyy').format(month);
      await Share.shareXFiles([
        XFile(result.filePath!),
      ], text: 'Transactions for $monthName');

      return true;
    } catch (e) {
      return false;
    }
  }

  // ==================== HELPER METHODS ====================

  /// Save CSV string to file
  static Future<File> _saveToFile(String csvString, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    return await file.writeAsString(csvString);
  }

  /// Parse date from string
  static DateTime _parseDate(String dateStr) {
    try {
      return _dateFormat.parse(dateStr);
    } catch (e) {
      // Try alternative formats
      try {
        return DateTime.parse(dateStr);
      } catch (e) {
        return DateTime.now();
      }
    }
  }

  /// Parse amount from string
  static double _parseAmount(String amountStr) {
    try {
      return double.parse(amountStr.replaceAll(',', ''));
    } catch (e) {
      return 0.0;
    }
  }

  /// Parse transaction type from string
  static TransactionType _parseTransactionType(String typeStr) {
    final lower = typeStr.toLowerCase();
    if (lower.contains('income')) {
      return TransactionType.income;
    }
    return TransactionType.expense;
  }

  /// Find or create category by name
  static CategoryModel _findOrCreateCategory(
    String categoryName,
    TransactionType type,
  ) {
    // Try to find existing category
    final categories = DataService.getAllCategories();
    final existing = categories
        .where((c) => c.name.toLowerCase() == categoryName.toLowerCase())
        .toList();

    if (existing.isNotEmpty) {
      return existing.first;
    }

    // Create new category
    final newCategory = CategoryFactory.createCustom(
      name: categoryName,
      icon: '📦',
      color: 0xFF98C1D9,
      categoryType: type,
    );

    DataService.addCategory(newCategory);
    return newCategory;
  }

  // ==================== CLEANUP ====================

  /// Delete exported file
  static Future<bool> deleteExportedFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Get list of exported files
  static Future<List<FileInfo>> getExportedFiles() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final files = directory
          .listSync()
          .where((f) => f.path.endsWith('.csv'))
          .map((f) => File(f.path))
          .toList();

      final List<FileInfo> fileInfos = [];
      for (var file in files) {
        final stat = await file.stat();
        fileInfos.add(
          FileInfo(
            name: file.path.split('/').last,
            path: file.path,
            size: stat.size,
            modifiedDate: stat.modified,
          ),
        );
      }

      return fileInfos
        ..sort((a, b) => b.modifiedDate.compareTo(a.modifiedDate));
    } catch (e) {
      return [];
    }
  }
}

// ==================== RESULT CLASSES ====================

/// Class representing export operation result
class ExportResult {
  final bool success;
  final String message;
  final String? filePath;
  final int? recordCount;

  ExportResult({
    required this.success,
    required this.message,
    this.filePath,
    this.recordCount,
  });

  @override
  String toString() {
    return 'ExportResult(success: $success, message: $message, records: $recordCount)';
  }
}

/// Class representing import operation result
class ImportResult {
  final bool success;
  final String message;
  final int? recordCount;
  final int? failedCount;
  final List<String>? errors;

  ImportResult({
    required this.success,
    required this.message,
    this.recordCount,
    this.failedCount,
    this.errors,
  });

  @override
  String toString() {
    return 'ImportResult(success: $success, message: $message, '
        'imported: $recordCount, failed: $failedCount)';
  }
}

/// Class representing file information
class FileInfo {
  final String name;
  final String path;
  final int size;
  final DateTime modifiedDate;

  FileInfo({
    required this.name,
    required this.path,
    required this.size,
    required this.modifiedDate,
  });

  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String get formattedDate {
    return DateFormat('MMM dd, yyyy HH:mm').format(modifiedDate);
  }
}
