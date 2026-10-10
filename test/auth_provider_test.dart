import 'package:flutter_test/flutter_test.dart';
import 'package:starshop/providers/auth_provider.dart';

void main() {
  group('AuthProvider Developer Mode Tests', () {
    test('activateDeveloperBypass sets user and activates developer mode', () {
      final auth = AuthProvider();

      expect(auth.isDeveloperMode, isFalse);
      expect(auth.isAuthenticated, isFalse);

      auth.activateDeveloperBypass(
        name: 'Abhishek (Lead Developer)',
        email: 'abhishekCode7266@starshop.app',
        uid: 'dev_abhishek_7266',
      );

      expect(auth.isDeveloperMode, isTrue);
      expect(auth.isAuthenticated, isTrue);
      expect(auth.user?.name, 'Abhishek (Lead Developer)');
      expect(auth.user?.uid, 'dev_abhishek_7266');
      expect(auth.user?.email, 'abhishekCode7266@starshop.app');

      auth.exitDeveloperMode();
      expect(auth.isDeveloperMode, isFalse);
      expect(auth.isAuthenticated, isFalse);
      expect(auth.user, isNull);
    });

    test('Security and settings preferences behave correctly', () {
      final auth = AuthProvider();

      expect(auth.biometricEnabled, isTrue);
      expect(auth.appLockEnabled, isFalse);

      auth.toggleBiometrics(false);
      expect(auth.biometricEnabled, isFalse);

      auth.setAppLock(enabled: true, pin: '9876');
      expect(auth.appLockEnabled, isTrue);
      expect(auth.appLockPin, '9876');

      auth.setAutoLockTimeout(15);
      expect(auth.autoLockTimeoutMinutes, 15);

      auth.setAiPersonalization(false);
      expect(auth.aiPersonalizationEnabled, isFalse);

      auth.setLanguage('Hindi');
      expect(auth.appLanguage, 'Hindi');
    });
  });
}
