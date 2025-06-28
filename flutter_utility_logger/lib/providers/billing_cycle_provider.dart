import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/billing_cycle.dart';
import '../utils/constants.dart';

class BillingCycleProvider with ChangeNotifier {
  List<BillingCycle> _billingCycles = [];
  BillingCycle? _activeCycle;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<BillingCycle> get billingCycles => _billingCycles;
  BillingCycle? get activeCycle => _activeCycle;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize provider
  Future<void> initialize() async {
    await loadFromLocalStorage();
    await fetchBillingCycles();
  }

  // Fetch billing cycles from API
  Future<void> fetchBillingCycles() async {
    _setLoading(true);
    _clearError();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.billingCycles),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        _billingCycles =
            data.map((json) => BillingCycle.fromJson(json)).toList();

        // Set active cycle
        _activeCycle =
            _billingCycles.where((cycle) => cycle.isActive).firstOrNull;

        await saveToLocalStorage();
        notifyListeners();
      } else {
        throw Exception(
            'Failed to fetch billing cycles: ${response.statusCode}');
      }
    } catch (e) {
      _setError(e.toString());
      debugPrint('Error fetching billing cycles: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Create new billing cycle
  Future<bool> createBillingCycle({
    required String name,
    required DateTime startDate,
    required double startReading,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.post(
        Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.billingCycles),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': name,
          'start_date': startDate.toIso8601String().split('T')[0],
          'start_reading': startReading,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body)['data'];
        final newCycle = BillingCycle.fromJson(data);
        _billingCycles.add(newCycle);

        // If this is the first cycle or marked as active, set it as active
        if (newCycle.isActive || _billingCycles.length == 1) {
          _activeCycle = newCycle;
        }

        await saveToLocalStorage();
        notifyListeners();
        return true;
      } else {
        throw Exception(
            'Failed to create billing cycle: ${response.statusCode}');
      }
    } catch (e) {
      _setError(e.toString());
      debugPrint('Error creating billing cycle: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update billing cycle
  Future<bool> updateBillingCycle({
    required int id,
    String? name,
    DateTime? startDate,
    double? startReading,
    DateTime? endDate,
    double? endReading,
    bool? isActive,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final Map<String, dynamic> updateData = {};
      if (name != null) updateData['name'] = name;
      if (startDate != null)
        updateData['start_date'] = startDate.toIso8601String().split('T')[0];
      if (startReading != null) updateData['start_reading'] = startReading;
      if (endDate != null)
        updateData['end_date'] = endDate.toIso8601String().split('T')[0];
      if (endReading != null) updateData['end_reading'] = endReading;
      if (isActive != null) updateData['is_active'] = isActive;

      final response = await http.put(
        Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.billingCycles + '/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(updateData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        final updatedCycle = BillingCycle.fromJson(data);

        final index = _billingCycles.indexWhere((cycle) => cycle.id == id);
        if (index != -1) {
          _billingCycles[index] = updatedCycle;

          // Update active cycle if needed
          if (updatedCycle.isActive) {
            _activeCycle = updatedCycle;
          } else if (_activeCycle?.id == id) {
            _activeCycle = null;
          }
        }

        await saveToLocalStorage();
        notifyListeners();
        return true;
      } else {
        throw Exception(
            'Failed to update billing cycle: ${response.statusCode}');
      }
    } catch (e) {
      _setError(e.toString());
      debugPrint('Error updating billing cycle: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete billing cycle
  Future<bool> deleteBillingCycle(int id) async {
    _setLoading(true);
    _clearError();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.delete(
        Uri.parse(ApiEndpoints.baseUrl + ApiEndpoints.billingCycles + '/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        _billingCycles.removeWhere((cycle) => cycle.id == id);

        // Remove from active cycle if it was deleted
        if (_activeCycle?.id == id) {
          _activeCycle = null;
        }

        await saveToLocalStorage();
        notifyListeners();
        return true;
      } else {
        throw Exception(
            'Failed to delete billing cycle: ${response.statusCode}');
      }
    } catch (e) {
      _setError(e.toString());
      debugPrint('Error deleting billing cycle: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Set active cycle
  Future<bool> setActiveCycle(int id) async {
    return await updateBillingCycle(id: id, isActive: true);
  }

  // Local storage methods
  Future<void> saveToLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cyclesJson = _billingCycles.map((cycle) => cycle.toJson()).toList();
      await prefs.setString('billing_cycles', json.encode(cyclesJson));
    } catch (e) {
      debugPrint('Error saving billing cycles to local storage: $e');
    }
  }

  Future<void> loadFromLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cyclesString = prefs.getString('billing_cycles');

      if (cyclesString != null) {
        final List<dynamic> cyclesJson = json.decode(cyclesString);
        _billingCycles =
            cyclesJson.map((json) => BillingCycle.fromJson(json)).toList();
        _activeCycle =
            _billingCycles.where((cycle) => cycle.isActive).firstOrNull;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading billing cycles from local storage: $e');
    }
  }

  // Helper methods
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

  void clearData() {
    _billingCycles.clear();
    _activeCycle = null;
    _error = null;
    notifyListeners();
  }
}
