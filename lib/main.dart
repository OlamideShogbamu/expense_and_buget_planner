import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'models/transaction_model.dart';
import 'models/category_model.dart';
import 'models/budget_model.dart';
import 'models/transaction_type.dart';

import 'services/data_service.dart';

import 'screens/auth/splash_screen.dart';

import 'theme/app_theme.dart';
import 'theme/colors.dart';
import 'utils/constants.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive adapters
  Hive.registerAdapter(TransactionModelAdapter());
  Hive.registerAdapter(CategoryModelAdapter());
  Hive.registerAdapter(BudgetModelAdapter());
  Hive.registerAdapter(TransactionTypeAdapter());

  // Open Hive boxes
  await Hive.openBox<TransactionModel>('transactions');
  await Hive.openBox<CategoryModel>('categories');
  await Hive.openBox<BudgetModel>('budgets');
  await Hive.openBox('settings');
  await Hive.openBox('user');

  // Initialize default categories if empty
  final categoryBox = Hive.box<CategoryModel>('categories');
  if (categoryBox.isEmpty) {
    await _initializeDefaultCategories();
  }

  // Run the app
  runApp(const ExpensePlannerApp());
}

/// Initialize default categories for first-time users
Future<void> _initializeDefaultCategories() async {
  final defaultCategories = [
    CategoryModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'Food & Dining',
      icon: '🍽️',
      color: 0xFFFF6B6B,
    ),
    CategoryModel(
      id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
      name: 'Transportation',
      icon: '🚗',
      color: 0xFF4ECDC4,
    ),
    CategoryModel(
      id: (DateTime.now().millisecondsSinceEpoch + 2).toString(),
      name: 'Shopping',
      icon: '🛍️',
      color: 0xFF95E1D3,
    ),
    CategoryModel(
      id: (DateTime.now().millisecondsSinceEpoch + 3).toString(),
      name: 'Bills & Utilities',
      icon: '📄',
      color: 0xFFF38181,
    ),
    CategoryModel(
      id: (DateTime.now().millisecondsSinceEpoch + 4).toString(),
      name: 'Entertainment',
      icon: '🎮',
      color: 0xFFAA96DA,
    ),
    CategoryModel(
      id: (DateTime.now().millisecondsSinceEpoch + 5).toString(),
      name: 'Health & Fitness',
      icon: '🏥',
      color: 0xFFFCBAD3,
    ),
    CategoryModel(
      id: (DateTime.now().millisecondsSinceEpoch + 6).toString(),
      name: 'Education',
      icon: '📚',
      color: 0xFFFFD93D,
    ),
    CategoryModel(
      id: (DateTime.now().millisecondsSinceEpoch + 7).toString(),
      name: 'Travel',
      icon: '✈️',
      color: 0xFF6BCB77,
    ),
    CategoryModel(
      id: (DateTime.now().millisecondsSinceEpoch + 8).toString(),
      name: 'Salary',
      icon: '💰',
      color: 0xFF58641D,
    ),
    CategoryModel(
      id: (DateTime.now().millisecondsSinceEpoch + 9).toString(),
      name: 'Investment',
      icon: '📈',
      color: 0xFF7B904B,
    ),
    CategoryModel(
      id: (DateTime.now().millisecondsSinceEpoch + 10).toString(),
      name: 'Freelance',
      icon: '💼',
      color: 0xFF3D5A80,
    ),
    CategoryModel(
      id: (DateTime.now().millisecondsSinceEpoch + 11).toString(),
      name: 'Gifts',
      icon: '🎁',
      color: 0xFFEE6C4D,
    ),
    CategoryModel(
      id: (DateTime.now().millisecondsSinceEpoch + 12).toString(),
      name: 'Other',
      icon: '📦',
      color: 0xFF98C1D9,
    ),
  ];

  final categoryBox = Hive.box<CategoryModel>('categories');
  for (var category in defaultCategories) {
    await categoryBox.add(category);
  }

  debugPrint('Default categories initialized: ${defaultCategories.length}');
}

/// Main application widget
class ExpensePlannerApp extends StatelessWidget {
  const ExpensePlannerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Expense Planner',
      debugShowCheckedModeBanner: false,

      // Theme configuration
      theme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,

      // Initial route
      home: const SplashScreen(),

      // Navigation
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },
    );
  }
}

/// App Configuration
class AppConfig {
  // App metadata
  static const String appName = 'Smart Expense Planner';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  // Feature flags
  static const bool enableFirebaseAuth = true;
  static const bool enableGoogleSignIn = true;
  static const bool enableBiometricAuth = false;
  static const bool enableCloudBackup = false;

  // Analytics
  static const bool enableAnalytics = false;
  static const bool enableCrashReporting = false;

  // Currency
  static const String defaultCurrency = 'USD';
  static const String currencySymbol = '\$';

  // Date format
  static const String dateFormat = 'MMM dd, yyyy';
  static const String monthYearFormat = 'MMMM yyyy';

  // Cashback rates
  static const double shoppingCashbackRate = 0.05; // 5%
  static const double diningCashbackRate = 0.03; // 3%
  static const double travelCashbackRate = 0.02; // 2%

  // Budget alerts
  static const double budgetWarningThreshold = 0.80; // 80%
  static const double budgetCriticalThreshold = 0.95; // 95%

  // Pagination
  static const int transactionsPerPage = 20;
  static const int categoriesPerPage = 10;

  // Chart settings
  static const int maxChartDataPoints = 30;
  static const int pieChartMaxSlices = 6;

  // Backup
  static const String backupFilePrefix = 'expense_backup_';
  static const String backupFileExtension = '.csv';

  // Validation
  static const double minTransactionAmount = 0.01;
  static const double maxTransactionAmount = 999999999.99;
  static const int maxNoteLength = 200;
  static const int maxCategoryNameLength = 30;

  // Cache duration
  static const Duration cacheDuration = Duration(hours: 1);

  // Animation durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
}

/// Global error handler
class AppErrorHandler {
  static void handleError(dynamic error, StackTrace stackTrace) {
    debugPrint('Error: $error');
    debugPrint('StackTrace: $stackTrace');

    // Log to crash reporting service if enabled
    if (AppConfig.enableCrashReporting) {
      // TODO: Send to Firebase Crashlytics or similar service
    }
  }

  static void handleAuthError(dynamic error) {
    debugPrint('Authentication Error: $error');
    // Handle specific auth errors
  }

  static void handleDatabaseError(dynamic error) {
    debugPrint('Database Error: $error');
    // Handle database-specific errors
  }

  static void handleNetworkError(dynamic error) {
    debugPrint('Network Error: $error');
    // Handle network-specific errors
  }
}
