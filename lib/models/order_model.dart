import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_item_model.dart';

class OrderItem {
  final String productId;
  final String name;
  final double price;
  final String imageUrl;
  final int quantity;

  OrderItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.quantity,
  });

  double get subtotal => price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'quantity': quantity,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: map['imageUrl'] as String? ?? '',
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
    );
  }

  factory OrderItem.fromCartItem(CartItemModel item) {
    return OrderItem(
      productId: item.productId,
      name: item.name,
      price: item.price,
      imageUrl: item.imageUrl,
      quantity: item.quantity,
    );
  }
}

class ShippingAddress {
  final String id;
  final String label; // 'Home', 'Work', 'Other'
  final String fullName;
  final String phone;
  final String street;
  final String city;
  final String state;
  final String postalCode;
  final bool isDefault;

  ShippingAddress({
    String? id,
    this.label = 'Home',
    required this.fullName,
    required this.phone,
    required this.street,
    required this.city,
    required this.state,
    required this.postalCode,
    this.isDefault = false,
  }) : id = id ?? 'addr_${DateTime.now().millisecondsSinceEpoch}';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'fullName': fullName,
      'phone': phone,
      'street': street,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'isDefault': isDefault,
    };
  }

  factory ShippingAddress.fromMap(Map<String, dynamic> map) {
    return ShippingAddress(
      id: map['id'] as String? ?? 'addr_default',
      label: map['label'] as String? ?? 'Home',
      fullName: map['fullName'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      street: map['street'] as String? ?? '',
      city: map['city'] as String? ?? '',
      state: map['state'] as String? ?? '',
      postalCode: map['postalCode'] as String? ?? '',
      isDefault: map['isDefault'] as bool? ?? false,
    );
  }

  String get fullAddress => '$street, $city, $state - $postalCode';

  ShippingAddress copyWith({
    String? id,
    String? label,
    String? fullName,
    String? phone,
    String? street,
    String? city,
    String? state,
    String? postalCode,
    bool? isDefault,
  }) {
    return ShippingAddress(
      id: id ?? this.id,
      label: label ?? this.label,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      street: street ?? this.street,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}

class OrderTimeline {
  final DateTime confirmedAt;
  final DateTime? packedAt;
  final DateTime? shippedAt;
  final DateTime? outForDeliveryAt;
  final DateTime? deliveredAt;

  OrderTimeline({
    required this.confirmedAt,
    this.packedAt,
    this.shippedAt,
    this.outForDeliveryAt,
    this.deliveredAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'confirmedAt': Timestamp.fromDate(confirmedAt),
      'packedAt': packedAt != null ? Timestamp.fromDate(packedAt!) : null,
      'shippedAt': shippedAt != null ? Timestamp.fromDate(shippedAt!) : null,
      'outForDeliveryAt': outForDeliveryAt != null ? Timestamp.fromDate(outForDeliveryAt!) : null,
      'deliveredAt': deliveredAt != null ? Timestamp.fromDate(deliveredAt!) : null,
    };
  }

  factory OrderTimeline.fromMap(Map<String, dynamic> map) {
    DateTime parseDate(dynamic v, DateTime fallback) {
      if (v is Timestamp) return v.toDate();
      if (v is String) return DateTime.tryParse(v) ?? fallback;
      return fallback;
    }

    final confirmed = parseDate(map['confirmedAt'], DateTime.now());
    return OrderTimeline(
      confirmedAt: confirmed,
      packedAt: map['packedAt'] != null ? parseDate(map['packedAt'], confirmed) : null,
      shippedAt: map['shippedAt'] != null ? parseDate(map['shippedAt'], confirmed) : null,
      outForDeliveryAt: map['outForDeliveryAt'] != null ? parseDate(map['outForDeliveryAt'], confirmed) : null,
      deliveredAt: map['deliveredAt'] != null ? parseDate(map['deliveredAt'], confirmed) : null,
    );
  }
}

class OrderModel {
  final String id;
  final String invoiceNumber;
  final String userId;
  final List<OrderItem> items;
  final double subtotal;
  final double discount;
  final String? couponCode;
  final double tax;
  final double deliveryCharge;
  final double total;
  final ShippingAddress address;
  final String paymentMethod;
  final String status; // 'Confirmed', 'Packed', 'Shipped', 'Out for Delivery', 'Delivered', 'Cancelled'
  final String trackingId;
  final String deliveryPartner;
  final DateTime estimatedDeliveryDate;
  final DateTime createdAt;
  final OrderTimeline timeline;
  final String? cancelReason;
  final String returnStatus; // 'none', 'requested', 'approved', 'refunded', 'rejected'
  final String? returnReason;
  final double? refundAmount;

  OrderModel({
    required this.id,
    String? invoiceNumber,
    required this.userId,
    required this.items,
    double? subtotal,
    this.discount = 0.0,
    this.couponCode,
    double? tax,
    double? deliveryCharge,
    required this.total,
    required this.address,
    required this.paymentMethod,
    this.status = 'Confirmed',
    String? trackingId,
    String? deliveryPartner,
    DateTime? estimatedDeliveryDate,
    required this.createdAt,
    OrderTimeline? timeline,
    this.cancelReason,
    this.returnStatus = 'none',
    this.returnReason,
    this.refundAmount,
  })  : invoiceNumber = invoiceNumber ?? 'INV-${DateTime.now().year}-${id.replaceAll(RegExp(r'[^0-9]'), '').padRight(5, '0').substring(0, 5)}',
        subtotal = subtotal ?? items.fold(0.0, (sum, i) => sum + i.subtotal),
        tax = tax ?? (items.fold(0.0, (sum, i) => sum + i.subtotal) * 0.18), // 18% GST standard
        deliveryCharge = deliveryCharge ?? (total >= 50 ? 0.0 : 5.0),
        trackingId = trackingId ?? 'STAR-TRK-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
        deliveryPartner = deliveryPartner ?? 'StarShop Express (BlueDart)',
        estimatedDeliveryDate = estimatedDeliveryDate ?? createdAt.add(const Duration(days: 3)),
        timeline = timeline ?? OrderTimeline(confirmedAt: createdAt);

  bool get isCancellable => status == 'Confirmed' || status == 'Packed';
  bool get isReturnable => status == 'Delivered' && returnStatus == 'none';

  Map<String, dynamic> toMap() {
    return {
      'invoiceNumber': invoiceNumber,
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'discount': discount,
      'couponCode': couponCode,
      'tax': tax,
      'deliveryCharge': deliveryCharge,
      'total': total,
      'address': address.toMap(),
      'paymentMethod': paymentMethod,
      'status': status,
      'trackingId': trackingId,
      'deliveryPartner': deliveryPartner,
      'estimatedDeliveryDate': Timestamp.fromDate(estimatedDeliveryDate),
      'createdAt': Timestamp.fromDate(createdAt),
      'timeline': timeline.toMap(),
      'cancelReason': cancelReason,
      'returnStatus': returnStatus,
      'returnReason': returnReason,
      'refundAmount': refundAmount,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime parseDate(dynamic v) {
      if (v is Timestamp) return v.toDate();
      if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
      return DateTime.now();
    }

    final rawItems = map['items'] as List<dynamic>? ?? [];
    final itemsList = rawItems
        .map((e) => OrderItem.fromMap(e as Map<String, dynamic>))
        .toList();

    final addressMap = map['address'] as Map<String, dynamic>? ?? {};
    final createdDate = parseDate(map['createdAt']);

    return OrderModel(
      id: id,
      invoiceNumber: map['invoiceNumber'] as String?,
      userId: map['userId'] as String? ?? '',
      items: itemsList,
      subtotal: (map['subtotal'] as num?)?.toDouble(),
      discount: (map['discount'] as num?)?.toDouble() ?? 0.0,
      couponCode: map['couponCode'] as String?,
      tax: (map['tax'] as num?)?.toDouble(),
      deliveryCharge: (map['deliveryCharge'] as num?)?.toDouble(),
      total: (map['total'] as num?)?.toDouble() ?? 0.0,
      address: ShippingAddress.fromMap(addressMap),
      paymentMethod: map['paymentMethod'] as String? ?? 'Cash on Delivery',
      status: map['status'] as String? ?? 'Confirmed',
      trackingId: map['trackingId'] as String?,
      deliveryPartner: map['deliveryPartner'] as String?,
      estimatedDeliveryDate: map['estimatedDeliveryDate'] != null
          ? parseDate(map['estimatedDeliveryDate'])
          : null,
      createdAt: createdDate,
      timeline: map['timeline'] != null
          ? OrderTimeline.fromMap(map['timeline'] as Map<String, dynamic>)
          : null,
      cancelReason: map['cancelReason'] as String?,
      returnStatus: map['returnStatus'] as String? ?? 'none',
      returnReason: map['returnReason'] as String?,
      refundAmount: (map['refundAmount'] as num?)?.toDouble(),
    );
  }

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return OrderModel.fromMap(data, doc.id);
  }

  OrderModel copyWith({
    String? id,
    String? invoiceNumber,
    String? userId,
    List<OrderItem>? items,
    double? subtotal,
    double? discount,
    String? couponCode,
    double? tax,
    double? deliveryCharge,
    double? total,
    ShippingAddress? address,
    String? paymentMethod,
    String? status,
    String? trackingId,
    String? deliveryPartner,
    DateTime? estimatedDeliveryDate,
    DateTime? createdAt,
    OrderTimeline? timeline,
    String? cancelReason,
    String? returnStatus,
    String? returnReason,
    double? refundAmount,
  }) {
    return OrderModel(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      couponCode: couponCode ?? this.couponCode,
      tax: tax ?? this.tax,
      deliveryCharge: deliveryCharge ?? this.deliveryCharge,
      total: total ?? this.total,
      address: address ?? this.address,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      trackingId: trackingId ?? this.trackingId,
      deliveryPartner: deliveryPartner ?? this.deliveryPartner,
      estimatedDeliveryDate: estimatedDeliveryDate ?? this.estimatedDeliveryDate,
      createdAt: createdAt ?? this.createdAt,
      timeline: timeline ?? this.timeline,
      cancelReason: cancelReason ?? this.cancelReason,
      returnStatus: returnStatus ?? this.returnStatus,
      returnReason: returnReason ?? this.returnReason,
      refundAmount: refundAmount ?? this.refundAmount,
    );
  }
}
