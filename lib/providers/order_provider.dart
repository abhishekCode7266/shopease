import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/cart_item_model.dart';
import '../models/order_model.dart';
import '../services/notification_service.dart';
import '../services/order_service.dart';

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
          _orders = ordersList;
          _isLoading = false;
          _errorMessage = null;
          notifyListeners();
        },
        onError: (err) {
          _isLoading = false;
          _errorMessage = err.toString();
          notifyListeners();
        },
      );
    } else {
      _orders = [];
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<OrderModel> placeOrder({
    required List<CartItemModel> cartItems,
    required double total,
    required ShippingAddress address,
    required String paymentMethod,
  }) async {
    if (_userId == null || _userId!.isEmpty) {
      throw 'Please log in to place your order.';
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final order = await _orderService.placeOrder(
        uid: _userId!,
        cartItems: cartItems,
        total: total,
        address: address,
        paymentMethod: paymentMethod,
      );

      // Trigger FCM / Local Notification
      await _notificationService.showOrderPlacedNotification(
        orderId: order.id,
        total: order.total,
      );

      _isLoading = false;
      notifyListeners();
      return order;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
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
