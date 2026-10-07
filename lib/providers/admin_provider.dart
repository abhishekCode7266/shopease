import 'package:flutter/foundation.dart';

class MonthlySalesData {
  final String month;
  final double sales;
  final int orders;

  const MonthlySalesData({
    required this.month,
    required this.sales,
    required this.orders,
  });
}

class AdminSellerApplication {
  final String id;
  final String applicantName;
  final String storeName;
  final String email;
  final String category;
  final String gstin;
  bool isApproved;

  AdminSellerApplication({
    required this.id,
    required this.applicantName,
    required this.storeName,
    required this.email,
    required this.category,
    required this.gstin,
    this.isApproved = false,
  });
}

class AdminProvider extends ChangeNotifier {
  double _totalSales = 128450.00;
  int _totalOrders = 1420;
  int _totalUsers = 5680;
  int _activeSellers = 48;
  double _platformNetRevenue = 25690.00; // 20% platform commission

  final List<MonthlySalesData> _monthlySales = const [
    MonthlySalesData(month: 'Jan', sales: 7800, orders: 85),
    MonthlySalesData(month: 'Feb', sales: 9400, orders: 102),
    MonthlySalesData(month: 'Mar', sales: 11200, orders: 124),
    MonthlySalesData(month: 'Apr', sales: 8900, orders: 98),
    MonthlySalesData(month: 'May', sales: 13500, orders: 145),
    MonthlySalesData(month: 'Jun', sales: 14200, orders: 156),
    MonthlySalesData(month: 'Jul', sales: 12100, orders: 130),
    MonthlySalesData(month: 'Aug', sales: 16800, orders: 180),
    MonthlySalesData(month: 'Sep', sales: 18900, orders: 210),
    MonthlySalesData(month: 'Oct', sales: 22400, orders: 245),
    MonthlySalesData(month: 'Nov', sales: 25100, orders: 275),
    MonthlySalesData(month: 'Dec', sales: 28600, orders: 310),
  ];

  final List<AdminSellerApplication> _sellerApplications = [
    AdminSellerApplication(
      id: 'app_1',
      applicantName: 'Vikram Sethi',
      storeName: 'AudioCrafters India',
      email: 'vikram@audiocrafters.in',
      category: 'Electronics',
      gstin: '07AAACZ1234F1Z8',
      isApproved: false,
    ),
    AdminSellerApplication(
      id: 'app_2',
      applicantName: 'Meera Rajput',
      storeName: 'Royal Threads Jaipur',
      email: 'meera@royalthreads.co',
      category: 'Fashion',
      gstin: '08BBBRP5678G2Z3',
      isApproved: false,
    ),
  ];

  final List<String> _blockedUserIds = [];

  double get totalSales => _totalSales;
  int get totalOrders => _totalOrders;
  int get totalUsers => _totalUsers;
  int get activeSellers => _activeSellers;
  double get platformNetRevenue => _platformNetRevenue;
  List<MonthlySalesData> get monthlySales => _monthlySales;
  List<AdminSellerApplication> get sellerApplications => List.unmodifiable(_sellerApplications);

  bool isUserBlocked(String uid) => _blockedUserIds.contains(uid);

  void toggleBlockUser(String uid) {
    if (_blockedUserIds.contains(uid)) {
      _blockedUserIds.remove(uid);
    } else {
      _blockedUserIds.add(uid);
    }
    notifyListeners();
  }

  void approveSeller(String id) {
    final index = _sellerApplications.indexWhere((a) => a.id == id);
    if (index >= 0) {
      _sellerApplications[index].isApproved = true;
      _activeSellers++;
      notifyListeners();
    }
  }

  void rejectSeller(String id) {
    _sellerApplications.removeWhere((a) => a.id == id);
    notifyListeners();
  }
}
