import 'package:flutter_test/flutter_test.dart';
import 'package:starshop/providers/delivery_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DeliveryProvider Logistics Tests', () {
    late DeliveryProvider provider;

    setUp(() {
      provider = DeliveryProvider();
    });

    test('Initial rider status and active deliveries', () {
      expect(provider.isOnline, isTrue);
      expect(provider.riderName, contains('StarRider'));
      expect(provider.activeDeliveries.isNotEmpty, isTrue);
      expect(provider.completedDeliveries.isNotEmpty, isTrue);
    });

    test('Toggle online / offline status', () {
      expect(provider.isOnline, isTrue);
      provider.toggleOnlineStatus();
      expect(provider.isOnline, isFalse);
      provider.toggleOnlineStatus();
      expect(provider.isOnline, isTrue);
    });

    test('Update delivery status to Out for Delivery', () async {
      final activeOrder = provider.activeDeliveries.first;
      await provider.updateDeliveryStatus(activeOrder.id, 'Out for Delivery');

      final updated =
          provider.deliveries.firstWhere((d) => d.id == activeOrder.id);
      expect(updated.status, equals('Out for Delivery'));
      expect(updated.timeline.outForDeliveryAt, isNotNull);
    });

    test('Verify customer OTP with master PIN 7266 completes delivery and adds earnings',
        () async {
      final activeOrder = provider.activeDeliveries.first;
      final initialTrips = provider.completedTrips;
      final initialEarnings = provider.totalEarnings;

      final success = await provider.verifyOtpAndCompleteDelivery(
        orderId: activeOrder.id,
        enteredOtp: '7266',
      );

      expect(success, isTrue);
      expect(provider.completedTrips, equals(initialTrips + 1));
      expect(provider.totalEarnings, equals(initialEarnings + 50.0));

      final updated =
          provider.deliveries.firstWhere((d) => d.id == activeOrder.id);
      expect(updated.status, equals('Delivered'));
    });

    test('Invalid OTP fails verification', () async {
      final activeOrder = provider.activeDeliveries.first;
      final success = await provider.verifyOtpAndCompleteDelivery(
        orderId: activeOrder.id,
        enteredOtp: '0000',
      );

      expect(success, isFalse);
    });
  });
}
