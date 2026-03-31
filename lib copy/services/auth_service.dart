import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService extends ChangeNotifier {
  AppUser? _currentUser;
  bool _isLoading = false;
  bool _isLoggedIn = false;

  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;

  AuthService() {
    _loadStoredUser();
  }

  Future<void> _loadStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId != null) {
      // In a real app, this would fetch from a backend.
      // For demo purposes, we use mock data.
      _currentUser = _mockUser(userId);
      _isLoggedIn = true;
      notifyListeners();
    }
  }

  AppUser _mockUser(String id) => AppUser(
    id: id,
    fullName: 'Jean-Baptiste Mbida',
    phone: '+237 6 XX XX XX XX',
    email: 'jb.mbida@email.com',
    userType: UserType.seller,
    city: 'Yaoundé',
    rating: 4.3,
    totalRatings: 12,
    totalListings: 8,
    totalSales: 5,
    joinedAt: DateTime(2024, 1, 15),
  );

  Future<bool> login(String phone, String password) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1)); // Simulate network

    final prefs = await SharedPreferences.getInstance();
    const userId = 'user_demo_001';
    await prefs.setString('userId', userId);

    _currentUser = _mockUser(userId);
    _isLoggedIn = true;
    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> register({
    required String fullName,
    required String phone,
    required String password,
    required UserType userType,
    required String city,
    String? businessName,
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    final prefs = await SharedPreferences.getInstance();
    final userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
    await prefs.setString('userId', userId);

    _currentUser = AppUser(
      id: userId,
      fullName: fullName,
      phone: phone,
      userType: userType,
      city: city,
      businessName: businessName,
      joinedAt: DateTime.now(),
    );
    _isLoggedIn = true;
    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    _currentUser = null;
    _isLoggedIn = false;
    notifyListeners();
  }
}
