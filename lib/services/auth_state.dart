import 'package:flutter/foundation.dart';
import 'package:myportfolio_mobile/services/api_client.dart';

class AuthState extends ChangeNotifier {
  AuthState(this._apiClient);

  final ApiClient _apiClient;
  String? _token;
  Future<void>? _signOut;

  String? get token => _token;
  bool get isLoggedIn => _token != null;

  Future<void> login(String username, String password) async {
    try {
      await _signOut;
    } catch (_) {
      // The logout action reports its own failure. A new login can still proceed.
    }
    _token = await _apiClient.obtainToken(username, password);
    notifyListeners();
  }

  Future<void> logout() async {
    final current = _token;
    if (current == null) return;

    _token = null;
    final request = _apiClient.logout(token: current);
    _signOut = request;
    notifyListeners();
    try {
      await request;
    } finally {
      _signOut = null;
    }
  }

  void expire(String token) {
    if (_token == token) {
      _token = null;
      notifyListeners();
    }
  }
}
