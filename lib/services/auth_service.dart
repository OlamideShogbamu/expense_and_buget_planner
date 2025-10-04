import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';

/// Service for handling authentication operations
/// Supports email/password and Google Sign-In
class AuthService {
  // Firebase Auth instance
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Google Sign-In disabled for now

  // Hive box for user data
  static Box get _userBox => Hive.box('user');

  // ==================== USER STATE ====================

  /// Get current user
  static User? get currentUser => _auth.currentUser;

  /// Check if user is signed in
  static bool get isSignedIn => currentUser != null;

  /// Get current user ID
  static String? get currentUserId => currentUser?.uid;

  /// Get current user email
  static String? get currentUserEmail => currentUser?.email;

  /// Get current user display name
  static String? get currentUserDisplayName => currentUser?.displayName;

  /// Get current user photo URL
  static String? get currentUserPhotoUrl => currentUser?.photoURL;

  /// Stream of auth state changes
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Stream of user changes
  static Stream<User?> get userChanges => _auth.userChanges();

  // ==================== EMAIL/PASSWORD AUTHENTICATION ====================

  /// Sign up with email and password
  static Future<AuthResult> signUpWithEmailPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      // Validate email and password
      final validation = _validateEmailPassword(email, password);
      if (!validation.success) {
        return AuthResult(success: false, message: validation.message);
      }

      // Create user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Update display name if provided
      if (displayName != null && displayName.isNotEmpty) {
        await userCredential.user?.updateDisplayName(displayName);
      }

      // Send email verification
      await userCredential.user?.sendEmailVerification();

      // Save user data locally
      await _saveUserDataLocally(userCredential.user);

      return AuthResult(
        success: true,
        message: 'Account created successfully! Please verify your email.',
        user: userCredential.user,
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult(
        success: false,
        message: _getFirebaseAuthErrorMessage(e.code),
        errorCode: e.code,
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'An unexpected error occurred. Please try again.',
      );
    }
  }

  /// Sign in with email and password
  static Future<AuthResult> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      // Validate email and password
      final validation = _validateEmailPassword(email, password);
      if (!validation.success) {
        return AuthResult(success: false, message: validation.message);
      }

      // Sign in
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Save user data locally
      await _saveUserDataLocally(userCredential.user);

      return AuthResult(
        success: true,
        message: 'Welcome back!',
        user: userCredential.user,
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult(
        success: false,
        message: _getFirebaseAuthErrorMessage(e.code),
        errorCode: e.code,
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'An unexpected error occurred. Please try again.',
      );
    }
  }

  // ==================== GOOGLE SIGN-IN ====================

  /// Sign in with Google (currently disabled)
  static Future<AuthResult> signInWithGoogle() async {
    return AuthResult(
      success: false,
      message: 'Google Sign-In is currently unavailable. Please use email/password.',
    );
  }

  // ==================== PASSWORD RESET ====================

  /// Send password reset email
  static Future<AuthResult> sendPasswordResetEmail(String email) async {
    try {
      if (email.isEmpty || !_isValidEmail(email)) {
        return AuthResult(
          success: false,
          message: 'Please enter a valid email address',
        );
      }

      await _auth.sendPasswordResetEmail(email: email.trim());

      return AuthResult(
        success: true,
        message: 'Password reset email sent. Please check your inbox.',
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult(
        success: false,
        message: _getFirebaseAuthErrorMessage(e.code),
        errorCode: e.code,
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Failed to send password reset email. Please try again.',
      );
    }
  }

  /// Confirm password reset with code
  static Future<AuthResult> confirmPasswordReset({
    required String code,
    required String newPassword,
  }) async {
    try {
      if (newPassword.length < 6) {
        return AuthResult(
          success: false,
          message: 'Password must be at least 6 characters',
        );
      }

      await _auth.confirmPasswordReset(code: code, newPassword: newPassword);

      return AuthResult(
        success: true,
        message:
            'Password reset successful. Please sign in with your new password.',
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult(
        success: false,
        message: _getFirebaseAuthErrorMessage(e.code),
        errorCode: e.code,
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Failed to reset password. Please try again.',
      );
    }
  }

  // ==================== USER PROFILE MANAGEMENT ====================

  /// Update user display name
  static Future<AuthResult> updateDisplayName(String displayName) async {
    try {
      if (displayName.isEmpty) {
        return AuthResult(
          success: false,
          message: 'Display name cannot be empty',
        );
      }

      await currentUser?.updateDisplayName(displayName.trim());
      await currentUser?.reload();

      // Update local storage
      await _userBox.put('displayName', displayName.trim());

      return AuthResult(
        success: true,
        message: 'Display name updated successfully',
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Failed to update display name',
      );
    }
  }

  /// Update user email
  static Future<AuthResult> updateEmail(String newEmail) async {
    try {
      if (!_isValidEmail(newEmail)) {
        return AuthResult(
          success: false,
          message: 'Please enter a valid email address',
        );
      }

      await currentUser?.verifyBeforeUpdateEmail(newEmail.trim());
      await currentUser?.sendEmailVerification();
      await currentUser?.reload();

      // Update local storage
      await _userBox.put('email', newEmail.trim());

      return AuthResult(
        success: true,
        message: 'Email updated. Please verify your new email address.',
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult(
        success: false,
        message: _getFirebaseAuthErrorMessage(e.code),
        errorCode: e.code,
      );
    } catch (e) {
      return AuthResult(success: false, message: 'Failed to update email');
    }
  }

  /// Update user password
  static Future<AuthResult> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      if (newPassword.length < 6) {
        return AuthResult(
          success: false,
          message: 'New password must be at least 6 characters',
        );
      }

      // Re-authenticate user before changing password
      final email = currentUser?.email;
      if (email == null) {
        return AuthResult(success: false, message: 'User not found');
      }

      final credential = EmailAuthProvider.credential(
        email: email,
        password: currentPassword,
      );

      await currentUser?.reauthenticateWithCredential(credential);
      await currentUser?.updatePassword(newPassword);

      return AuthResult(
        success: true,
        message: 'Password updated successfully',
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult(
        success: false,
        message: _getFirebaseAuthErrorMessage(e.code),
        errorCode: e.code,
      );
    } catch (e) {
      return AuthResult(success: false, message: 'Failed to update password');
    }
  }

  /// Send email verification
  static Future<AuthResult> sendEmailVerification() async {
    try {
      if (currentUser == null) {
        return AuthResult(success: false, message: 'No user signed in');
      }

      if (currentUser!.emailVerified) {
        return AuthResult(success: false, message: 'Email is already verified');
      }

      await currentUser!.sendEmailVerification();

      return AuthResult(
        success: true,
        message: 'Verification email sent. Please check your inbox.',
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult(
        success: false,
        message: _getFirebaseAuthErrorMessage(e.code),
        errorCode: e.code,
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Failed to send verification email',
      );
    }
  }

  /// Check if email is verified
  static Future<bool> checkEmailVerified() async {
    await currentUser?.reload();
    return currentUser?.emailVerified ?? false;
  }

  // ==================== SIGN OUT ====================

  /// Sign out current user
  static Future<AuthResult> signOut() async {
    try {
      // Google Sign-In disabled

      // Sign out from Firebase
      await _auth.signOut();

      // Clear local user data
      await _clearUserDataLocally();

      return AuthResult(success: true, message: 'Signed out successfully');
    } catch (e) {
      return AuthResult(success: false, message: 'Failed to sign out');
    }
  }

  // ==================== ACCOUNT DELETION ====================

  /// Delete user account
  static Future<AuthResult> deleteAccount(String password) async {
    try {
      final email = currentUser?.email;
      if (email == null) {
        return AuthResult(success: false, message: 'User not found');
      }

      // Re-authenticate before deletion
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      await currentUser?.reauthenticateWithCredential(credential);

      // Delete user account
      await currentUser?.delete();

      // Clear local data
      await _clearUserDataLocally();

      return AuthResult(success: true, message: 'Account deleted successfully');
    } on FirebaseAuthException catch (e) {
      return AuthResult(
        success: false,
        message: _getFirebaseAuthErrorMessage(e.code),
        errorCode: e.code,
      );
    } catch (e) {
      return AuthResult(success: false, message: 'Failed to delete account');
    }
  }

  // ==================== LOCAL DATA MANAGEMENT ====================

  /// Save user data locally
  static Future<void> _saveUserDataLocally(User? user) async {
    if (user == null) return;

    await _userBox.put('userId', user.uid);
    await _userBox.put('email', user.email);
    await _userBox.put('displayName', user.displayName);
    await _userBox.put('photoUrl', user.photoURL);
    await _userBox.put('emailVerified', user.emailVerified);
    await _userBox.put('lastSignIn', DateTime.now().toIso8601String());
  }

  /// Clear user data locally
  static Future<void> _clearUserDataLocally() async {
    await _userBox.clear();
  }

  /// Get locally saved user data
  static Map<String, dynamic>? getLocalUserData() {
    if (_userBox.isEmpty) return null;

    return {
      'userId': _userBox.get('userId'),
      'email': _userBox.get('email'),
      'displayName': _userBox.get('displayName'),
      'photoUrl': _userBox.get('photoUrl'),
      'emailVerified': _userBox.get('emailVerified'),
      'lastSignIn': _userBox.get('lastSignIn'),
    };
  }

  // ==================== VALIDATION ====================

  /// Validate email and password
  static AuthResult _validateEmailPassword(String email, String password) {
    if (email.isEmpty) {
      return AuthResult(
        success: false,
        message: 'Please enter your email address',
      );
    }

    if (!_isValidEmail(email)) {
      return AuthResult(
        success: false,
        message: 'Please enter a valid email address',
      );
    }

    if (password.isEmpty) {
      return AuthResult(success: false, message: 'Please enter your password');
    }

    if (password.length < 6) {
      return AuthResult(
        success: false,
        message: 'Password must be at least 6 characters',
      );
    }

    return AuthResult(success: true, message: 'Valid');
  }

  /// Check if email is valid
  static bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email.trim());
  }

  // ==================== ERROR MESSAGES ====================

  /// Get user-friendly error message from Firebase error code
  static String _getFirebaseAuthErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'email-already-in-use':
        return 'This email is already registered. Please sign in instead.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'operation-not-allowed':
        return 'This operation is not allowed. Please contact support.';
      case 'weak-password':
        return 'Password is too weak. Please use a stronger password.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'user-not-found':
        return 'No account found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-credential':
        return 'Invalid credentials. Please check your email and password.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with this email but different sign-in method.';
      case 'requires-recent-login':
        return 'This operation requires recent authentication. Please sign in again.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}

// ==================== AUTH RESULT CLASS ====================

/// Class representing the result of an authentication operation
class AuthResult {
  final bool success;
  final String message;
  final String? errorCode;
  final User? user;

  AuthResult({
    required this.success,
    required this.message,
    this.errorCode,
    this.user,
  });

  @override
  String toString() {
    return 'AuthResult(success: $success, message: $message, errorCode: $errorCode)';
  }
}
