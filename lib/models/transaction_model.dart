import 'package:hive/hive.dart';
import 'transaction_type.dart';

part 'transaction_model.g.dart';

/// Model representing a financial transaction (income or expense)
/// This is the core data structure for tracking all money movements
@HiveType(typeId: 1)
class TransactionModel extends HiveObject {
  /// Unique identifier for the transaction
  @HiveField(0)
  final String id;

  /// Amount of money involved in the transaction
  @HiveField(1)
  final double amount;

  /// Category ID this transaction belongs to
  /// References CategoryModel.id
  @HiveField(2)
  final String categoryId;

  /// Type of transaction (income or expense)
  @HiveField(3)
  final TransactionType type;

  /// Date and time when the transaction occurred
  @HiveField(4)
  final DateTime date;

  /// Optional note/description about the transaction
  @HiveField(5)
  final String note;

  /// User ID who created this transaction (for multi-user support)
  @HiveField(6)
  final String? userId;

  /// Cashback earned from this transaction (if applicable)
  /// Only relevant for expense transactions with cashback categories
  @HiveField(7)
  final double? cashbackEarned;

  /// Whether this transaction is recurring
  @HiveField(8)
  final bool isRecurring;

  /// Tags for better categorization and filtering
  @HiveField(9)
  final List<String>? tags;

  /// Payment method (cash, card, bank transfer, etc.)
  @HiveField(10)
  final String? paymentMethod;

  /// Location where transaction occurred (optional)
  @HiveField(11)
  final String? location;

  /// Timestamp when the transaction was created in the app
  @HiveField(12)
  final DateTime createdAt;

  /// Timestamp when the transaction was last updated
  @HiveField(13)
  final DateTime updatedAt;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.categoryId,
    required this.type,
    required this.date,
    this.note = '',
    this.userId,
    this.cashbackEarned,
    this.isRecurring = false,
    this.tags,
    this.paymentMethod,
    this.location,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /// Create a copy of this transaction with updated fields
  TransactionModel copyWith({
    String? id,
    double? amount,
    String? categoryId,
    TransactionType? type,
    DateTime? date,
    String? note,
    String? userId,
    double? cashbackEarned,
    bool? isRecurring,
    List<String>? tags,
    String? paymentMethod,
    String? location,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      type: type ?? this.type,
      date: date ?? this.date,
      note: note ?? this.note,
      userId: userId ?? this.userId,
      cashbackEarned: cashbackEarned ?? this.cashbackEarned,
      isRecurring: isRecurring ?? this.isRecurring,
      tags: tags ?? this.tags,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Convert transaction to JSON format for export/backup
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'categoryId': categoryId,
      'type': type.name,
      'date': date.toIso8601String(),
      'note': note,
      'userId': userId,
      'cashbackEarned': cashbackEarned,
      'isRecurring': isRecurring,
      'tags': tags,
      'paymentMethod': paymentMethod,
      'location': location,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create transaction from JSON format for import/restore
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      categoryId: json['categoryId'] as String,
      type: TransactionTypeHelper.fromString(json['type'] as String),
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String? ?? '',
      userId: json['userId'] as String?,
      cashbackEarned: json['cashbackEarned'] != null
          ? (json['cashbackEarned'] as num).toDouble()
          : null,
      isRecurring: json['isRecurring'] as bool? ?? false,
      tags: json['tags'] != null
          ? List<String>.from(json['tags'] as List)
          : null,
      paymentMethod: json['paymentMethod'] as String?,
      location: json['location'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Convert to CSV row format for export
  List<dynamic> toCsvRow() {
    return [
      date.toIso8601String(),
      type.displayName,
      categoryId,
      amount,
      note,
      cashbackEarned ?? 0,
      paymentMethod ?? '',
      location ?? '',
      tags?.join(';') ?? '',
    ];
  }

  /// Get the impact this transaction has on the total balance
  /// Positive for income, negative for expense
  double get balanceImpact => amount * type.signMultiplier;

  /// Check if this transaction occurred today
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Check if this transaction occurred this week
  bool get isThisWeek {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return date.isAfter(weekAgo) &&
        date.isBefore(now.add(const Duration(days: 1)));
  }

  /// Check if this transaction occurred this month
  bool get isThisMonth {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  /// Check if this transaction occurred this year
  bool get isThisYear {
    final now = DateTime.now();
    return date.year == now.year;
  }

  /// Check if transaction has cashback
  bool get hasCashback => cashbackEarned != null && cashbackEarned! > 0;

  /// Get formatted amount with currency symbol
  String getFormattedAmount([String currencySymbol = '\$']) {
    return '$currencySymbol${amount.toStringAsFixed(2)}';
  }

  /// Get formatted cashback amount
  String getFormattedCashback([String currencySymbol = '\$']) {
    if (!hasCashback) return '$currencySymbol 0.00';
    return '$currencySymbol${cashbackEarned!.toStringAsFixed(2)}';
  }

  /// Check if transaction matches search query
  bool matchesSearch(String query) {
    final lowerQuery = query.toLowerCase();
    return note.toLowerCase().contains(lowerQuery) ||
        amount.toString().contains(lowerQuery) ||
        (location?.toLowerCase().contains(lowerQuery) ?? false) ||
        (tags?.any((tag) => tag.toLowerCase().contains(lowerQuery)) ?? false);
  }

  /// Check if transaction has any tags
  bool get hasTags => tags != null && tags!.isNotEmpty;

  /// Validate transaction data
  bool validate() {
    if (amount <= 0) return false;
    if (categoryId.isEmpty) return false;
    if (date.isAfter(DateTime.now().add(const Duration(days: 1)))) return false;
    return true;
  }

  @override
  String toString() {
    return 'Transaction(id: $id, amount: $amount, type: ${type.displayName}, '
        'category: $categoryId, date: $date)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransactionModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Factory class for creating new transactions
class TransactionFactory {
  /// Create a new transaction with auto-generated ID
  static TransactionModel create({
    required double amount,
    required String categoryId,
    required TransactionType type,
    required DateTime date,
    String note = '',
    String? userId,
    double? cashbackEarned,
    bool isRecurring = false,
    List<String>? tags,
    String? paymentMethod,
    String? location,
  }) {
    return TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      categoryId: categoryId,
      type: type,
      date: date,
      note: note,
      userId: userId,
      cashbackEarned: cashbackEarned,
      isRecurring: isRecurring,
      tags: tags,
      paymentMethod: paymentMethod,
      location: location,
    );
  }

  /// Create an income transaction
  static TransactionModel createIncome({
    required double amount,
    required String categoryId,
    required DateTime date,
    String note = '',
    List<String>? tags,
  }) {
    return create(
      amount: amount,
      categoryId: categoryId,
      type: TransactionType.income,
      date: date,
      note: note,
      tags: tags,
    );
  }

  /// Create an expense transaction with optional cashback
  static TransactionModel createExpense({
    required double amount,
    required String categoryId,
    required DateTime date,
    String note = '',
    double? cashbackEarned,
    List<String>? tags,
    String? paymentMethod,
    String? location,
  }) {
    return create(
      amount: amount,
      categoryId: categoryId,
      type: TransactionType.expense,
      date: date,
      note: note,
      cashbackEarned: cashbackEarned,
      tags: tags,
      paymentMethod: paymentMethod,
      location: location,
    );
  }
}
