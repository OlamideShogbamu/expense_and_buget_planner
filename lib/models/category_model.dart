import 'package:hive/hive.dart';
import 'transaction_type.dart';

part 'category_model.g.dart';

/// Model representing a transaction category
/// Categories help organize income and expenses for better tracking and analytics
@HiveType(typeId: 2)
class CategoryModel extends HiveObject {
  /// Unique identifier for the category
  @HiveField(0)
  final String id;

  /// Display name of the category
  @HiveField(1)
  final String name;

  /// Emoji icon representing the category
  @HiveField(2)
  final String icon;

  /// Color code for the category (used in UI and charts)
  @HiveField(3)
  final int color;

  /// Whether this is a default category (cannot be deleted)
  @HiveField(4)
  final bool isDefault;

  /// Type of transactions this category is for (income/expense/both)
  /// If null, it can be used for both income and expense
  @HiveField(5)
  final TransactionType? categoryType;

  /// Whether this category is eligible for cashback rewards
  /// Only applicable to expense categories
  @HiveField(6)
  final bool isCashbackEligible;

  /// Cashback rate for this category (e.g., 0.05 for 5%)
  /// Only used if isCashbackEligible is true
  @HiveField(7)
  final double? cashbackRate;

  /// Description of the category
  @HiveField(8)
  final String? description;

  /// Budget limit for this category (monthly)
  /// Helps with expense tracking and budget alerts
  @HiveField(9)
  final double? budgetLimit;

  /// Sort order for displaying categories
  @HiveField(10)
  final int sortOrder;

  /// Whether the category is active (visible to users)
  @HiveField(11)
  final bool isActive;

  /// User ID who created this category (for custom categories)
  @HiveField(12)
  final String? userId;

  /// Timestamp when the category was created
  @HiveField(13)
  final DateTime createdAt;

  /// Timestamp when the category was last updated
  @HiveField(14)
  final DateTime updatedAt;

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.isDefault = false,
    this.categoryType,
    this.isCashbackEligible = false,
    this.cashbackRate,
    this.description,
    this.budgetLimit,
    this.sortOrder = 0,
    this.isActive = true,
    this.userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /// Create a copy of this category with updated fields
  CategoryModel copyWith({
    String? id,
    String? name,
    String? icon,
    int? color,
    bool? isDefault,
    TransactionType? categoryType,
    bool? isCashbackEligible,
    double? cashbackRate,
    String? description,
    double? budgetLimit,
    int? sortOrder,
    bool? isActive,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isDefault: isDefault ?? this.isDefault,
      categoryType: categoryType ?? this.categoryType,
      isCashbackEligible: isCashbackEligible ?? this.isCashbackEligible,
      cashbackRate: cashbackRate ?? this.cashbackRate,
      description: description ?? this.description,
      budgetLimit: budgetLimit ?? this.budgetLimit,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Convert category to JSON format
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
      'isDefault': isDefault,
      'categoryType': categoryType?.name,
      'isCashbackEligible': isCashbackEligible,
      'cashbackRate': cashbackRate,
      'description': description,
      'budgetLimit': budgetLimit,
      'sortOrder': sortOrder,
      'isActive': isActive,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create category from JSON format
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      color: json['color'] as int,
      isDefault: json['isDefault'] as bool? ?? false,
      categoryType: json['categoryType'] != null
          ? TransactionTypeHelper.fromString(json['categoryType'] as String)
          : null,
      isCashbackEligible: json['isCashbackEligible'] as bool? ?? false,
      cashbackRate: json['cashbackRate'] != null
          ? (json['cashbackRate'] as num).toDouble()
          : null,
      description: json['description'] as String?,
      budgetLimit: json['budgetLimit'] != null
          ? (json['budgetLimit'] as num).toDouble()
          : null,
      sortOrder: json['sortOrder'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      userId: json['userId'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Check if this category can be used for income transactions
  bool get canBeUsedForIncome {
    return categoryType == null || categoryType == TransactionType.income;
  }

  /// Check if this category can be used for expense transactions
  bool get canBeUsedForExpense {
    return categoryType == null || categoryType == TransactionType.expense;
  }

  /// Get the display label for the category type
  String get categoryTypeLabel {
    if (categoryType == null) return 'All';
    return categoryType!.displayName;
  }

  /// Check if category has a budget limit set
  bool get hasBudgetLimit => budgetLimit != null && budgetLimit! > 0;

  /// Check if category offers cashback
  bool get offersCashback =>
      isCashbackEligible && cashbackRate != null && cashbackRate! > 0;

  /// Get formatted cashback rate (e.g., "5%")
  String get formattedCashbackRate {
    if (!offersCashback) return '0%';
    return '${(cashbackRate! * 100).toStringAsFixed(0)}%';
  }

  /// Get formatted budget limit
  String getFormattedBudgetLimit([String currencySymbol = '\$']) {
    if (!hasBudgetLimit) return '$currencySymbol 0.00';
    return '$currencySymbol${budgetLimit!.toStringAsFixed(2)}';
  }

  /// Calculate cashback amount for a given transaction amount
  double calculateCashback(double transactionAmount) {
    if (!offersCashback) return 0.0;
    return transactionAmount * cashbackRate!;
  }

  /// Check if category matches search query
  bool matchesSearch(String query) {
    final lowerQuery = query.toLowerCase();
    return name.toLowerCase().contains(lowerQuery) ||
        (description?.toLowerCase().contains(lowerQuery) ?? false);
  }

  /// Validate category data
  bool validate() {
    if (name.isEmpty || name.length > 30) return false;
    if (icon.isEmpty) return false;
    if (cashbackRate != null && (cashbackRate! < 0 || cashbackRate! > 1))
      return false;
    if (budgetLimit != null && budgetLimit! < 0) return false;
    return true;
  }

  @override
  String toString() {
    return 'Category(id: $id, name: $name, icon: $icon, type: ${categoryTypeLabel})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Predefined category templates for easy setup
class CategoryTemplates {
  /// Income categories
  static List<CategoryModel> get incomeCategories => [
    CategoryModel(
      id: 'income_salary',
      name: 'Salary',
      icon: '💰',
      color: 0xFF58641D,
      isDefault: true,
      categoryType: TransactionType.income,
      description: 'Monthly salary and wages',
    ),
    CategoryModel(
      id: 'income_freelance',
      name: 'Freelance',
      icon: '💼',
      color: 0xFF3D5A80,
      isDefault: true,
      categoryType: TransactionType.income,
      description: 'Freelance project payments',
    ),
    CategoryModel(
      id: 'income_investment',
      name: 'Investment',
      icon: '📈',
      color: 0xFF7B904B,
      isDefault: true,
      categoryType: TransactionType.income,
      description: 'Returns from investments',
    ),
    CategoryModel(
      id: 'income_business',
      name: 'Business',
      icon: '🏢',
      color: 0xFF4A5899,
      isDefault: true,
      categoryType: TransactionType.income,
      description: 'Business income and profits',
    ),
    CategoryModel(
      id: 'income_rental',
      name: 'Rental',
      icon: '🏠',
      color: 0xFF6BCB77,
      isDefault: true,
      categoryType: TransactionType.income,
      description: 'Property rental income',
    ),
    CategoryModel(
      id: 'income_gifts',
      name: 'Gifts',
      icon: '🎁',
      color: 0xFFEE6C4D,
      isDefault: true,
      categoryType: TransactionType.income,
      description: 'Money received as gifts',
    ),
  ];

  /// Expense categories with cashback
  static List<CategoryModel> get expenseCategories => [
    CategoryModel(
      id: 'expense_food',
      name: 'Food & Dining',
      icon: '🍽️',
      color: 0xFFFF6B6B,
      isDefault: true,
      categoryType: TransactionType.expense,
      isCashbackEligible: true,
      cashbackRate: 0.03, // 3% cashback
      description: 'Restaurant meals and food delivery',
    ),
    CategoryModel(
      id: 'expense_groceries',
      name: 'Groceries',
      icon: '🛒',
      color: 0xFF51CF66,
      isDefault: true,
      categoryType: TransactionType.expense,
      isCashbackEligible: true,
      cashbackRate: 0.02, // 2% cashback
      description: 'Supermarket and grocery shopping',
    ),
    CategoryModel(
      id: 'expense_transport',
      name: 'Transportation',
      icon: '🚗',
      color: 0xFF4ECDC4,
      isDefault: true,
      categoryType: TransactionType.expense,
      description: 'Fuel, public transport, taxi',
    ),
    CategoryModel(
      id: 'expense_shopping',
      name: 'Shopping',
      icon: '🛍️',
      color: 0xFF95E1D3,
      isDefault: true,
      categoryType: TransactionType.expense,
      isCashbackEligible: true,
      cashbackRate: 0.05, // 5% cashback
      description: 'Clothes, accessories, personal items',
    ),
    CategoryModel(
      id: 'expense_bills',
      name: 'Bills & Utilities',
      icon: '📄',
      color: 0xFFF38181,
      isDefault: true,
      categoryType: TransactionType.expense,
      description: 'Electricity, water, internet, phone',
    ),
    CategoryModel(
      id: 'expense_entertainment',
      name: 'Entertainment',
      icon: '🎮',
      color: 0xFFAA96DA,
      isDefault: true,
      categoryType: TransactionType.expense,
      description: 'Movies, games, subscriptions',
    ),
    CategoryModel(
      id: 'expense_health',
      name: 'Health & Fitness',
      icon: '🏥',
      color: 0xFFFCBAD3,
      isDefault: true,
      categoryType: TransactionType.expense,
      description: 'Medical, gym, wellness',
    ),
    CategoryModel(
      id: 'expense_education',
      name: 'Education',
      icon: '📚',
      color: 0xFFFFD93D,
      isDefault: true,
      categoryType: TransactionType.expense,
      description: 'Courses, books, learning materials',
    ),
    CategoryModel(
      id: 'expense_travel',
      name: 'Travel',
      icon: '✈️',
      color: 0xFF6BCB77,
      isDefault: true,
      categoryType: TransactionType.expense,
      isCashbackEligible: true,
      cashbackRate: 0.02, // 2% cashback
      description: 'Flights, hotels, vacation expenses',
    ),
    CategoryModel(
      id: 'expense_other',
      name: 'Other',
      icon: '📦',
      color: 0xFF98C1D9,
      isDefault: true,
      categoryType: TransactionType.expense,
      description: 'Miscellaneous expenses',
    ),
  ];

  /// Get all default categories (income + expense)
  static List<CategoryModel> get allDefaultCategories => [
    ...incomeCategories,
    ...expenseCategories,
  ];

  /// Get categories by type
  static List<CategoryModel> getCategoriesByType(TransactionType type) {
    return type == TransactionType.income
        ? incomeCategories
        : expenseCategories;
  }

  /// Get cashback eligible categories
  static List<CategoryModel> get cashbackCategories {
    return expenseCategories.where((c) => c.isCashbackEligible).toList();
  }
}

/// Factory class for creating categories
class CategoryFactory {
  /// Create a new custom category
  static CategoryModel createCustom({
    required String name,
    required String icon,
    required int color,
    TransactionType? categoryType,
    bool isCashbackEligible = false,
    double? cashbackRate,
    String? description,
    double? budgetLimit,
    String? userId,
  }) {
    return CategoryModel(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      icon: icon,
      color: color,
      isDefault: false,
      categoryType: categoryType,
      isCashbackEligible: isCashbackEligible,
      cashbackRate: cashbackRate,
      description: description,
      budgetLimit: budgetLimit,
      userId: userId,
    );
  }

  /// Create an income category
  static CategoryModel createIncomeCategory({
    required String name,
    required String icon,
    required int color,
    String? description,
    String? userId,
  }) {
    return createCustom(
      name: name,
      icon: icon,
      color: color,
      categoryType: TransactionType.income,
      description: description,
      userId: userId,
    );
  }

  /// Create an expense category
  static CategoryModel createExpenseCategory({
    required String name,
    required String icon,
    required int color,
    bool isCashbackEligible = false,
    double? cashbackRate,
    String? description,
    double? budgetLimit,
    String? userId,
  }) {
    return createCustom(
      name: name,
      icon: icon,
      color: color,
      categoryType: TransactionType.expense,
      isCashbackEligible: isCashbackEligible,
      cashbackRate: cashbackRate,
      description: description,
      budgetLimit: budgetLimit,
      userId: userId,
    );
  }
}
