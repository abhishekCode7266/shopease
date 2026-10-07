import 'package:flutter_test/flutter_test.dart';
import 'package:shopease/providers/auth_provider.dart';

void main() {
  group('AuthProvider Developer Mode Tests', () {
    test('activateDeveloperBypass sets user and activates developer mode', () {
      final auth = AuthProvider();

      expect(auth.isDeveloperMode, isFalse);
      expect(auth.isAuthenticated, isFalse);

      auth.activateDeveloperBypass(
        name: 'Abhishek (Lead Developer)',
        email: 'abhishekCode7266@shopease.app',
        uid: 'dev_abhishek_7266',
      );

      expect(auth.isDeveloperMode, isTrue);
      expect(auth.isAuthenticated, isTrue);
      expect(auth.user?.name, 'Abhishek (Lead Developer)');
      expect(auth.user?.uid, 'dev_abhishek_7266');
      expect(auth.user?.email, 'abhishekCode7266@shopease.app');

      auth.exitDeveloperMode();
      expect(auth.isDeveloperMode, isFalse);
      expect(auth.isAuthenticated, isFalse);
      expect(auth.user, isNull);
    });
  });
}
