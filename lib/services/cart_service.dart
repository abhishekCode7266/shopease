import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';
import '../utils/constants.dart';

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference _cartRef(String uid) {
    return _firestore
        .collection(AppConstants.collectionUsers)
        .doc(uid)
        .collection(AppConstants.collectionCart);
  }

  // Stream of user cart items
  Stream<List<CartItemModel>> getCartStream(String uid) {
    return _cartRef(uid).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => CartItemModel.fromFirestore(doc))
          .toList();
    });
  }

  // Add product to cart (or increment if exists)
  Future<void> addToCart(
    String uid,
    ProductModel product, {
    int quantity = 1,
  }) async {
    final docRef = _cartRef(uid).doc(product.id);
    final doc = await docRef.get();

    if (doc.exists) {
      final currentQuantity = (doc.get('quantity') as num?)?.toInt() ?? 1;
      await docRef.update({
        'quantity': currentQuantity + quantity,
      });
    } else {
      final cartItem = CartItemModel(
        productId: product.id,
        name: product.name,
        price: product.price,
        imageUrl: product.imageUrl,
        quantity: quantity,
      );
      await docRef.set(cartItem.toMap());
    }
  }

  // Update item quantity
  Future<void> updateQuantity(
    String uid,
    String productId,
    int quantity,
  ) async {
    final docRef = _cartRef(uid).doc(productId);
    if (quantity <= 0) {
      await docRef.delete();
    } else {
      await docRef.update({'quantity': quantity});
    }
  }

  // Remove single item from cart
  Future<void> removeFromCart(String uid, String productId) async {
    await _cartRef(uid).doc(productId).delete();
  }

  // Clear entire cart (called after successful order)
  Future<void> clearCart(String uid) async {
    final snapshot = await _cartRef(uid).get();
    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
