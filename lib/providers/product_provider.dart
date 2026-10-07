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
  String _sortBy = 'popular'; // 'popular', 'price_asc', 'price_desc', 'rating', 'discount', 'newest'
  double _minPrice = 0.0;
  double _maxPrice = 300.0;
  double _minRating = 0.0;
  bool _onlyInStock = false;

  final List<ProductModel> _comparedProducts = [];
  final List<ProductModel> _recentlyViewed = [];

  bool _isLoading = true;
  String? _errorMessage;
  StreamSubscription<List<ProductModel>>? _streamSubscription;

  ProductProvider() {
    _initStream();
  }

  List<ProductModel> get allProducts => List.unmodifiable(_allProducts);
  List<ProductModel> get products => _allProducts;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  String get sortBy => _sortBy;
  double get minPrice => _minPrice;
  double get maxPrice => _maxPrice;
  double get minRating => _minRating;
  bool get onlyInStock => _onlyInStock;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get hasActiveFilters =>
      _selectedCategory != 'All' ||
      _searchQuery.isNotEmpty ||
      _sortBy != 'popular' ||
      _minPrice > 0.0 ||
      _maxPrice < 300.0 ||
      _minRating > 0.0 ||
      _onlyInStock;

  List<ProductModel> get comparedProducts => List.unmodifiable(_comparedProducts);
  List<ProductModel> get recentlyViewed => List.unmodifiable(_recentlyViewed);

  List<ProductModel> get filteredProducts {
    var list = List<ProductModel>.from(_allProducts);

    // 1. Category Filter
    if (_selectedCategory != 'All') {
      list = list.where((p) => p.category == _selectedCategory).toList();
    }

    // 2. Search Query Filter
    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.toLowerCase().trim();
      list = list.where((p) {
        return p.name.toLowerCase().contains(query) ||
            p.description.toLowerCase().contains(query) ||
            p.category.toLowerCase().contains(query);
      }).toList();
    }

    // 3. Price Range Filter
    list = list.where((p) => p.price >= _minPrice && p.price <= _maxPrice).toList();

    // 4. Rating Filter
    if (_minRating > 0.0) {
      list = list.where((p) => p.rating >= _minRating).toList();
    }

    // 5. In-Stock Filter
    if (_onlyInStock) {
      list = list.where((p) => p.isInStock).toList();
    }

    // 6. Sorting
    switch (_sortBy) {
      case 'price_asc':
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_desc':
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'rating':
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'discount':
        list.sort((a, b) => b.discountPercent.compareTo(a.discountPercent));
        break;
      case 'newest':
        list = list.reversed.toList();
        break;
      case 'popular':
      default:
        list.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
        break;
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

  void setSortBy(String sort) {
    _sortBy = sort;
    notifyListeners();
  }

  void setPriceRange(double min, double max) {
    _minPrice = min;
    _maxPrice = max;
    notifyListeners();
  }

  void setMinRating(double rating) {
    _minRating = rating;
    notifyListeners();
  }

  void setOnlyInStock(bool value) {
    _onlyInStock = value;
    notifyListeners();
  }

  void toggleOnlyInStock(bool value) {
    _onlyInStock = value;
    notifyListeners();
  }

  List<ProductModel> searchProducts(String query) {
    if (query.trim().isEmpty) return _allProducts;
    final q = query.toLowerCase().trim();
    return _allProducts.where((p) =>
      p.name.toLowerCase().contains(q) ||
      p.description.toLowerCase().contains(q) ||
      p.category.toLowerCase().contains(q)
    ).toList();
  }

  void resetFilters() {
    _selectedCategory = 'All';
    _searchQuery = '';
    _sortBy = 'popular';
    _minPrice = 0.0;
    _maxPrice = 300.0;
    _minRating = 0.0;
    _onlyInStock = false;
    notifyListeners();
  }

  // Recently Viewed Tracking
  void addToRecentlyViewed(ProductModel product) {
    _recentlyViewed.removeWhere((p) => p.id == product.id);
    _recentlyViewed.insert(0, product);
    if (_recentlyViewed.length > 8) {
      _recentlyViewed.removeLast();
    }
    notifyListeners();
  }

  // Product Comparison (Up to 3 products)
  bool isCompared(String productId) {
    return _comparedProducts.any((p) => p.id == productId);
  }

  bool addToCompare(ProductModel product) {
    if (_comparedProducts.length >= 3) {
      return false; // Limit reached
    }
    if (!isCompared(product.id)) {
      _comparedProducts.add(product);
      notifyListeners();
      return true;
    }
    return true;
  }

  void removeFromCompare(String productId) {
    _comparedProducts.removeWhere((p) => p.id == productId);
    notifyListeners();
  }

  void clearCompare() {
    _comparedProducts.clear();
    notifyListeners();
  }

  // Add Product Review
  void addReview(String productId, ProductReview review) {
    final index = _allProducts.indexWhere((p) => p.id == productId);
    if (index >= 0) {
      final current = _allProducts[index];
      final newReviews = List<ProductReview>.from(current.reviews)..insert(0, review);
      final newRating = newReviews.fold(0.0, (sum, r) => sum + r.rating) / newReviews.length;

      _allProducts[index] = current.copyWith(
        reviews: newReviews,
        rating: double.parse(newRating.toStringAsFixed(1)),
        reviewCount: newReviews.length,
      );
      notifyListeners();
    }
  }

  // Seller / Admin Management Methods
  void addSellerProduct(ProductModel product) {
    _allProducts.insert(0, product);
    notifyListeners();
  }

  void addProduct(ProductModel product) => addSellerProduct(product);

  void updateProduct(ProductModel product) {
    final index = _allProducts.indexWhere((p) => p.id == product.id);
    if (index >= 0) {
      _allProducts[index] = product;
      notifyListeners();
    }
  }

  void updateProductStock(String productId, int newStock) {
    final index = _allProducts.indexWhere((p) => p.id == productId);
    if (index >= 0) {
      _allProducts[index] = _allProducts[index].copyWith(stock: newStock);
      notifyListeners();
    }
  }

  void deleteProduct(String productId) {
    _allProducts.removeWhere((p) => p.id == productId);
    notifyListeners();
  }

  List<ProductModel> getSellerProducts(String sellerId) {
    return _allProducts.where((p) => p.sellerId == sellerId).toList();
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
