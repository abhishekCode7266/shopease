import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import '../utils/constants.dart';
import '../utils/sample_data.dart';

class ProductService {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  CollectionReference get _productsRef =>
      _firestore.collection(AppConstants.collectionProducts);

  // Stream of all products with real-time updates
  Stream<List<ProductModel>> getProductsStream({
    String? category,
    String? searchQuery,
  }) {
    Query query = _productsRef;

    if (category != null && category != 'All' && category.isNotEmpty) {
      query = query.where('category', isEqualTo: category);
    }

    return query.snapshots().map((snapshot) {
      var products = snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();

      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final queryLower = searchQuery.toLowerCase().trim();
        products = products.where((p) {
          return p.name.toLowerCase().contains(queryLower) ||
              p.description.toLowerCase().contains(queryLower) ||
              p.category.toLowerCase().contains(queryLower);
        }).toList();
      }

      return products;
    });
  }

  // Get single product by ID
  Future<ProductModel?> getProductById(String productId) async {
    try {
      final doc = await _productsRef.doc(productId).get();
      if (doc.exists) {
        return ProductModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Seed sample products into Firestore
  Future<int> seedSampleProducts({bool forceOverwrite = false}) async {
    try {
      final snapshot = await _productsRef.limit(1).get();
      if (snapshot.docs.isNotEmpty && !forceOverwrite) {
        // Already seeded
        return snapshot.docs.length;
      }

      final batch = _firestore.batch();
      final products = SampleData.sampleProducts;

      for (final product in products) {
        final docRef = _productsRef.doc(product.id);
        batch.set(docRef, product.toMap(), SetOptions(merge: true));
      }

      await batch.commit();
      return products.length;
    } catch (e) {
      throw 'Failed to seed sample products: $e';
    }
  }
}
