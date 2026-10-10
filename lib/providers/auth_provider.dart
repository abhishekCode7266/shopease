import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/order_model.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../utils/sample_data.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  UserModel? _user;
  bool _isLoading = false;
  bool _isDeveloperMode = false;
  String? _errorMessage;
  StreamSubscription<User?>? _authSubscription;

  AuthProvider({AuthService? authService})
      : _authService = authService ?? AuthService() {
    _initAuthListener();
  }

  UserModel? get user => _user;
  UserModel? get currentUser => _user;
  String? get currentUserId => _user?.uid;
  bool get isAuthenticated => _user != null;
  bool get isDeveloperMode => _isDeveloperMode;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String get currentRole => _user?.role ?? 'customer';
  bool get isCustomer => _user?.isCustomer ?? true;
  bool get isSeller => _user?.isSeller ?? false;
  bool get isAdmin => _user?.isAdmin ?? false;

  List<String> get wishlistProductIds => _user?.wishlistProductIds ?? [];
  List<ShippingAddress> get savedAddresses => _user?.savedAddresses ?? [];
  ShippingAddress? get defaultAddress => _user?.defaultAddress;

  bool isWishlisted(String productId) {
    return _user?.wishlistProductIds.contains(productId) ?? false;
  }

  bool isInWishlist(String productId) => isWishlisted(productId);

  void _initAuthListener() {
    try {
      _authSubscription = _authService.authStateChanges.listen((firebaseUser) async {
        if (_isDeveloperMode) return;
        if (firebaseUser != null) {
          _user = await _authService.getUserProfile(firebaseUser.uid) ??
              UserModel(
                uid: firebaseUser.uid,
                name: firebaseUser.displayName ?? 'Shopper',
                email: firebaseUser.email ?? '',
                createdAt: DateTime.now(),
                savedAddresses: SampleData.sampleAddresses,
                wishlistProductIds: ['prod_elec_01', 'prod_fash_03'],
              );
        } else {
          _user = null;
        }
        notifyListeners();
      }, onError: (_) {});
    } catch (_) {}
  }

  // Developer Bypass Mode with Role Selection (Customer, Seller, Delivery, Super Admin)
  void activateDeveloperBypass({
    String role = 'admin', // 'admin', 'seller', 'delivery', 'customer'
    String? name,
    String? email,
    String? uid,
  }) {
    _isDeveloperMode = true;

    String defaultName;
    String defaultEmail;
    String defaultUid;
    String? storeName;

    if (role == 'admin') {
      defaultName = name ?? 'Abhishek (Super Admin)';
      defaultEmail = email ?? 'admin@starshop.com';
      defaultUid = uid ?? 'dev_admin_abhishek';
    } else if (role == 'seller') {
      defaultName = name ?? 'Abhishek (Apex Audio Seller)';
      defaultEmail = email ?? 'seller.apex@starshop.com';
      defaultUid = uid ?? 'seller_apex_audio';
      storeName = 'Apex Audio Labs Official';
    } else if (role == 'delivery') {
      defaultName = name ?? 'Abhishek StarRider';
      defaultEmail = email ?? 'rider.abhishek@starshop.com';
      defaultUid = uid ?? 'rider_dev_7266';
    } else {
      defaultName = name ?? 'Abhishek (Premium Shopper)';
      defaultEmail = email ?? 'abhishek.shopper@starshop.com';
      defaultUid = uid ?? 'dev_customer_abhishek';
    }

    _user = UserModel(
      uid: defaultUid,
      name: defaultName,
      email: defaultEmail,
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
      phoneNumber: '+91 9876543210',
      address: 'Plot 42, DLF Cyber City, Gurugram, Haryana - 122002',
      role: role,
      savedAddresses: SampleData.sampleAddresses,
      wishlistProductIds: ['prod_elec_01', 'prod_fash_03'],
      isVerifiedSeller: role == 'seller' || role == 'admin',
      sellerStoreName: storeName,
      sellerEarnings: 84250.00,
      sellerRating: 4.9,
      deliveryVehicleNumber: role == 'delivery' ? 'DL 01 ST 7266' : null,
      deliveryRating: 4.9,
      deliveryTripsCompleted: role == 'delivery' ? 29 : 0,
      deliveryStatus: 'available',
    );
    _errorMessage = null;
    notifyListeners();
  }

  void bypassLogin({String role = 'customer', String? name, String? email}) {
    activateDeveloperBypass(role: role, name: name, email: email);
  }

  void switchRole(String newRole) {
    if (_user == null) return;
    _user = _user!.copyWith(role: newRole);
    notifyListeners();
  }

  void exitDeveloperMode() {
    _isDeveloperMode = false;
    _user = null;
    notifyListeners();
  }

  // Wishlist toggle
  void toggleWishlist(String productId) {
    if (_user == null) return;
    final currentList = List<String>.from(_user!.wishlistProductIds);
    if (currentList.contains(productId)) {
      currentList.remove(productId);
    } else {
      currentList.add(productId);
    }
    _user = _user!.copyWith(wishlistProductIds: currentList);
    notifyListeners();
  }

  // Address Management
  void addAddress(ShippingAddress address) {
    if (_user == null) return;
    final addresses = List<ShippingAddress>.from(_user!.savedAddresses);
    if (address.isDefault) {
      for (var i = 0; i < addresses.length; i++) {
        addresses[i] = addresses[i].copyWith(isDefault: false);
      }
    }
    addresses.add(address);
    _user = _user!.copyWith(savedAddresses: addresses);
    notifyListeners();
  }

  void removeAddress(String addressId) {
    if (_user == null) return;
    final addresses = List<ShippingAddress>.from(_user!.savedAddresses)
      ..removeWhere((a) => a.id == addressId);
    _user = _user!.copyWith(savedAddresses: addresses);
    notifyListeners();
  }

  void deleteAddress(String addressId) => removeAddress(addressId);

  void updateAddress(ShippingAddress address) {
    if (_user == null) return;
    final addresses = List<ShippingAddress>.from(_user!.savedAddresses);
    final idx = addresses.indexWhere((a) => a.id == address.id);
    if (idx >= 0) {
      if (address.isDefault) {
        for (var i = 0; i < addresses.length; i++) {
          addresses[i] = addresses[i].copyWith(isDefault: false);
        }
      }
      addresses[idx] = address;
      _user = _user!.copyWith(savedAddresses: addresses);
      notifyListeners();
    }
  }

  void setDefaultAddress(String addressId) {
    if (_user == null) return;
    final addresses = _user!.savedAddresses.map((a) {
      return a.copyWith(isDefault: a.id == addressId);
    }).toList();
    _user = _user!.copyWith(savedAddresses: addresses);
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Sign Up
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    String role = 'customer',
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final baseUser = await _authService.signUp(
        name: name,
        email: email,
        password: password,
      );
      _user = baseUser.copyWith(
        role: role,
        savedAddresses: SampleData.sampleAddresses,
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Sign In
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final baseUser = await _authService.signIn(
        email: email,
        password: password,
      );
      _user = baseUser.copyWith(
        savedAddresses: baseUser.savedAddresses.isEmpty
            ? SampleData.sampleAddresses
            : baseUser.savedAddresses,
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    _setLoading(true);
    try {
      if (_isDeveloperMode) {
        _isDeveloperMode = false;
        _user = null;
      } else {
        await _authService.signOut();
        _user = null;
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Send Password Reset
  Future<bool> sendPasswordReset(String email) async {
    _setLoading(true);
    _setError(null);
    try {
      await _authService.sendPasswordReset(email);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Update Profile Name
  Future<bool> updateProfileName(String newName) async {
    _setLoading(true);
    _setError(null);
    try {
      await _authService.updateProfileName(newName);
      if (_user != null) {
        _user = _user!.copyWith(name: newName);
      }
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Security & App Settings
  bool _biometricEnabled = true;
  bool _appLockEnabled = false;
  String _appLockPin = '1234';
  int _autoLockTimeoutMinutes = 5;
  bool _aiPersonalizationEnabled = true;
  String _appLanguage = 'English';

  bool get biometricEnabled => _biometricEnabled;
  bool get appLockEnabled => _appLockEnabled;
  String get appLockPin => _appLockPin;
  int get autoLockTimeoutMinutes => _autoLockTimeoutMinutes;
  bool get aiPersonalizationEnabled => _aiPersonalizationEnabled;
  String get appLanguage => _appLanguage;

  void toggleBiometrics(bool enabled) {
    _biometricEnabled = enabled;
    notifyListeners();
  }

  void setAppLock({required bool enabled, String? pin}) {
    _appLockEnabled = enabled;
    if (pin != null && pin.isNotEmpty) {
      _appLockPin = pin;
    }
    notifyListeners();
  }

  void setAutoLockTimeout(int minutes) {
    _autoLockTimeoutMinutes = minutes;
    notifyListeners();
  }

  void setAiPersonalization(bool enabled) {
    _aiPersonalizationEnabled = enabled;
    notifyListeners();
  }

  void setLanguage(String lang) {
    _appLanguage = lang;
    notifyListeners();
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _setLoading(true);
    _setError(null);
    await Future.delayed(const Duration(milliseconds: 600));
    _setLoading(false);
    notifyListeners();
    return true;
  }

  Future<bool> deleteAccount() async {
    _setLoading(true);
    try {
      if (!_isDeveloperMode) {
        try {
          await _authService.deleteAccount();
        } catch (_) {}
      }
      _user = null;
      _isDeveloperMode = false;
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
