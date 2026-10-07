import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';
import '../utils/sample_data.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService _productService = ProductService();

  List<ProductModel> _allProducts = [];
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _isLoading = true;
  String? _errorMessage;
  StreamSubscription<List<ProductModel>>? _streamSubscription;

  ProductProvider() {
    _initStream();
  }

  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<ProductModel> get filteredProducts {
    var list = _allProducts;

    // Filter by Category
    if (_selectedCategory != 'All') {
      list = list.where((p) => p.category == _selectedCategory).toList();
    }

    // Filter by Search Query
    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.toLowerCase().trim();
      list = list.where((p) {
        return p.name.toLowerCase().contains(query) ||
            p.description.toLowerCase().contains(query) ||
            p.category.toLowerCase().contains(query);
      }).toList();
    }

    return list;
  }

  List<ProductModel> get featuredProducts {
    return _allProducts.where((p) => p.isFeatured).toList();
  }

  void _initStream() {
    _isLoading = true;
    notifyListeners();

    _streamSubscription = _productService.getProductsStream().listen(
      (products) {
        if (products.isEmpty) {
          // If Firestore collection is empty, use sample catalog and auto-seed
          _allProducts = SampleData.sampleProducts;
          seedProducts(silent: true);
        } else {
          _allProducts = products;
        }
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (err) {
        // Fallback to sample data for offline / preview resilience
        _allProducts = SampleData.sampleProducts;
        _isLoading = false;
        _errorMessage = err.toString();
        notifyListeners();
      },
    );
  }

  void selectCategory(String category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> seedProducts({bool silent = false}) async {
    try {
      await _productService.seedSampleProducts();
    } catch (e) {
      if (!silent) {
        _errorMessage = e.toString();
        notifyListeners();
      }
    }
  }

  ProductModel? findById(String id) {
    try {
      return _allProducts.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }
}
