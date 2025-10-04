import 'constants.dart';

/// Utility class for input validation
class Validators {
  // Private constructor to prevent instantiation
  Validators._();

  // ==================== EMAIL VALIDATION ====================

  /// Validate email address
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final trimmed = value.trim();
    final emailRegex = RegExp(AppConstants.emailPattern);

    if (!emailRegex.hasMatch(trimmed)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  /// Check if email is valid (returns bool)
  static bool isValidEmail(String email) {
    return validateEmail(email) == null;
  }

  // ==================== PASSWORD VALIDATION ====================

  /// Validate password
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < AppConstants.minPasswordLength) {
      return 'Password must be at least ${AppConstants.minPasswordLength} characters';
    }

    if (value.length > AppConstants.maxPasswordLength) {
      return 'Password must not exceed ${AppConstants.maxPasswordLength} characters';
    }

    return null;
  }

  /// Validate password with strength requirements
  static String? validateStrongPassword(String? value) {
    final basicValidation = validatePassword(value);
    if (basicValidation != null) return basicValidation;

    final password = value!;

    // Check for uppercase
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    // Check for lowercase
    if (!password.contains(RegExp(r'[a-Z]'))) {
      return 'Password must contain at least one lowercase letter';
    }

    // Check for number
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    // Check for special character
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }

    return null;
  }

  /// Validate password confirmation
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  // ==================== NAME VALIDATION ====================

  /// Validate name
  static String? validateName(String? value, {String fieldName = 'Name'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    final trimmed = value.trim();

    if (trimmed.length < 2) {
      return '$fieldName must be at least 2 characters';
    }

    if (trimmed.length > 50) {
      return '$fieldName must not exceed 50 characters';
    }

    // Check for valid characters (letters, spaces, hyphens, apostrophes)
    if (!RegExp(r"^[a-zA-Z\s\-']+$").hasMatch(trimmed)) {
      return '$fieldName can only contain letters, spaces, hyphens, and apostrophes';
    }

    return null;
  }

  // ==================== AMOUNT VALIDATION ====================

  /// Validate transaction amount
  static String? validateAmount(String? value, {String fieldName = 'Amount'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    final cleaned = value.replaceAll(RegExp(r'[^\d.]'), '');
    final amount = double.tryParse(cleaned);

    if (amount == null) {
      return 'Please enter a valid amount';
    }

    if (amount < AppConstants.minTransactionAmount) {
      return '$fieldName must be at least \$${AppConstants.minTransactionAmount}';
    }

    if (amount > AppConstants.maxTransactionAmount) {
      return '$fieldName is too large';
    }

    // Check decimal places
    final parts = cleaned.split('.');
    if (parts.length == 2 && parts[1].length > 2) {
      return '$fieldName can have at most 2 decimal places';
    }

    return null;
  }

  /// Validate amount is positive
  static String? validatePositiveAmount(String? value) {
    final amountValidation = validateAmount(value);
    if (amountValidation != null) return amountValidation;

    final amount = double.parse(value!.replaceAll(RegExp(r'[^\d.]'), ''));
    if (amount <= 0) {
      return 'Amount must be greater than zero';
    }

    return null;
  }

  // ==================== TEXT VALIDATION ====================

  /// Validate required field
  static String? validateRequired(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validate note/description
  static String? validateNote(String? value, {int maxLength = AppConstants.maxNoteLength}) {
    if (value == null || value.isEmpty) {
      return null; // Note is optional
    }

    if (value.length > maxLength) {
      return 'Note must not exceed $maxLength characters';
    }

    return null;
  }

  /// Validate category name
  static String? validateCategoryName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Category name is required';
    }

    final trimmed = value.trim();

    if (trimmed.length < 2) {
      return 'Category name must be at least 2 characters';
    }

    if (trimmed.length > AppConstants.maxCategoryNameLength) {
      return 'Category name must not exceed ${AppConstants.maxCategoryNameLength} characters';
    }

    return null;
  }

  /// Validate minimum length
  static String? validateMinLength(String? value, int minLength, {String fieldName = 'Field'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    if (value.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }

    return null;
  }

  /// Validate maximum length
  static String? validateMaxLength(String? value, int maxLength, {String fieldName = 'Field'}) {
    if (value == null || value.isEmpty) {
      return null;
    }

    if (value.length > maxLength) {
      return '$fieldName must not exceed $maxLength characters';
    }

    return null;
  }

  // ==================== PHONE VALIDATION ====================

  /// Validate phone number
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }

    final cleaned = value.replaceAll(RegExp(r'\D'), '');

    if (cleaned.length < 10) {
      return 'Phone number must be at least 10 digits';
    }

    if (cleaned.length > 15) {
      return 'Phone number is too long';
    }

    return null;
  }

  /// Check if phone is valid (returns bool)
  static bool isValidPhone(String phone) {
    return validatePhone(phone) == null;
  }

  // ==================== DATE VALIDATION ====================

  /// Validate date is not in future
  static String? validateDateNotFuture(DateTime? date, {String fieldName = 'Date'}) {
    if (date == null) {
      return '$fieldName is required';
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDate = DateTime(date.year, date.month, date.day);

    if (selectedDate.isAfter(today)) {
      return '$fieldName cannot be in the future';
    }

    return null;
  }

  /// Validate date is within range
  static String? validateDateRange(
    DateTime? date,
    DateTime minDate,
    DateTime maxDate, {
    String fieldName = 'Date',
  }) {
    if (date == null) {
      return '$fieldName is required';
    }

    if (date.isBefore(minDate)) {
      return '$fieldName must be after ${minDate.toString().split(' ')[0]}';
    }

    if (date.isAfter(maxDate)) {
      return '$fieldName must be before ${maxDate.toString().split(' ')[0]}';
    }

    return null;
  }

  // ==================== NUMBER VALIDATION ====================

  /// Validate number is within range
  static String? validateNumberRange(
    num? value,
    num min,
    num max, {
    String fieldName = 'Value',
  }) {
    if (value == null) {
      return '$fieldName is required';
    }

    if (value < min) {
      return '$fieldName must be at least $min';
    }

    if (value > max) {
      return '$fieldName must not exceed $max';
    }

    return null;
  }

  /// Validate percentage (0-100)
  static String? validatePercentage(num? value) {
    return validateNumberRange(value, 0, 100, fieldName: 'Percentage');
  }

  /// Validate integer
  static String? validateInteger(String? value, {String fieldName = 'Value'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    final number = int.tryParse(value);
    if (number == null) {
      return 'Please enter a valid whole number';
    }

    return null;
  }

  // ==================== BUDGET VALIDATION ====================

  /// Validate budget amount
  static String? validateBudgetAmount(String? value) {
    final amountValidation = validateAmount(value, fieldName: 'Budget amount');
    if (amountValidation != null) return amountValidation;

    final amount = double.parse(value!.replaceAll(RegExp(r'[^\d.]'), ''));

    if (amount < AppConstants.minBudgetAmount) {
      return 'Budget must be at least \${AppConstants.minBudgetAmount}';
    }

    if (amount > AppConstants.maxBudgetAmount) {
      return 'Budget amount is too large';
    }

    return null;
  }

  /// Validate budget threshold (0.0 - 1.0)
  static String? validateBudgetThreshold(double? value) {
    if (value == null) {
      return 'Threshold is required';
    }

    if (value < 0.0 || value > 1.0) {
      return 'Threshold must be between 0% and 100%';
    }

    return null;
  }

  // ==================== CASHBACK VALIDATION ====================

  /// Validate cashback rate
  static String? validateCashbackRate(double? value) {
    if (value == null) {
      return 'Cashback rate is required';
    }

    if (value < AppConstants.minCashbackRate) {
      return 'Cashback rate must be at least ${(AppConstants.minCashbackRate * 100).toStringAsFixed(0)}%';
    }

    if (value > AppConstants.maxCashbackRate) {
      return 'Cashback rate cannot exceed ${(AppConstants.maxCashbackRate * 100).toStringAsFixed(0)}%';
    }

    return null;
  }

  // ==================== URL VALIDATION ====================

  /// Validate URL
  static String? validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'URL is required';
    }

    final urlPattern = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*),
    );

    if (!urlPattern.hasMatch(value.trim())) {
      return 'Please enter a valid URL';
    }

    return null;
  }

  // ==================== FILE VALIDATION ====================

  /// Validate file extension
  static String? validateFileExtension(
    String? filename,
    List<String> allowedExtensions,
  ) {
    if (filename == null || filename.isEmpty) {
      return 'File is required';
    }

    final extension = filename.split('.').last.toLowerCase();

    if (!allowedExtensions.contains(extension)) {
      return 'Only ${allowedExtensions.join(', ')} files are allowed';
    }

    return null;
  }

  /// Validate file size
  static String? validateFileSize(int? size, int maxSizeInBytes) {
    if (size == null) {
      return 'File size is required';
    }

    if (size > maxSizeInBytes) {
      final maxSizeMB = (maxSizeInBytes / (1024 * 1024)).toStringAsFixed(1);
      return 'File size must not exceed $maxSizeMB MB';
    }

    return null;
  }

  // ==================== CUSTOM VALIDATORS ====================

  /// Validate against custom regex pattern
  static String? validatePattern(
    String? value,
    String pattern,
    String errorMessage,
  ) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }

    final regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return errorMessage;
    }

    return null;
  }

  /// Validate custom condition
  static String? validateCondition(
    bool condition,
    String errorMessage,
  ) {
    return condition ? null : errorMessage;
  }

  /// Validate multiple conditions (all must pass)
  static String? validateMultiple(List<String? Function()> validators) {
    for (final validator in validators) {
      final result = validator();
      if (result != null) return result;
    }
    return null;
  }

  // ==================== SELECTION VALIDATION ====================

  /// Validate selection is made
  static String? validateSelection(dynamic value, {String fieldName = 'Selection'}) {
    if (value == null) {
      return 'Please select a $fieldName';
    }
    return null;
  }

  /// Validate at least one item is selected
  static String? validateListNotEmpty(List? list, {String fieldName = 'Item'}) {
    if (list == null || list.isEmpty) {
      return 'Please select at least one $fieldName';
    }
    return null;
  }

  // ==================== COMPARISON VALIDATORS ====================

  /// Validate value is greater than another
  static String? validateGreaterThan(
    num? value,
    num compareValue, {
    String fieldName = 'Value',
  }) {
    if (value == null) {
      return '$fieldName is required';
    }

    if (value <= compareValue) {
      return '$fieldName must be greater than $compareValue';
    }

    return null;
  }

  /// Validate value is less than another
  static String? validateLessThan(
    num? value,
    num compareValue, {
    String fieldName = 'Value',
  }) {
    if (value == null) {
      return '$fieldName is required';
    }

    if (value >= compareValue) {
      return '$fieldName must be less than $compareValue';
    }

    return null;
  }

  // ==================== COMPOSITE VALIDATORS ====================

  /// Combine multiple validators
  static String? Function(String?) combineValidators(
    List<String? Function(String?)> validators,
  ) {
    return (value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) return result;
      }
      return null;
    };
  }

  // ==================== HELPER METHODS ====================

  /// Check if string is empty or null
  static bool isEmpty(String? value) {
    return value == null || value.trim().isEmpty;
  }

  /// Check if value is numeric
  static bool isNumeric(String? value) {
    if (value == null) return false;
    return double.tryParse(value) != null;
  }

  /// Check if value is integer
  static bool isInteger(String? value) {
    if (value == null) return false;
    return int.tryParse(value) != null;
  }

  /// Check if string contains only letters
  static bool isAlpha(String value) {
    return RegExp(r'^[a-zA-Z]+).hasMatch(value);
  }

  /// Check if string contains only alphanumeric characters
  static bool isAlphanumeric(String value) {
    return RegExp(r'^[a-zA-Z0-9]+).hasMatch(value);
  }
}

/// Extension methods for easier validation
extension ValidationExtension on String? {
  /// Validate as email
  String? get validateEmail => Validators.validateEmail(this);

  /// Validate as password
  String? get validatePassword => Validators.validatePassword(this);

  /// Validate as required field
  String? validateRequired([String fieldName = 'This field']) {
    return Validators.validateRequired(this, fieldName: fieldName);
  }

  /// Validate as amount
  String? get validateAmount => Validators.validateAmount(this);

  /// Check if empty
  bool get isEmpty => Validators.isEmpty(this);

  /// Check if numeric
  bool get isNumeric => Validators.isNumeric(this);
}