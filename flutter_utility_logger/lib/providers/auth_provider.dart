import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user.dart';
import '../utils/constants.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _token != null && _user != null;

  AuthProvider() {
    _loadAuthData();
  }

  Future<void> _loadAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenKey);
    final userData = prefs.getString(AppConstants.userKey);

    if (token != null && userData != null) {
      _token = token;
      _user = User.fromJson(json.decode(userData));
      notifyListeners();
    }
  }

  Future<void> _saveAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    if (_token != null) {
      await prefs.setString(AppConstants.tokenKey, _token!);
    }
    if (_user != null) {
      await prefs.setString(AppConstants.userKey, json.encode(_user!.toJson()));
    }
  }

  Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.userKey);
  }

  Future<bool> checkAuthStatus() async {
    await _loadAuthData();
    return isAuthenticated;
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}/api/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      final responseJson = json.decode(response.body);
      if (response.statusCode == 200 && responseJson['success'] == true) {
        _token = responseJson['data']['token'];
        _user = User.fromJson(responseJson['data']['user']);
        await _saveAuthData();
        _setLoading(false);
        return true;
      } else {
        _setError(responseJson['message'] ?? 'Login failed');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError(AppConstants.networkError);
      _setLoading(false);
      return false;
    }
  }

  Future<bool> register(String name, String email, String password,
      String passwordConfirmation) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}/api/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      );

      final responseJson = json.decode(response.body);
      if (response.statusCode == 201 && responseJson['success'] == true) {
        _token = responseJson['data']['token'];
        _user = User.fromJson(responseJson['data']['user']);
        await _saveAuthData();
        _setLoading(false);
        return true;
      } else {
        if (responseJson['errors'] != null) {
          final errors = responseJson['errors'] as Map<String, dynamic>;
          final errorMessages = errors.values
              .expand((e) => e is List ? e : [e])
              .where((e) => e is String)
              .cast<String>()
              .join(', ');
          _setError(errorMessages);
        } else {
          _setError(responseJson['message'] ?? 'Registration failed');
        }
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError(AppConstants.networkError);
      _setLoading(false);
      return false;
    }
  }

  Future<bool> logout() async {
    _setLoading(true);
    _clearError();
    try {
      if (_token != null) {
        await http.post(
          Uri.parse('${ApiEndpoints.baseUrl}/api/logout'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $_token',
          },
        );
      }
    } catch (e) {
      // Ignore logout errors
    } finally {
      _user = null;
      _token = null;
      await _clearAuthData();
      _setLoading(false);
      notifyListeners();
    }
    return true;
  }

  // Optionally expose a public clearAuthData for UI use
  Future<void> clearAuthData() async {
    _user = null;
    _token = null;
    await _clearAuthData();
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }

  // Helper method to get auth headers for API requests
  Map<String, String> getAuthHeaders() {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (_token != null) {
      headers['X-CSRF-TOKEN'] = _token!;
    }

    return headers;
  }
}
