import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../services/auth_service.dart';
import '../../services/data_service.dart';
import '../../services/csv_service.dart';
import '../categories/categories_screen.dart';
import '../auth/auth_screen.dart';

/// Settings screen for app configuration
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    final isGuest = user == null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildProfileCard(context, user, isGuest),
              const SizedBox(height: 24),
              _buildSection(context, 'General', [
                _buildSettingTile(
                  context,
                  'Categories',
                  'Manage expense and income categories',
                  Icons.category_outlined,
                  AppColors.secondary,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CategoriesScreen(),
                      ),
                    );
                  },
                ),
                _buildSettingTile(
                  context,
                  'Currency',
                  'USD (\$)',
                  Icons.attach_money,
                  AppColors.success,
                  () {
                    _showComingSoonDialog(context);
                  },
                ),
              ]),
              const SizedBox(height: 24),
              _buildSection(context, 'Data Management', [
                _buildSettingTile(
                  context,
                  'Export Data',
                  'Export transactions to CSV',
                  Icons.file_download_outlined,
                  AppColors.info,
                  () => _exportData(context),
                ),
                _buildSettingTile(
                  context,
                  'Import Data',
                  'Import transactions from CSV',
                  Icons.file_upload_outlined,
                  AppColors.warning,
                  () => _importData(context),
                ),
                _buildSettingTile(
                  context,
                  'Clear All Data',
                  'Delete all transactions and budgets',
                  Icons.delete_outline,
                  AppColors.error,
                  () => _clearAllData(context),
                ),
              ]),
              const SizedBox(height: 24),
              _buildSection(context, 'About', [
                _buildSettingTile(
                  context,
                  'App Version',
                  '1.0.0',
                  Icons.info_outline,
                  AppColors.textSecondary,
                  null,
                ),
                _buildSettingTile(
                  context,
                  'Privacy Policy',
                  'View our privacy policy',
                  Icons.privacy_tip_outlined,
                  AppColors.textSecondary,
                  () {
                    _showComingSoonDialog(context);
                  },
                ),
                _buildSettingTile(
                  context,
                  'Terms of Service',
                  'View terms and conditions',
                  Icons.description_outlined,
                  AppColors.textSecondary,
                  () {
                    _showComingSoonDialog(context);
                  },
                ),
              ]),
              const SizedBox(height: 24),
              if (!isGuest) _buildSignOutButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Text(
      'Settings',
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, dynamic user, bool isGuest) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isGuest ? Icons.person_outline : Icons.person,
              color: AppColors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isGuest ? 'Guest User' : (user.displayName ?? 'User'),
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isGuest ? 'Using app without account' : (user.email ?? ''),
                  style: TextStyle(
                    color: AppColors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          if (isGuest)
            IconButton(
              icon: const Icon(Icons.login, color: AppColors.white),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const AuthScreen()),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color iconColor,
    VoidCallback? onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.arrow_forward_ios,
                color: AppColors.textTertiary,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignOutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: () => _signOut(context),
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
        icon: const Icon(Icons.logout, color: AppColors.white),
        label: const Text(
          'Sign Out',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }

  Future<void> _exportData(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final result = await CSVService.exportAllDataToCSV();

    Navigator.pop(context); // Close loading dialog

    if (result.success) {
      _showSnackBar(context, result.message, isError: false);
    } else {
      _showSnackBar(context, result.message, isError: true);
    }
  }

  Future<void> _importData(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Data'),
        content: const Text(
          'This will import transactions from a CSV file. Existing data will not be affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Import'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final result = await CSVService.importTransactionsFromCSV();

    Navigator.pop(context); // Close loading dialog

    if (result.success) {
      _showSnackBar(
        context,
        '${result.recordCount} transactions imported successfully',
        isError: false,
      );
    } else {
      _showSnackBar(context, result.message, isError: true);
    }
  }

  Future<void> _clearAllData(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all your transactions and budgets. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await DataService.clearAllData();

    if (context.mounted) {
      _showSnackBar(context, 'All data cleared successfully', isError: false);
    }
  }

  Future<void> _signOut(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await AuthService.signOut();

    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AuthScreen()),
      );
    }
  }

  void _showComingSoonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Coming Soon'),
        content: const Text(
          'This feature will be available in a future update.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
