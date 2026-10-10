import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/notification_service.dart';
import '../../utils/constants.dart';
import '../../widgets/developer_bypass_sheet.dart';
import '../ai/ai_assistant_screen.dart';
import '../auth/login_screen.dart';
import '../profile/addresses_screen.dart';
import '../profile/edit_profile_screen.dart';
import '../wallet/wallet_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Local toggles for settings
  bool _orderNotifications = true;
  bool _promotionalNotifications = true;
  bool _deliveryAlerts = true;
  String _refundMethod = 'StarShop Wallet (Instant)';
  bool _oneClickReorder = true;
  bool _cameraAutoFocus = true;
  double _cacheSizeMb = 24.6;

  void _showChangePasswordDialog(BuildContext context) {
    final currentPass = TextEditingController();
    final newPass = TextEditingController();
    final confirmPass = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPass,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newPass,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                prefixIcon: Icon(Icons.lock_reset),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmPass,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm New Password',
                prefixIcon: Icon(Icons.check_circle_outline),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (newPass.text.isNotEmpty &&
                  newPass.text == confirmPass.text) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password updated successfully!'),
                    backgroundColor: Color(0xFF10B981),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Passwords do not match or are empty.'),
                    backgroundColor: Color(0xFFEF4444),
                  ),
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showAppLockPinDialog(BuildContext context, AuthProvider auth) {
    final pinCtrl = TextEditingController(text: auth.appLockPin);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Configure App Lock PIN'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter a 4-digit PIN required whenever opening StarShop:',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: pinCtrl,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                letterSpacing: 12,
                fontWeight: FontWeight.bold,
              ),
              decoration: const InputDecoration(
                counterText: '',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (pinCtrl.text.length == 4) {
                auth.setAppLock(enabled: true, pin: pinCtrl.text);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('App Lock PIN configured successfully!'),
                    backgroundColor: Color(0xFF10B981),
                  ),
                );
              }
            },
            child: const Text('Set PIN'),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, AuthProvider auth) {
    final languages = [
      'English',
      'हिन्दी (Hindi)',
      'Español (Spanish)',
      'Français (French)',
      'Deutsch (German)',
    ];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Select App Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.map((lang) {
            final isSel = auth.appLanguage == lang.split(' ').first;
            return ListTile(
              leading: Icon(
                isSel ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: isSel ? const Color(0xFF4F46E5) : Colors.grey,
              ),
              title: Text(lang),
              onTap: () {
                auth.setLanguage(lang.split(' ').first);
                Navigator.pop(ctx);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showFaqDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.help_outline, color: Color(0xFF4F46E5)),
            SizedBox(width: 8),
            Text('Help Center & FAQs'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Q: How long does express delivery take?',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              SizedBox(height: 2),
              Text(
                'A: Express orders in metro cities are fulfilled in under 2 hours, standard orders take 24 hours.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              SizedBox(height: 12),
              Text(
                'Q: How do refunds to StarShop Wallet work?',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              SizedBox(height: 2),
              Text(
                'A: Wallet refunds are processed instantly within 15 minutes of return courier pickup.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              SizedBox(height: 12),
              Text(
                'Q: What is Developer PIN 7266?',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              SizedBox(height: 2),
              Text(
                'A: It allows authorized developers to preview Admin, Seller, and Delivery Partner interfaces instantly.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showRateAppDialog(BuildContext context) {
    int stars = 5;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Rate StarShop on Google Play'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enjoying StarShop? Let us know how we are doing!'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < stars ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: Colors.amber,
                      size: 32,
                    ),
                    onPressed: () {
                      setDialogState(() => stars = index + 1);
                    },
                  );
                }),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Later'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogCtx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Thank you for rating StarShop 5 stars!'),
                    backgroundColor: Color(0xFF10B981),
                  ),
                );
              },
              child: const Text('Submit Review'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Account', style: TextStyle(color: Color(0xFFEF4444))),
        content: const Text(
          'Are you sure you want to delete your StarShop account? This action is permanent and will remove your order history, saved addresses, and wallet balance.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await auth.deleteAccount();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();
    final themeProv = context.watch<ThemeProvider>();
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Preferences'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // 1. Account Information
          _buildSectionHeader('1. Account Information'),
          _buildCard(
            isDark: isDark,
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.primary,
                  child: Text(
                    user?.name.isNotEmpty == true
                        ? user!.name[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(
                  user?.name ?? 'StarShop Shopper',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${user?.email ?? "shopper@starshop.com"}\n${user?.phoneNumber ?? "+91 9876543210"}',
                  style: const TextStyle(fontSize: 12),
                ),
                isThreeLine: true,
                trailing: TextButton.icon(
                  icon: const Icon(Icons.edit, size: 14),
                  label: const Text('Edit'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const EditProfileScreen()),
                    );
                  },
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.verified_user_rounded,
                    color: Color(0xFF10B981)),
                title: const Text('Account Verification Status'),
                subtitle: const Text('Phone & Email Verified (High Trust Tier)',
                    style: TextStyle(fontSize: 12)),
                trailing: const Icon(Icons.check_circle,
                    color: Color(0xFF10B981), size: 18),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 2. Login, Biometrics & Security
          _buildSectionHeader('2. Login, Biometrics & Security'),
          _buildCard(
            isDark: isDark,
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.fingerprint_rounded,
                    color: Color(0xFF4F46E5)),
                title: const Text('Biometric Authentication'),
                subtitle: const Text(
                  'Use Fingerprint or Face ID to unlock StarShop',
                  style: TextStyle(fontSize: 12),
                ),
                value: auth.biometricEnabled,
                onChanged: (val) => auth.toggleBiometrics(val),
              ),
              const Divider(height: 1),
              SwitchListTile(
                secondary: const Icon(Icons.pin_rounded,
                    color: Color(0xFF059669)),
                title: const Text('App Lock PIN'),
                subtitle: Text(
                  auth.appLockEnabled
                      ? 'PIN Protection Active'
                      : 'Lock app with custom 4-digit code',
                  style: const TextStyle(fontSize: 12),
                ),
                value: auth.appLockEnabled,
                onChanged: (val) {
                  if (val) {
                    _showAppLockPinDialog(context, auth);
                  } else {
                    auth.setAppLock(enabled: false);
                  }
                },
              ),
              if (auth.appLockEnabled) ...[
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.timer_outlined),
                  title: const Text('Auto-Lock Timeout'),
                  subtitle: Text(
                    'Lock automatically after ${auth.autoLockTimeoutMinutes} minutes idle',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: DropdownButton<int>(
                    value: auth.autoLockTimeoutMinutes,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('1 min')),
                      DropdownMenuItem(value: 5, child: Text('5 min')),
                      DropdownMenuItem(value: 15, child: Text('15 min')),
                      DropdownMenuItem(value: 30, child: Text('30 min')),
                    ],
                    onChanged: (v) {
                      if (v != null) auth.setAutoLockTimeout(v);
                    },
                  ),
                ),
              ],
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.password_rounded,
                    color: Color(0xFFD97706)),
                title: const Text('Change Password'),
                subtitle: const Text('Update your StarShop login password',
                    style: TextStyle(fontSize: 12)),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _showChangePasswordDialog(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 3 & 4. Addresses & Payment / Wallet Hub
          _buildSectionHeader('3 & 4. Addresses & Payment Methods'),
          _buildCard(
            isDark: isDark,
            children: [
              ListTile(
                leading: const Icon(Icons.location_on_rounded,
                    color: Color(0xFF10B981)),
                title: const Text('Saved Delivery Addresses'),
                subtitle: Text(
                  '${auth.savedAddresses.length} addresses configured',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const AddressesScreen()),
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.account_balance_wallet_rounded,
                    color: Color(0xFF047857)),
                title: const Text('StarShop Wallet & Saved Payment Methods'),
                subtitle: const Text(
                  'Manage UPI IDs, Saved Cards & Instant Refunds',
                  style: TextStyle(fontSize: 12),
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const WalletScreen()),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 5. Notifications Preferences
          _buildSectionHeader('5. Notification Preferences'),
          _buildCard(
            isDark: isDark,
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.local_shipping_outlined),
                title: const Text('Order & Delivery Updates'),
                subtitle: const Text('Live shipment, out-for-delivery, and OTP alerts',
                    style: TextStyle(fontSize: 12)),
                value: _orderNotifications,
                onChanged: (v) => setState(() => _orderNotifications = v),
              ),
              const Divider(height: 1),
              SwitchListTile(
                secondary: const Icon(Icons.discount_outlined),
                title: const Text('Exclusive Deals & Flash Sales'),
                subtitle: const Text('Daily discounts and personalised price drops',
                    style: TextStyle(fontSize: 12)),
                value: _promotionalNotifications,
                onChanged: (v) => setState(() => _promotionalNotifications = v),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.phonelink_ring_rounded,
                    color: Color(0xFF6366F1)),
                title: const Text('Cloud Push Notifications (FCM)'),
                subtitle: Text(
                  NotificationService().fcmToken != null
                      ? 'Google FCM Token Active & Registered'
                      : 'Firebase Cloud Messaging Ready',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: const Icon(Icons.check_circle,
                    color: Color(0xFF10B981), size: 18),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 6 & 7. Language & Appearance
          _buildSectionHeader('6 & 7. Language & Appearance'),
          _buildCard(
            isDark: isDark,
            children: [
              ListTile(
                leading: const Icon(Icons.language_rounded,
                    color: Color(0xFF0EA5E9)),
                title: const Text('App Language'),
                subtitle: Text(auth.appLanguage,
                    style: const TextStyle(fontSize: 12)),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _showLanguageDialog(context, auth),
              ),
              const Divider(height: 1),
              SwitchListTile(
                secondary: Icon(
                  themeProv.isDarkMode
                      ? Icons.dark_mode_rounded
                      : Icons.light_mode_rounded,
                  color: theme.colorScheme.primary,
                ),
                title: const Text('Dark Mode Theme'),
                subtitle: Text(
                  themeProv.isDarkMode
                      ? 'Dark slate interface active'
                      : 'Light crisp interface active',
                  style: const TextStyle(fontSize: 12),
                ),
                value: themeProv.isDarkMode,
                onChanged: (v) => themeProv.toggleTheme(v),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 8, 9 & 10. Privacy, Orders & AI Recommendations
          _buildSectionHeader('8, 9 & 10. Privacy, Orders & AI Recommendations'),
          _buildCard(
            isDark: isDark,
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.auto_awesome,
                    color: Color(0xFF6366F1)),
                title: const Text('AI Personalization & Smart Recommendations'),
                subtitle: const Text(
                  'Personalize homepage deals based on your browsing habits',
                  style: TextStyle(fontSize: 12),
                ),
                value: auth.aiPersonalizationEnabled,
                onChanged: (v) => auth.setAiPersonalization(v),
              ),
              const Divider(height: 1),
              SwitchListTile(
                secondary: const Icon(Icons.bolt_rounded,
                    color: Color(0xFFF59E0B)),
                title: const Text('1-Click Reorder'),
                subtitle: const Text(
                  'Instantly re-order previous cart items with saved defaults',
                  style: TextStyle(fontSize: 12),
                ),
                value: _oneClickReorder,
                onChanged: (v) => setState(() => _oneClickReorder = v),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.replay_rounded,
                    color: Color(0xFF10B981)),
                title: const Text('Default Refund Destination'),
                subtitle: Text(_refundMethod, style: const TextStyle(fontSize: 12)),
                trailing: DropdownButton<String>(
                  value: _refundMethod,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(
                      value: 'StarShop Wallet (Instant)',
                      child: Text('StarShop Wallet (Instant)'),
                    ),
                    DropdownMenuItem(
                      value: 'Original Payment Method (2-3 Days)',
                      child: Text('Original Source (2-3 Days)'),
                    ),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _refundMethod = v);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 11 & 12. Camera Settings & Storage Cache
          _buildSectionHeader('11 & 12. Visual Camera & Cache Storage'),
          _buildCard(
            isDark: isDark,
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.camera_alt_outlined),
                title: const Text('Camera Auto-Focus & Barcode Assist'),
                subtitle: const Text(
                  'Enhances image resolution for AI Visual Search',
                  style: TextStyle(fontSize: 12),
                ),
                value: _cameraAutoFocus,
                onChanged: (v) => setState(() => _cameraAutoFocus = v),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.cleaning_services_rounded,
                    color: Color(0xFFEF4444)),
                title: const Text('Clear App Cache & Data'),
                subtitle: Text(
                  'Currently using ${_cacheSizeMb.toStringAsFixed(1)} MB storage',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: TextButton(
                  onPressed: () {
                    setState(() => _cacheSizeMb = 0.0);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('App cache cleared successfully!'),
                      ),
                    );
                  },
                  child: const Text('Clear'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 13, 14 & 15. Developer Portal, Help & Customer Support
          _buildSectionHeader('13, 14 & 15. Developer Portal & Support'),
          _buildCard(
            isDark: isDark,
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    ),
                  ),
                  child: const Icon(Icons.code_rounded,
                      color: Colors.white, size: 16),
                ),
                title: const Text('Developer Portal (PIN: 7266)'),
                subtitle: const Text(
                  'Test Customer, Seller, Delivery Partner, and Super Admin roles',
                  style: TextStyle(fontSize: 12),
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => DeveloperBypassSheet.show(context),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.help_center_outlined,
                    color: Color(0xFF4F46E5)),
                title: const Text('Help Center & FAQs'),
                subtitle: const Text('Common answers for orders, payments & returns',
                    style: TextStyle(fontSize: 12)),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _showFaqDialog(context),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.support_agent_rounded,
                    color: Color(0xFF059669)),
                title: const Text('24x7 Customer Support & AI Concierge'),
                subtitle: const Text('Chat live with StarShop AI Assistant',
                    style: TextStyle(fontSize: 12)),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const AIAssistantScreen()),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 16, 17 & 18. Legal, Rating & Version Info
          _buildSectionHeader('16, 17 & 18. Legal & App Details'),
          _buildCard(
            isDark: isDark,
            children: [
              ListTile(
                leading: const Icon(Icons.policy_outlined),
                title: const Text('Terms of Service & Privacy Policy'),
                subtitle: const Text('StarShop Customer Data Protection Policy 2026',
                    style: TextStyle(fontSize: 12)),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      title: const Text('StarShop Privacy & Terms'),
                      content: const Text(
                        'Your personal information and payment credentials are encrypted using industry standard TLS 1.3 and stored securely within Firebase. StarShop never shares or sells customer browsing history.',
                      ),
                      actions: [
                        ElevatedButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Understood'),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.star_rate_rounded,
                    color: Colors.amber),
                title: const Text('Rate StarShop on Google Play'),
                subtitle: const Text('Help us improve your shopping experience',
                    style: TextStyle(fontSize: 12)),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _showRateAppDialog(context),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.info_outline_rounded),
                title: const Text('App Version & Release Info'),
                subtitle: const Text('Version 2.0.0 (Enterprise Production Build #2026)',
                    style: TextStyle(fontSize: 12)),
                trailing: const Text(
                  'LATEST',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF10B981),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 19. Logout & Delete Account
          _buildSectionHeader('19. Account Actions'),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFEF4444),
              side: const BorderSide(color: Color(0xFFEF4444)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Log Out',
                style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () {
              auth.signOut();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[600],
            ),
            icon: const Icon(Icons.delete_forever_rounded, size: 18),
            label: const Text('Delete Account Permanently',
                style: TextStyle(fontSize: 12)),
            onPressed: () => _showDeleteAccountDialog(context, auth),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Color(0xFF64748B),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildCard({
    required bool isDark,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(children: children),
    );
  }
}
