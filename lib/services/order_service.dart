import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/cart_item_model.dart';
import '../models/order_model.dart';
import '../utils/constants.dart';
import 'cart_service.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CartService _cartService = CartService();
  final Uuid _uuid = const Uuid();

  CollectionReference _ordersRef(String uid) {
    return _firestore
        .collection(AppConstants.collectionUsers)
        .doc(uid)
        .collection(AppConstants.collectionOrders);
  }

  // Stream of user orders sorted newest first
  Stream<List<OrderModel>> getOrdersStream(String uid) {
    return _ordersRef(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc))
          .toList();
    });
  }

  // Place a new order
  Future<OrderModel> placeOrder({
    required String uid,
    required List<CartItemModel> cartItems,
    required double total,
    required ShippingAddress address,
    required String paymentMethod,
  }) async {
    if (cartItems.isEmpty) {
      throw 'Cannot place an order with an empty cart.';
    }

    final orderId = 'ORD-${_uuid.v4().substring(0, 8).toUpperCase()}';
    final orderItems = cartItems.map((c) => OrderItem.fromCartItem(c)).toList();

    final order = OrderModel(
      id: orderId,
      userId: uid,
      items: orderItems,
      total: total,
      address: address,
      paymentMethod: paymentMethod,
      status: AppConstants.orderStatusPlaced,
      createdAt: DateTime.now(),
    );

    // Save order in Firestore under users/{uid}/orders/{orderId}
    await _ordersRef(uid).doc(orderId).set(order.toMap());

    // Clear cart after placing order
    await _cartService.clearCart(uid);

    return order;
  }

  // Get order by ID
  Future<OrderModel?> getOrderById(String uid, String orderId) async {
    try {
      final doc = await _ordersRef(uid).doc(orderId).get();
      if (doc.exists) {
        return OrderModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
