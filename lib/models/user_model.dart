import 'package:cloud_firestore/cloud_firestore.dart';
import 'order_model.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final DateTime createdAt;
  final String? photoUrl;
  final String? phoneNumber;
  final String? address;
  final String role; // 'customer', 'seller', 'delivery', 'admin'
  final List<ShippingAddress> savedAddresses;
  final List<String> wishlistProductIds;
  final bool isBlocked;
  final bool isVerifiedSeller;
  final String? sellerStoreName;
  final double sellerEarnings;
  final double sellerRating;
  final String? deliveryVehicleNumber;
  final double deliveryRating;
  final int deliveryTripsCompleted;
  final String deliveryStatus; // 'available', 'on_delivery', 'offline'

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.createdAt,
    this.photoUrl,
    this.phoneNumber,
    this.address,
    this.role = 'customer',
    this.savedAddresses = const [],
    this.wishlistProductIds = const [],
    this.isBlocked = false,
    this.isVerifiedSeller = false,
    this.sellerStoreName,
    this.sellerEarnings = 0.0,
    this.sellerRating = 4.8,
    this.deliveryVehicleNumber,
    this.deliveryRating = 4.9,
    this.deliveryTripsCompleted = 0,
    this.deliveryStatus = 'available',
  });

  String get id => uid;
  bool get isCustomer => role == 'customer';
  bool get isSeller => role == 'seller';
  bool get isDeliveryPartner => role == 'delivery';
  bool get isAdmin => role == 'admin';

  ShippingAddress? get defaultAddress {
    if (savedAddresses.isEmpty) return null;
    try {
      return savedAddresses.firstWhere((a) => a.isDefault);
    } catch (_) {
      return savedAddresses.first;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'createdAt': Timestamp.fromDate(createdAt),
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'address': address,
      'role': role,
      'savedAddresses': savedAddresses.map((a) => a.toMap()).toList(),
      'wishlistProductIds': wishlistProductIds,
      'isBlocked': isBlocked,
      'isVerifiedSeller': isVerifiedSeller,
      'sellerStoreName': sellerStoreName,
      'sellerEarnings': sellerEarnings,
      'sellerRating': sellerRating,
      'deliveryVehicleNumber': deliveryVehicleNumber,
      'deliveryRating': deliveryRating,
      'deliveryTripsCompleted': deliveryTripsCompleted,
      'deliveryStatus': deliveryStatus,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime parsedDate;
    if (map['createdAt'] is Timestamp) {
      parsedDate = (map['createdAt'] as Timestamp).toDate();
    } else if (map['createdAt'] is String) {
      parsedDate = DateTime.tryParse(map['createdAt']) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    final rawAddresses = map['savedAddresses'] as List<dynamic>? ?? [];
    final addressesList = rawAddresses
        .map((a) => ShippingAddress.fromMap(a as Map<String, dynamic>))
        .toList();

    final wishlistList = (map['wishlistProductIds'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    return UserModel(
      uid: id,
      name: map['name'] as String? ?? 'User',
      email: map['email'] as String? ?? '',
      createdAt: parsedDate,
      photoUrl: map['photoUrl'] as String?,
      phoneNumber: map['phoneNumber'] as String?,
      address: map['address'] as String?,
      role: map['role'] as String? ?? 'customer',
      savedAddresses: addressesList,
      wishlistProductIds: wishlistList,
      isBlocked: map['isBlocked'] as bool? ?? false,
      isVerifiedSeller: map['isVerifiedSeller'] as bool? ?? false,
      sellerStoreName: map['sellerStoreName'] as String?,
      sellerEarnings: (map['sellerEarnings'] as num?)?.toDouble() ?? 0.0,
      sellerRating: (map['sellerRating'] as num?)?.toDouble() ?? 4.8,
      deliveryVehicleNumber: map['deliveryVehicleNumber'] as String?,
      deliveryRating: (map['deliveryRating'] as num?)?.toDouble() ?? 4.9,
      deliveryTripsCompleted: (map['deliveryTripsCompleted'] as num?)?.toInt() ?? 0,
      deliveryStatus: map['deliveryStatus'] as String? ?? 'available',
    );
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel.fromMap(data, doc.id);
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    DateTime? createdAt,
    String? photoUrl,
    String? phoneNumber,
    String? address,
    String? role,
    List<ShippingAddress>? savedAddresses,
    List<String>? wishlistProductIds,
    bool? isBlocked,
    bool? isVerifiedSeller,
    String? sellerStoreName,
    double? sellerEarnings,
    double? sellerRating,
    String? deliveryVehicleNumber,
    double? deliveryRating,
    int? deliveryTripsCompleted,
    String? deliveryStatus,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      role: role ?? this.role,
      savedAddresses: savedAddresses ?? this.savedAddresses,
      wishlistProductIds: wishlistProductIds ?? this.wishlistProductIds,
      isBlocked: isBlocked ?? this.isBlocked,
      isVerifiedSeller: isVerifiedSeller ?? this.isVerifiedSeller,
      sellerStoreName: sellerStoreName ?? this.sellerStoreName,
      sellerEarnings: sellerEarnings ?? this.sellerEarnings,
      sellerRating: sellerRating ?? this.sellerRating,
      deliveryVehicleNumber:
          deliveryVehicleNumber ?? this.deliveryVehicleNumber,
      deliveryRating: deliveryRating ?? this.deliveryRating,
      deliveryTripsCompleted:
          deliveryTripsCompleted ?? this.deliveryTripsCompleted,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
    );
  }
}
