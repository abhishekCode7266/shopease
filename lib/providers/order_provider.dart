import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/cart_item_model.dart';
import '../models/order_model.dart';
import '../services/notification_service.dart';
import '../services/order_service.dart';
import '../utils/sample_data.dart';

class OrderProvider extends ChangeNotifier {
  final OrderService _orderService = OrderService();
  final NotificationService _notificationService = NotificationService();

  List<OrderModel> _orders = [];
  String? _userId;
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<List<OrderModel>>? _orderSubscription;

  OrderProvider({String? initialUserId}) {
    if (initialUserId != null) {
      updateUser(initialUserId);
    }
  }

  List<OrderModel> get orders => List.unmodifiable(_orders);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void updateUser(String? userId) {
    if (_userId == userId) return;
    _userId = userId;
    _orderSubscription?.cancel();

    if (_userId != null && _userId!.isNotEmpty) {
      _isLoading = true;
      notifyListeners();

      _orderSubscription = _orderService.getOrdersStream(_userId!).listen(
        (ordersList) {
          if (ordersList.isEmpty && _orders.isEmpty) {
            _orders = _getDemoInitialOrders();
          } else {
            _orders = ordersList;
          }
          _isLoading = false;
          _errorMessage = null;
          notifyListeners();
        },
        onError: (err) {
          if (_orders.isEmpty) {
            _orders = _getDemoInitialOrders();
          }
          _isLoading = false;
          _errorMessage = err.toString();
          notifyListeners();
        },
      );
    } else {
      if (_orders.isEmpty) {
        _orders = _getDemoInitialOrders();
      }
      _isLoading = false;
      notifyListeners();
    }
  }

  List<OrderModel> _getDemoInitialOrders() {
    final sampleProduct1 = SampleData.sampleProducts[0];
    final sampleProduct2 = SampleData.sampleProducts[1];
    final addr = SampleData.sampleAddresses[0];

    return [
      OrderModel(
        id: 'ORD-98234',
        invoiceNumber: 'INV-2026-09823',
        userId: _userId ?? 'dev_abhishek',
        items: [
          OrderItem(
            productId: sampleProduct1.id,
            name: sampleProduct1.name,
            price: sampleProduct1.price,
            imageUrl: sampleProduct1.imageUrl,
            quantity: 1,
          ),
        ],
        subtotal: 199.99,
        discount: 20.0,
        couponCode: 'EASE20',
        tax: 32.40,
        deliveryCharge: 0.0,
        total: 212.39,
        address: addr,
        paymentMethod: 'UPI (Google Pay)',
        status: 'Shipped',
        trackingId: 'SE-BD-9284102',
        deliveryPartner: 'BlueDart Express',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        estimatedDeliveryDate: DateTime.now().add(const Duration(days: 1)),
        timeline: OrderTimeline(
          confirmedAt: DateTime.now().subtract(const Duration(days: 2)),
          packedAt: DateTime.now().subtract(const Duration(days: 1, hours: 12)),
          shippedAt: DateTime.now().subtract(const Duration(hours: 18)),
        ),
      ),
      OrderModel(
        id: 'ORD-87112',
        invoiceNumber: 'INV-2026-08711',
        userId: _userId ?? 'dev_abhishek',
        items: [
          OrderItem(
            productId: sampleProduct2.id,
            name: sampleProduct2.name,
            price: sampleProduct2.price,
            imageUrl: sampleProduct2.imageUrl,
            quantity: 1,
          ),
        ],
        subtotal: 149.50,
        discount: 0.0,
        tax: 26.91,
        deliveryCharge: 0.0,
        total: 176.41,
        address: addr,
        paymentMethod: 'Credit Card',
        status: 'Delivered',
        trackingId: 'SE-DL-5521901',
        deliveryPartner: 'Delhivery Surface',
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        estimatedDeliveryDate: DateTime.now().subtract(const Duration(days: 4)),
        timeline: OrderTimeline(
          confirmedAt: DateTime.now().subtract(const Duration(days: 7)),
          packedAt: DateTime.now().subtract(const Duration(days: 6)),
          shippedAt: DateTime.now().subtract(const Duration(days: 5)),
          outForDeliveryAt: DateTime.now().subtract(const Duration(days: 4, hours: 4)),
          deliveredAt: DateTime.now().subtract(const Duration(days: 4)),
        ),
      ),
    ];
  }

  Future<OrderModel> placeOrder({
    required List<CartItemModel> cartItems,
    required double total,
    required ShippingAddress address,
    required String paymentMethod,
    double? subtotal,
    double discount = 0.0,
    String? couponCode,
    double? tax,
    double? deliveryCharge,
  }) async {
    if (_userId == null || _userId!.isEmpty) {
      throw 'Please log in to place your order.';
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final orderId = 'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final order = OrderModel(
      id: orderId,
      userId: _userId!,
      items: cartItems.map((c) => OrderItem.fromCartItem(c)).toList(),
      subtotal: subtotal ?? total,
      discount: discount,
      couponCode: couponCode,
      tax: tax,
      deliveryCharge: deliveryCharge,
      total: total,
      address: address,
      paymentMethod: paymentMethod,
      status: 'Confirmed',
      trackingId: 'SE-TRK-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
      deliveryPartner: 'ShopEase Express (BlueDart)',
      createdAt: DateTime.now(),
    );

    try {
      await _orderService.placeOrder(
        uid: _userId!,
        cartItems: cartItems,
        total: total,
        address: address,
        paymentMethod: paymentMethod,
      );
    } catch (_) {
      // In-memory fallback
    }

    _orders.insert(0, order);

    try {
      await _notificationService.showOrderPlacedNotification(
        orderId: order.id,
        total: order.total,
      );
    } catch (_) {}

    _isLoading = false;
    notifyListeners();
    return order;
  }

  // Cancel Order
  Future<void> cancelOrder(String orderId, String reason) async {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index >= 0) {
      final updated = _orders[index].copyWith(
        status: 'Cancelled',
        cancelReason: reason,
      );
      _orders[index] = updated;
      notifyListeners();
    }
  }

  // Request Return / Replacement
  Future<void> requestReturn(String orderId, String reason) async {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index >= 0) {
      final current = _orders[index];
      final updated = current.copyWith(
        returnStatus: 'requested',
        returnReason: reason,
        refundAmount: current.total,
      );
      _orders[index] = updated;
      notifyListeners();
    }
  }

  // Update Status by Seller / Admin
  void updateOrderStatus(String orderId, String newStatus) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index >= 0) {
      final current = _orders[index];
      final now = DateTime.now();
      OrderTimeline newTimeline = current.timeline;

      if (newStatus == 'Packed') {
        newTimeline = OrderTimeline(
          confirmedAt: current.timeline.confirmedAt,
          packedAt: now,
        );
      } else if (newStatus == 'Shipped') {
        newTimeline = OrderTimeline(
          confirmedAt: current.timeline.confirmedAt,
          packedAt: current.timeline.packedAt ?? now,
          shippedAt: now,
        );
      } else if (newStatus == 'Out for Delivery') {
        newTimeline = OrderTimeline(
          confirmedAt: current.timeline.confirmedAt,
          packedAt: current.timeline.packedAt ?? now,
          shippedAt: current.timeline.shippedAt ?? now,
          outForDeliveryAt: now,
        );
      } else if (newStatus == 'Delivered') {
        newTimeline = OrderTimeline(
          confirmedAt: current.timeline.confirmedAt,
          packedAt: current.timeline.packedAt ?? now,
          shippedAt: current.timeline.shippedAt ?? now,
          outForDeliveryAt: current.timeline.outForDeliveryAt ?? now,
          deliveredAt: now,
        );
      }

      _orders[index] = current.copyWith(
        status: newStatus,
        timeline: newTimeline,
      );
      notifyListeners();
    }
  }

  // Admin approves refund
  void approveRefund(String orderId) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index >= 0) {
      _orders[index] = _orders[index].copyWith(
        returnStatus: 'refunded',
      );
      notifyListeners();
    }
  }

  OrderModel? findById(String id) {
    try {
      return _orders.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _orderSubscription?.cancel();
    super.dispose();
  }
}
