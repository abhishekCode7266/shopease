class CouponModel {
  final String code;
  final String title;
  final String description;
  final double discountPercent;
  final double minOrderAmount;
  final double maxDiscountAmount;
  final bool isFreeShipping;

  const CouponModel({
    required this.code,
    required this.title,
    required this.description,
    this.discountPercent = 0.0,
    this.minOrderAmount = 0.0,
    this.maxDiscountAmount = 100.0,
    this.isFreeShipping = false,
  });

  double calculateDiscount(double subtotal) {
    if (subtotal < minOrderAmount) return 0.0;
    if (discountPercent <= 0) return 0.0;
    final discount = subtotal * (discountPercent / 100.0);
    return discount > maxDiscountAmount ? maxDiscountAmount : discount;
  }

  static const List<CouponModel> availableCoupons = [
    CouponModel(
      code: 'WELCOME50',
      title: 'Flat 50% Off First Order',
      description: 'Get 50% discount up to ₹500 / \$50 on orders above \$30',
      discountPercent: 50.0,
      minOrderAmount: 30.0,
      maxDiscountAmount: 50.0,
    ),
    CouponModel(
      code: 'EASE20',
      title: '20% Mega Savings',
      description: 'Get 20% instant off on all electronics & fashion items',
      discountPercent: 20.0,
      minOrderAmount: 20.0,
      maxDiscountAmount: 40.0,
    ),
    CouponModel(
      code: 'FREESHIP',
      title: 'Free Express Delivery',
      description: 'Waive shipping fees on your current order',
      isFreeShipping: true,
    ),
    CouponModel(
      code: 'FESTIVE10',
      title: 'Festive 10% Extra',
      description: 'Extra 10% off on all catalog purchases',
      discountPercent: 10.0,
      minOrderAmount: 15.0,
      maxDiscountAmount: 25.0,
    ),
  ];
}
