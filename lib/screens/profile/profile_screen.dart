import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/notification_service.dart';
import '../../utils/constants.dart';
import '../auth/login_screen.dart';
import '../orders/orders_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();
    final themeProv = context.watch<ThemeProvider>();
    final user = auth.user;

    final initial = (user?.name.isNotEmpty == true)
        ? user!.name[0].toUpperCase()
        : 'U';

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Account'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // User Profile Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: theme.colorScheme.primary,
                    child: Text(
                      initial,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'ShopEase Shopper',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? 'user@shopease.com',
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.textTheme.bodyMedium?.color
                                ?.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 10),
                        InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const EditProfileScreen(),
                              ),
                            );
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.edit_outlined,
                                size: 14,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Edit Profile',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Settings Section
            _buildSectionHeader('Preferences & Settings'),
            const SizedBox(height: 10),

            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                children: [
                  // Dark Mode Switch
                  SwitchListTile(
                    secondary: Icon(
                      themeProv.isDarkMode
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
                      color: theme.colorScheme.primary,
                    ),
                    title: const Text(
                      'Dark Mode',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      themeProv.isDarkMode
                          ? 'Sleek dark interface active'
                          : 'Standard light interface active',
                      style: const TextStyle(fontSize: 12),
                    ),
                    value: themeProv.isDarkMode,
                    onChanged: (val) => themeProv.toggleTheme(val),
                  ),
                  const Divider(height: 1),

                  // Push Notifications Info
                  ListTile(
                    leading: Icon(
                      Icons.notifications_active_outlined,
                      color: theme.colorScheme.primary,
                    ),
                    title: const Text(
                      'Push Notifications (FCM)',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      NotificationService().fcmToken != null
                          ? 'FCM Connected & Ready'
                          : 'In-app push notifications enabled',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: const Icon(Icons.check_circle,
                        color: Color(0xFF10B981), size: 18),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Account Shortcuts
            _buildSectionHeader('Orders & Support'),
            const SizedBox(height: 10),

            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.receipt_long_rounded),
                    title: const Text('Order History'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const OrdersScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.info_outline_rounded),
                    title: const Text('About & Play Store Release'),
                    subtitle: const Text('Version 1.0.0 (Production Ready)',
                        style: TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: AppConstants.appName,
                        applicationVersion: AppConstants.appVersion,
                        applicationLegalese:
                            '© 2026 ShopEase Inc. All rights reserved.\nEngineered for Google Play Store with Material 3 & Firebase.',
                        applicationIcon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.shopping_bag_rounded,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Logout Button
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFEF4444),
                side: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.logout_rounded),
              label: const Text(
                'Log Out',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Confirm Logout'),
                    content: const Text(
                      'Are you sure you want to log out of your ShopEase account?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.of(ctx).pop();
                          await auth.signOut();
                          if (context.mounted) {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                              (route) => false,
                            );
                          }
                        },
                        child: const Text(
                          'Log Out',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFF64748B),
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
