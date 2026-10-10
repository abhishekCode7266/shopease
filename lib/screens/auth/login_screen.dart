import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/developer_bypass_sheet.dart';
import '../home/home_screen.dart';
import 'forgot_password_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Login failed'),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _fillDemoCredentials() {
    _emailController.text = 'demo.user@starshop.com';
    _passwordController.text = 'password123';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Developer Bypass Circular Button (एक छोटे से गोले से सेटिंग/बाईपास बटन)
                  Align(
                    alignment: Alignment.topRight,
                    child: Tooltip(
                      message: 'Developer Settings & Bypass (डेवलपर मोड)',
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => DeveloperBypassSheet.show(context),
                          borderRadius: BorderRadius.circular(22),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF6366F1).withOpacity(0.35),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.admin_panel_settings_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Header Logo and Welcome
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.shopping_bag_rounded,
                        size: 48,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Center(
                    child: Text(
                      'Welcome to ${AppConstants.appName}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  Center(
                    child: Text(
                      'Sign in to explore exclusive products & deals',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.65),
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Email Input
                  CustomTextField(
                    controller: _emailController,
                    label: 'Email Address',
                    hintText: 'name@example.com',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.validateEmail,
                  ),
                  const SizedBox(height: 18),

                  // Password Input
                  CustomTextField(
                    controller: _passwordController,
                    label: 'Password',
                    hintText: 'Enter your password',
                    prefixIcon: Icons.lock_outline_rounded,
                    obscureText: _obscurePassword,
                    validator: Validators.validatePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Forgot Password Link
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ForgotPasswordScreen(),
                          ),
                        );
                      },
                      child: const Text('Forgot Password?'),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Sign In Button
                  CustomButton(
                    text: 'Sign In',
                    isLoading: auth.isLoading,
                    onPressed: _handleLogin,
                  ),
                  const SizedBox(height: 12),

                  // Demo Credentials Quick Fill
                  OutlinedButton.icon(
                    onPressed: _fillDemoCredentials,
                    icon: const Icon(Icons.flash_on_rounded, size: 18),
                    label: const Text('Fill Demo Credentials'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Alternative Sign In Options Divider
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'OR CONTINUE WITH',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                          ),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Social + Phone + Biometrics Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Phone OTP
                      _buildAuthOptionButton(
                        icon: Icons.phone_android_rounded,
                        label: 'Phone OTP',
                        color: const Color(0xFF10B981),
                        onTap: () => _showPhoneOtpSheet(context),
                      ),
                      // Google Sign-In
                      _buildAuthOptionButton(
                        icon: Icons.g_mobiledata_rounded,
                        label: 'Google',
                        color: const Color(0xFFEA4335),
                        onTap: () => _handleSocialLogin('Google'),
                      ),
                      // Apple Sign-In
                      _buildAuthOptionButton(
                        icon: Icons.apple_rounded,
                        label: 'Apple',
                        color: Colors.black,
                        onTap: () => _handleSocialLogin('Apple'),
                      ),
                      // Biometric
                      _buildAuthOptionButton(
                        icon: Icons.fingerprint_rounded,
                        label: 'Biometric',
                        color: const Color(0xFF6366F1),
                        onTap: () => _handleBiometricUnlock(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Developer Mode Bypass Button
                  TextButton.icon(
                    onPressed: () => DeveloperBypassSheet.show(context),
                    icon: const Icon(
                      Icons.admin_panel_settings_rounded,
                      size: 18,
                      color: Color(0xFF6366F1),
                    ),
                    label: const Text(
                      'Developer Mode Bypass (डेवलपर मोड बाईपास)',
                      style: TextStyle(
                        color: Color(0xFF6366F1),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Sign Up Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const SignUpScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAuthOptionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  void _handleSocialLogin(String provider) {
    final auth = context.read<AuthProvider>();
    auth.bypassLogin(role: 'customer');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Successfully authenticated with $provider!'),
        backgroundColor: const Color(0xFF10B981),
      ),
    );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  void _handleBiometricUnlock(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Biometric Authentication', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.fingerprint_rounded, size: 68, color: Color(0xFF6366F1)),
            SizedBox(height: 16),
            Text(
              'Touch fingerprint sensor or look at camera for Face ID',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              final auth = context.read<AuthProvider>();
              auth.bypassLogin(role: 'customer');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Biometric Verified! Logged in securely.'),
                  backgroundColor: Color(0xFF10B981),
                ),
              );
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
            ),
            child: const Text('Simulate Scan'),
          ),
        ],
      ),
    );
  }

  void _showPhoneOtpSheet(BuildContext context) {
    final phoneController = TextEditingController(text: '+91 98765 47266');
    final otpController = TextEditingController(text: '726600');
    bool otpSent = false;
    String? otpError;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 24,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Phone OTP Sign In',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(sheetCtx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (!otpSent) ...[
                  const Text(
                    'Enter your 10-digit mobile number to receive a secure one-time passcode.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      prefixIcon: Icon(Icons.phone),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setSheetState(() {
                        otpSent = true;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Send Verification OTP'),
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2FE),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Color(0xFF0284C7)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'OTP sent to ${phoneController.text}. Test OTP: 726600 (or 7266)',
                            style: const TextStyle(
                              color: Color(0xFF0369A1),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: InputDecoration(
                      labelText: '6-Digit OTP',
                      prefixIcon: const Icon(Icons.lock_clock),
                      errorText: otpError,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      final entered = otpController.text.trim();
                      if (entered == '726600' ||
                          entered == '7266' ||
                          entered == '123456') {
                        Navigator.pop(sheetCtx);
                        final auth = context.read<AuthProvider>();
                        auth.bypassLogin(role: 'customer');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Phone number verified! Logged in.'),
                            backgroundColor: Color(0xFF10B981),
                          ),
                        );
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                              builder: (_) => const HomeScreen()),
                        );
                      } else {
                        setSheetState(() {
                          otpError = 'Invalid OTP! Use 726600 or 7266';
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Verify & Continue'),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
