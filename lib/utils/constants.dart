import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'ShopEase';
  static const String appTagline = 'Smart Shopping, Delivered Ease';
  static const String appVersion = '1.0.0';

  // Currency
  static const String currencySymbol = '\$';

  // Firestore Collections
  static const String collectionProducts = 'products';
  static const String collectionUsers = 'users';
  static const String collectionCart = 'cart';
  static const String collectionOrders = 'orders';

  // Categories
  static const List<String> categories = [
    'All',
    'Electronics',
    'Fashion',
    'Home & Living',
    'Books',
    'Beauty',
    'Sports',
  ];

  // Category Icons
  static IconData getCategoryIcon(String category) {
    switch (category) {
      case 'Electronics':
        return Icons.devices_outlined;
      case 'Fashion':
        return Icons.checkroom_outlined;
      case 'Home & Living':
        return Icons.chair_outlined;
      case 'Books':
        return Icons.menu_book_outlined;
      case 'Beauty':
        return Icons.spa_outlined;
      case 'Sports':
        return Icons.fitness_center_outlined;
      default:
        return Icons.grid_view_rounded;
    }
  }

  // Order Statuses
  static const String orderStatusPlaced = 'Placed';
  static const String orderStatusConfirmed = 'Confirmed';
  static const String orderStatusPacked = 'Packed';
  static const String orderStatusShipped = 'Shipped';
  static const String orderStatusOutForDelivery = 'Out for Delivery';
  static const String orderStatusDelivered = 'Delivered';
  static const String orderStatusCancelled = 'Cancelled';

  // Payment Methods
  static const String paymentCod = 'Cash on Delivery';
  static const String paymentCard = 'Credit / Debit Card';
  static const String paymentUpi = 'UPI';

  // Animation Durations
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
}
