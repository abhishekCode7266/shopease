import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/order_model.dart';
import '../utils/sample_data.dart';

class DeliveryProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isOnline = true;
  String _riderId = 'rider_dev_7266';
  String _riderName = 'Abhishek StarRider';
  String _riderPhone = '+91 98765 47266';
  String _vehicleNumber = 'DL 01 ST 7266';
  double _totalEarnings = 1450.0;
  int _completedTrips = 29;
  double _rating = 4.9;
  bool _isLoading = false;
  String? _errorMessage;

  List<OrderModel> _deliveries = [];

  DeliveryProvider() {
    _initializeDeliveries();
  }

  bool get isOnline => _isOnline;
  String get riderId => _riderId;
  String get riderName => _riderName;
  String get riderPhone => _riderPhone;
  String get vehicleNumber => _vehicleNumber;
  double get totalEarnings => _totalEarnings;
  int get completedTrips => _completedTrips;
  double get rating => _rating;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<OrderModel> get deliveries => List.unmodifiable(_deliveries);

  List<OrderModel> get activeDeliveries => _deliveries
      .where((d) => d.status != 'Delivered' && d.status != 'Cancelled')
      .toList();

  List<OrderModel> get completedDeliveries =>
      _deliveries.where((d) => d.status == 'Delivered').toList();

  void _initializeDeliveries() {
    final sampleProd1 = SampleData.sampleProducts[0];
    final sampleProd2 = SampleData.sampleProducts[1];
    final sampleProd3 = SampleData.sampleProducts[2];
    final addr1 = SampleData.sampleAddresses[0];
    final addr2 = SampleData.sampleAddresses.length > 1
        ? SampleData.sampleAddresses[1]
        : addr1;

    _deliveries = [
      OrderModel(
        id: 'DELIV-7266-01',
        invoiceNumber: 'INV-2026-DEL01',
        userId: 'cust_priya_01',
        items: [
          OrderItem(
            productId: sampleProd1.id,
            name: sampleProd1.name,
            price: sampleProd1.price,
            imageUrl: sampleProd1.imageUrl,
            quantity: 1,
          ),
          OrderItem(
            productId: sampleProd2.id,
            name: sampleProd2.name,
            price: sampleProd2.price,
            imageUrl: sampleProd2.imageUrl,
            quantity: 2,
          ),
        ],
        subtotal: 498.99,
        discount: 25.0,
        tax: 85.31,
        deliveryCharge: 0.0,
        total: 559.30,
        address: addr1,
        paymentMethod: 'Prepaid (UPI PhonePe)',
        status: 'Out for Delivery',
        trackingId: 'STAR-EXP-72661',
        deliveryPartner: 'StarShop Fleet Express',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        deliveryPartnerId: _riderId,
        deliveryPartnerName: _riderName,
        deliveryPartnerPhone: _riderPhone,
        deliveryOtp: '7266',
        deliveryNotes: 'Call customer upon arrival at gate 2',
      ),
      OrderModel(
        id: 'DELIV-7266-02',
        invoiceNumber: 'INV-2026-DEL02',
        userId: 'cust_rohan_02',
        items: [
          OrderItem(
            productId: sampleProd3.id,
            name: sampleProd3.name,
            price: sampleProd3.price,
            imageUrl: sampleProd3.imageUrl,
            quantity: 1,
          ),
        ],
        subtotal: 89.99,
        discount: 0.0,
        tax: 16.20,
        deliveryCharge: 40.0,
        total: 146.19,
        address: addr2,
        paymentMethod: 'Cash on Delivery (₹146.19 to Collect)',
        status: 'Picked Up',
        trackingId: 'STAR-EXP-72662',
        deliveryPartner: 'StarShop Fleet Express',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        deliveryPartnerId: _riderId,
        deliveryPartnerName: _riderName,
        deliveryPartnerPhone: _riderPhone,
        deliveryOtp: '7266',
        deliveryNotes: 'Please ring the doorbell on 3rd floor',
      ),
      OrderModel(
        id: 'DELIV-7266-HIST-01',
        invoiceNumber: 'INV-2026-DELHIST01',
        userId: 'cust_amit_03',
        items: [
          OrderItem(
            productId: sampleProd1.id,
            name: sampleProd1.name,
            price: sampleProd1.price,
            imageUrl: sampleProd1.imageUrl,
            quantity: 1,
          ),
        ],
        subtotal: 199.99,
        total: 235.98,
        address: addr1,
        paymentMethod: 'Prepaid (Google Pay)',
        status: 'Delivered',
        trackingId: 'STAR-EXP-72660',
        deliveryPartner: 'StarShop Fleet Express',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        deliveryPartnerId: _riderId,
        deliveryPartnerName: _riderName,
        deliveryPartnerPhone: _riderPhone,
        deliveryOtp: '7266',
      ),
    ];
  }

  void toggleOnlineStatus() {
    _isOnline = !_isOnline;
    notifyListeners();
  }

  Future<void> updateDeliveryStatus(String orderId, String newStatus) async {
    final index = _deliveries.indexWhere((d) => d.id == orderId);
    if (index == -1) return;

    final existing = _deliveries[index];
    final updatedTimeline = OrderTimeline(
      confirmedAt: existing.timeline.confirmedAt,
      packedAt: existing.timeline.packedAt ?? DateTime.now(),
      shippedAt: existing.timeline.shippedAt ?? (newStatus == 'Picked Up' ? DateTime.now() : null),
      outForDeliveryAt: existing.timeline.outForDeliveryAt ?? (newStatus == 'Out for Delivery' ? DateTime.now() : null),
      deliveredAt: newStatus == 'Delivered' ? DateTime.now() : existing.timeline.deliveredAt,
    );

    final updated = existing.copyWith(
      status: newStatus,
      timeline: updatedTimeline,
    );

    _deliveries[index] = updated;
    notifyListeners();

    // Sync to Firestore non-blocking
    try {
      await _firestore
          .collection('users')
          .doc(existing.userId)
          .collection('orders')
          .doc(orderId)
          .update({
        'status': newStatus,
        'timeline': updatedTimeline.toMap(),
      });
    } catch (_) {}
  }

  Future<bool> verifyOtpAndCompleteDelivery({
    required String orderId,
    required String enteredOtp,
  }) async {
    final index = _deliveries.indexWhere((d) => d.id == orderId);
    if (index == -1) {
      throw Exception('Order not found');
    }

    final order = _deliveries[index];
    final cleanOtp = enteredOtp.trim();

    // Check entered OTP against order.deliveryOtp or master developer bypass '7266'
    if (cleanOtp != order.deliveryOtp && cleanOtp != '7266') {
      return false;
    }

    // OTP matched: complete the delivery
    await updateDeliveryStatus(orderId, 'Delivered');

    _completedTrips += 1;
    _totalEarnings += 50.0; // ₹50 delivery partner incentive per drop
    notifyListeners();
    return true;
  }

  void assignNewOrder(OrderModel order) {
    final assigned = order.copyWith(
      deliveryPartnerId: _riderId,
      deliveryPartnerName: _riderName,
      deliveryPartnerPhone: _riderPhone,
      deliveryOtp: '7266',
      status: 'Picked Up',
    );
    _deliveries.insert(0, assigned);
    notifyListeners();
  }
}
