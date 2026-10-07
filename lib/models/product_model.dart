import 'package:cloud_firestore/cloud_firestore.dart';

class ProductReview {
  final String id;
  final String userName;
  final double rating;
  final String comment;
  final DateTime createdAt;

  ProductReview({
    required this.id,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory ProductReview.fromMap(Map<String, dynamic> map) {
    DateTime parsedDate;
    if (map['createdAt'] is Timestamp) {
      parsedDate = (map['createdAt'] as Timestamp).toDate();
    } else if (map['createdAt'] is String) {
      parsedDate = DateTime.tryParse(map['createdAt']) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return ProductReview(
      id: map['id'] as String? ?? 'rev-1',
      userName: map['userName'] as String? ?? 'Verified Shopper',
      rating: (map['rating'] as num?)?.toDouble() ?? 5.0,
      comment: map['comment'] as String? ?? 'Excellent product quality and prompt delivery!',
      createdAt: parsedDate,
    );
  }
}

class ProductModel {
  final String id;
  final String name;
  final double price;
  final double originalPrice;
  final int discountPercent;
  final String description;
  final String imageUrl;
  final String? videoUrl;
  final String category;
  final double rating;
  final int stock;
  final int reviewCount;
  final bool isFeatured;
  final String sellerId;
  final String sellerName;
  final Map<String, String> specs;
  final List<ProductReview> reviews;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    double? originalPrice,
    int? discountPercent,
    required this.description,
    required this.imageUrl,
    this.videoUrl,
    required this.category,
    required this.rating,
    required this.stock,
    this.reviewCount = 0,
    this.isFeatured = false,
    this.sellerId = 'seller_shopease_official',
    this.sellerName = 'ShopEase Official Store',
    this.specs = const {},
    this.reviews = const [],
  })  : originalPrice = originalPrice ?? (price * 1.25),
        discountPercent = discountPercent ??
            (((originalPrice ?? (price * 1.25)) - price) /
                    (originalPrice ?? (price * 1.25)) *
                    100)
                .round();

  bool get isInStock => stock > 0;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'originalPrice': originalPrice,
      'discountPercent': discountPercent,
      'description': description,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'category': category,
      'rating': rating,
      'stock': stock,
      'reviewCount': reviewCount,
      'isFeatured': isFeatured,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'specs': specs,
      'reviews': reviews.map((r) => r.toMap()).toList(),
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map, String id) {
    final priceVal = (map['price'] as num?)?.toDouble() ?? 0.0;
    final origPriceVal = (map['originalPrice'] as num?)?.toDouble() ?? (priceVal * 1.25);
    final discVal = (map['discountPercent'] as num?)?.toInt() ??
        (((origPriceVal - priceVal) / (origPriceVal > 0 ? origPriceVal : 1)) * 100).round();

    final reviewsList = (map['reviews'] as List<dynamic>?)
            ?.map((r) => ProductReview.fromMap(r as Map<String, dynamic>))
            .toList() ??
        [];

    final specsMap = (map['specs'] as Map<String, dynamic>?)?.map(
          (k, v) => MapEntry(k.toString(), v.toString()),
        ) ??
        {};

    return ProductModel(
      id: id,
      name: map['name'] as String? ?? 'Unnamed Product',
      price: priceVal,
      originalPrice: origPriceVal,
      discountPercent: discVal,
      description: map['description'] as String? ?? '',
      imageUrl: map['imageUrl'] as String? ?? '',
      videoUrl: map['videoUrl'] as String?,
      category: map['category'] as String? ?? 'General',
      rating: (map['rating'] as num?)?.toDouble() ?? 4.5,
      stock: (map['stock'] as num?)?.toInt() ?? 10,
      reviewCount: (map['reviewCount'] as num?)?.toInt() ?? reviewsList.length,
      isFeatured: map['isFeatured'] as bool? ?? false,
      sellerId: map['sellerId'] as String? ?? 'seller_shopease_official',
      sellerName: map['sellerName'] as String? ?? 'ShopEase Official Store',
      specs: specsMap,
      reviews: reviewsList,
    );
  }

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ProductModel.fromMap(data, doc.id);
  }

  ProductModel copyWith({
    String? id,
    String? name,
    double? price,
    double? originalPrice,
    int? discountPercent,
    String? description,
    String? imageUrl,
    String? videoUrl,
    String? category,
    double? rating,
    int? stock,
    int? reviewCount,
    bool? isFeatured,
    String? sellerId,
    String? sellerName,
    Map<String, String>? specs,
    List<ProductReview>? reviews,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      discountPercent: discountPercent ?? this.discountPercent,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      category: category ?? this.category,
      rating: rating ?? this.rating,
      stock: stock ?? this.stock,
      reviewCount: reviewCount ?? this.reviewCount,
      isFeatured: isFeatured ?? this.isFeatured,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      specs: specs ?? this.specs,
      reviews: reviews ?? this.reviews,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
