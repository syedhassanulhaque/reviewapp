// lib/providers/auth_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  final FlutterSecureStorage _secureStorage;
  User? _user;
  bool _isAuthenticated = false;

  AuthProvider({required FlutterSecureStorage secureStorage})
      : _secureStorage = secureStorage;

  User? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  bool get isBrand => _user?.type == UserType.brand;

  Future<void> login(String email, String password, {UserType? role}) async {
    // Mock login - in a real app, this would be an API call
    final resolvedType = role ?? (email.contains('brand') ? UserType.brand : UserType.influencer);
    _user = User(
      id: '1',
      email: email,
      displayName: email.split('@')[0],
      type: resolvedType,
      createdAt: DateTime.now(),
    );
    _isAuthenticated = true;
    await _secureStorage.write(key: 'auth_token', value: 'dummy_token');
    notifyListeners();
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: 'auth_token');
    _user = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  Future<bool> checkAuth() async {
    final token = await _secureStorage.read(key: 'auth_token');
    _isAuthenticated = token != null;
    return _isAuthenticated;
  }

  // Initialize auth state
  Future<void> initialize() async {
    await checkAuth();
    // Add any other initialization logic here
  }

  // Reset password method
  Future<void> resetPassword(String email) async {
    // In a real app, this would send a password reset email
    await Future.delayed(const Duration(seconds: 1));
    // No need to update state here as we're just sending an email
  }

  String? get email => _user?.email;
}