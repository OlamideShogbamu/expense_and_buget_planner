/// App-wide constants and configuration values
class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();

  // ==================== APP INFORMATION ====================

  static const String appName = 'Smart Expense Planner';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';
  static const String appPackageName = 'com.expense.planner';

  // ==================== CURRENCY ====================

  static const String defaultCurrency = 'USD';
  static const String currencySymbol = '\$';
  static const String currencyCode = 'USD';

  // Supported currencies (for future expansion)
  static const List<String> supportedCurrencies = [
    'USD',
    'EUR',
    'GBP',
    'NGN',
    'INR',
    'JPY',
    'CNY',
  ];

  static const Map<String, String> currencySymbols = {
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
    'NGN': '₦',
    'INR': '₹',
    'JPY': '¥',
    'CNY': '¥',
  };

  // ==================== DATE & TIME FORMATS ====================

  static const String dateFormat = 'MMM dd, yyyy';
  static const String dateFormatFull = 'MMMM dd, yyyy';
  static const String dateFormatShort = 'MM/dd/yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'MMM dd, yyyy HH:mm';
  static const String monthYearFormat = 'MMMM yyyy';
  static const String monthFormat = 'MMM yyyy';
  static const String yearFormat = 'yyyy';

  // ==================== VALIDATION LIMITS ====================

  static const double minTransactionAmount = 0.01;
  static const double maxTransactionAmount = 999999999.99;
  static const int maxNoteLength = 200;
  static const int maxCategoryNameLength = 30;
  static const int maxBudgetNoteLength = 100;
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;

  // ==================== CASHBACK RATES ====================

  static const double shoppingCashbackRate = 0.05; // 5%
  static const double diningCashbackRate = 0.03; // 3%
  static const double travelCashbackRate = 0.02; // 2%
  static const double groceriesCashbackRate = 0.02; // 2%
  static const double minCashbackRate = 0.01; // 1%
  static const double maxCashbackRate = 0.10; // 10%

  // ==================== BUDGET SETTINGS ====================

  static const double budgetWarningThreshold = 0.80; // 80%
  static const double budgetCriticalThreshold = 0.95; // 95%
  static const double minBudgetAmount = 1.0;
  static const double maxBudgetAmount = 999999999.99;

  // ==================== PAGINATION ====================

  static const int transactionsPerPage = 20;
  static const int categoriesPerPage = 10;
  static const int budgetsPerPage = 10;
  static const int transactionsLoadMoreThreshold = 5;

  // ==================== CHART SETTINGS ====================

  static const int maxChartDataPoints = 31; // Days in month
  static const int pieChartMaxSlices = 6;
  static const int barChartMaxBars = 31;
  static const int topCategoriesLimit = 5;

  // ==================== FILE OPERATIONS ====================

  static const String backupFilePrefix = 'expense_backup_';
  static const String backupFileExtension = '.csv';
  static const String backupDateFormat = 'yyyyMMdd_HHmmss';
  static const int maxBackupFiles = 10;

  // Allowed file extensions for import
  static const List<String> allowedImportExtensions = ['csv'];

  // ==================== CACHE DURATION ====================

  static const Duration cacheDuration = Duration(hours: 1);
  static const Duration sessionTimeout = Duration(hours: 24);
  static const Duration networkTimeout = Duration(seconds: 30);

  // ==================== ANIMATION DURATIONS ====================

  static const Duration fastAnimation = Duration(milliseconds: 150);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);
  static const Duration verySlowAnimation = Duration(milliseconds: 1000);

  // ==================== UI CONSTANTS ====================

  static const double defaultPadding = 16.0;
  static const double defaultMargin = 8.0;
  static const double defaultBorderRadius = 12.0;
  static const double cardElevation = 2.0;
  static const double iconSize = 24.0;
  static const double avatarSize = 48.0;

  // ==================== ANALYTICS ====================

  static const int minTransactionsForInsights = 3;
  static const int daysForTrendAnalysis = 30;
  static const int monthsForYearlyAnalysis = 12;

  // ==================== NOTIFICATIONS ====================

  static const String notificationChannelId = 'expense_planner_notifications';
  static const String notificationChannelName = 'Expense Planner';
  static const String notificationChannelDescription =
      'Budget alerts and reminders';

  // ==================== STORAGE KEYS ====================

  static const String keyUserId = 'user_id';
  static const String keyUserEmail = 'user_email';
  static const String keyUserName = 'user_name';
  static const String keyIsFirstLaunch = 'is_first_launch';
  static const String keyLastBackupDate = 'last_backup_date';
  static const String keyThemeMode = 'theme_mode';
  static const String keyCurrency = 'currency';
  static const String keyNotificationsEnabled = 'notifications_enabled';

  // ==================== API & ENDPOINTS (for future use) ====================

  static const String baseUrl = 'https://api.expenseplanner.com';
  static const String apiVersion = 'v1';

  // ==================== DEFAULT VALUES ====================

  static const int defaultTransactionLimit = 100;
  static const String defaultCategoryIcon = '📦';
  static const int defaultCategoryColor = 0xFF98C1D9;

  // ==================== ERROR MESSAGES ====================

  static const String errorGeneric = 'Something went wrong. Please try again.';
  static const String errorNetwork =
      'No internet connection. Please check your network.';
  static const String errorTimeout = 'Request timed out. Please try again.';
  static const String errorInvalidData = 'Invalid data provided.';
  static const String errorPermissionDenied = 'Permission denied.';

  // ==================== SUCCESS MESSAGES ====================

  static const String successTransactionAdded =
      'Transaction added successfully';
  static const String successTransactionUpdated =
      'Transaction updated successfully';
  static const String successTransactionDeleted =
      'Transaction deleted successfully';
  static const String successBudgetCreated = 'Budget created successfully';
  static const String successBudgetUpdated = 'Budget updated successfully';
  static const String successCategoryCreated = 'Category created successfully';
  static const String successDataExported = 'Data exported successfully';
  static const String successDataImported = 'Data imported successfully';

  // ==================== REGEX PATTERNS ====================

  static const String emailPattern =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String phonePattern = r'^\+?[\d\s\-\(\)]+$';
  static const String amountPattern = r'^\d+\.?\d{0,2}$';

  // ==================== FIREBASE COLLECTIONS (for future cloud sync) ====================

  static const String collectionUsers = 'users';
  static const String collectionTransactions = 'transactions';
  static const String collectionBudgets = 'budgets';
  static const String collectionCategories = 'categories';

  // ==================== FEATURE FLAGS ====================

  static const bool enableFirebaseAuth = true;
  static const bool enableGoogleSignIn = true;
  static const bool enableBiometricAuth = false;
  static const bool enableCloudBackup = false;
  static const bool enableAnalytics = false;
  static const bool enableCrashReporting = false;
  static const bool enableNotifications = true;
  static const bool enableDarkMode = true;

  // ==================== LINKS ====================

  static const String privacyPolicyUrl = 'https://expenseplanner.com/privacy';
  static const String termsOfServiceUrl = 'https://expenseplanner.com/terms';
  static const String supportEmail = 'support@expenseplanner.com';
  static const String websiteUrl = 'https://expenseplanner.com';

  // ==================== SOCIAL MEDIA ====================

  static const String twitterHandle = '@ExpensePlanner';
  static const String facebookPage = 'ExpensePlannerApp';
  static const String instagramHandle = '@expenseplanner';

  // ==================== RATING & FEEDBACK ====================

  static const int minTransactionsBeforeRatingPrompt = 10;
  static const int daysBeforeRatingPrompt = 7;

  // ==================== ONBOARDING ====================

  static const int onboardingScreensCount = 3;
  static const bool skipOnboardingAfterFirstLaunch = true;

  // ==================== SEARCH ====================

  static const int minSearchQueryLength = 2;
  static const int searchResultsLimit = 50;
  static const Duration searchDebounceDelay = Duration(milliseconds: 500);
}

/// Payment methods
class PaymentMethods {
  PaymentMethods._();

  static const String cash = 'Cash';
  static const String creditCard = 'Credit Card';
  static const String debitCard = 'Debit Card';
  static const String bankTransfer = 'Bank Transfer';
  static const String mobilePayment = 'Mobile Payment';
  static const String other = 'Other';

  static const List<String> all = [
    cash,
    creditCard,
    debitCard,
    bankTransfer,
    mobilePayment,
    other,
  ];
}

/// Transaction tags
class TransactionTags {
  TransactionTags._();

  static const String essential = 'Essential';
  static const String nonEssential = 'Non-Essential';
  static const String recurring = 'Recurring';
  static const String oneTime = 'One-Time';
  static const String planned = 'Planned';
  static const String unplanned = 'Unplanned';

  static const List<String> all = [
    essential,
    nonEssential,
    recurring,
    oneTime,
    planned,
    unplanned,
  ];
}

/// Budget frequencies
class BudgetFrequencies {
  BudgetFrequencies._();

  static const String daily = 'Daily';
  static const String weekly = 'Weekly';
  static const String monthly = 'Monthly';
  static const String yearly = 'Yearly';

  static const List<String> all = [daily, weekly, monthly, yearly];
}
