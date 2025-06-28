import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/daily_reading.dart';
import '../utils/constants.dart';

class DailyReadingProvider with ChangeNotifier {
  List<DailyReading> _dailyReadings = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<DailyReading> get dailyReadings => _dailyReadings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Computed properties
  List<DailyReading> get sortedReadings {
    final sorted = List<DailyReading>.from(_dailyReadings);
    sorted.sort((a, b) {
      final dateComparison = b.readingDate.compareTo(a.readingDate);
      if (dateComparison != 0) return dateComparison;
      return b.readingTime.compareTo(a.readingTime);
    });
    return sorted;
  }

  Map<String, List<DailyReading>> get readingsByDate {
    final Map<String, List<DailyReading>> grouped = {};
    for (final reading in _dailyReadings) {
      final dateKey = reading.readingDate.toIso8601String().split('T')[0];
      grouped.putIfAbsent(dateKey, () => []).add(reading);
    }

    // Sort readings within each date by time (newest first)
    for (final date in grouped.keys) {
      grouped[date]!.sort((a, b) => b.readingTime.compareTo(a.readingTime));
    }

    return grouped;
  }

  // Initialize provider
  Future<void> initialize() async {
    await loadFromLocalStorage();
    await fetchDailyReadings();
  }

  // Fetch daily readings from API
  Future<void> fetchDailyReadings() async {
    _setLoading(true);
    _clearError();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.dailyReadings}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseJson = json.decode(response.body);
        if (responseJson['success'] == true) {
          final List<dynamic> data = responseJson['data'];
          _dailyReadings =
              data.map((json) => DailyReading.fromJson(json)).toList();

          await saveToLocalStorage();
          notifyListeners();
        } else {
          throw Exception(
              responseJson['message'] ?? 'Failed to fetch daily readings');
        }
      } else {
        throw Exception(
            'Failed to fetch daily readings: ${response.statusCode}');
      }
    } catch (e) {
      String errorMsg = e.toString();
      if (e is http.Response) {
        try {
          final errorJson = json.decode(e.body);
          if (errorJson is Map && errorJson['message'] != null) {
            errorMsg = errorJson['message'];
          }
        } catch (_) {}
      }
      _setError(errorMsg);
      debugPrint('Error fetching daily readings: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Create new daily reading
  Future<bool> createDailyReading({
    required int billingCycleId,
    required DateTime readingDate,
    required TimeOfDay readingTime,
    required double readingValue,
    String? notes,
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
        Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.dailyReadings}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'billing_cycle_id': billingCycleId,
          'reading_date': readingDate.toIso8601String().split('T')[0],
          'reading_time':
              '${readingTime.hour.toString().padLeft(2, '0')}:${readingTime.minute.toString().padLeft(2, '0')}',
          'reading_value': readingValue,
          'notes': notes,
        }),
      );

      if (response.statusCode == 201) {
        final responseJson = json.decode(response.body);
        if (responseJson['success'] == true) {
          final data = responseJson['data'];
          final newReading = DailyReading.fromJson(data);
          _dailyReadings.add(newReading);

          await saveToLocalStorage();
          notifyListeners();
          return true;
        } else {
          throw response;
        }
      } else {
        throw response;
      }
    } catch (e) {
      String errorMsg = e.toString();
      if (e is http.Response) {
        try {
          final errorJson = json.decode(e.body);
          if (errorJson is Map && errorJson['message'] != null) {
            errorMsg = errorJson['message'];
          }
        } catch (_) {}
      }
      _setError(errorMsg);
      debugPrint('Error creating daily reading: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Quick add daily reading
  Future<bool> quickAddDailyReading({
    required int billingCycleId,
    required double readingValue,
    required TimeOfDay readingTime,
    String? notes,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final now = DateTime.now();
      final response = await http.post(
        Uri.parse(
            '${ApiEndpoints.baseUrl}${ApiEndpoints.dailyReadings}${ApiEndpoints.dailyReadingsQuickStore}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'billing_cycle_id': billingCycleId,
          'reading_value': readingValue,
          'reading_time':
              '${readingTime.hour.toString().padLeft(2, '0')}:${readingTime.minute.toString().padLeft(2, '0')}',
          'notes': notes,
        }),
      );

      if (response.statusCode == 201) {
        final responseJson = json.decode(response.body);
        if (responseJson['success'] == true) {
          final data = responseJson['data'];
          final newReading = DailyReading.fromJson(data);
          _dailyReadings.add(newReading);

          await saveToLocalStorage();
          notifyListeners();
          return true;
        } else {
          throw response;
        }
      } else {
        throw response;
      }
    } catch (e) {
      String errorMsg = e.toString();
      if (e is http.Response) {
        try {
          final errorJson = json.decode(e.body);
          if (errorJson is Map && errorJson['message'] != null) {
            errorMsg = errorJson['message'];
          }
        } catch (_) {}
      }
      _setError(errorMsg);
      debugPrint('Error quick adding daily reading: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update daily reading
  Future<bool> updateDailyReading({
    required int id,
    DateTime? readingDate,
    TimeOfDay? readingTime,
    double? readingValue,
    String? notes,
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
      if (readingDate != null)
        updateData['reading_date'] =
            readingDate.toIso8601String().split('T')[0];
      if (readingTime != null)
        updateData['reading_time'] =
            '${readingTime.hour.toString().padLeft(2, '0')}:${readingTime.minute.toString().padLeft(2, '0')}';
      if (readingValue != null) updateData['reading_value'] = readingValue;
      if (notes != null) updateData['notes'] = notes;

      final response = await http.put(
        Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.dailyReadings}/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(updateData),
      );

      if (response.statusCode == 200) {
        final responseJson = json.decode(response.body);
        if (responseJson['success'] == true) {
          final data = responseJson['data'];
          final updatedReading = DailyReading.fromJson(data);

          final index =
              _dailyReadings.indexWhere((reading) => reading.id == id);
          if (index != -1) {
            _dailyReadings[index] = updatedReading;
          }

          await saveToLocalStorage();
          notifyListeners();
          return true;
        } else {
          throw response;
        }
      } else {
        throw response;
      }
    } catch (e) {
      String errorMsg = e.toString();
      if (e is http.Response) {
        try {
          final errorJson = json.decode(e.body);
          if (errorJson is Map && errorJson['message'] != null) {
            errorMsg = errorJson['message'];
          }
        } catch (_) {}
      }
      _setError(errorMsg);
      debugPrint('Error updating daily reading: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete daily reading
  Future<bool> deleteDailyReading(int id) async {
    _setLoading(true);
    _clearError();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.delete(
        Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.dailyReadings}/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        _dailyReadings.removeWhere((reading) => reading.id == id);

        await saveToLocalStorage();
        notifyListeners();
        return true;
      } else {
        throw Exception(
            'Failed to delete daily reading: ${response.statusCode}');
      }
    } catch (e) {
      _setError(e.toString());
      debugPrint('Error deleting daily reading: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get readings for a specific billing cycle
  List<DailyReading> getReadingsForCycle(int billingCycleId) {
    return _dailyReadings
        .where((reading) => reading.billingCycleId == billingCycleId)
        .toList();
  }

  // Get latest reading for a billing cycle
  DailyReading? getLatestReadingForCycle(int billingCycleId) {
    final cycleReadings = getReadingsForCycle(billingCycleId);
    if (cycleReadings.isEmpty) return null;

    cycleReadings.sort((a, b) {
      final dateComparison = b.readingDate.compareTo(a.readingDate);
      if (dateComparison != 0) return dateComparison;
      return b.readingTime.compareTo(a.readingTime);
    });

    return cycleReadings.first;
  }

  // Local storage methods
  Future<void> saveToLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final readingsJson =
          _dailyReadings.map((reading) => reading.toJson()).toList();
      await prefs.setString('daily_readings', json.encode(readingsJson));
    } catch (e) {
      debugPrint('Error saving daily readings to local storage: $e');
    }
  }

  Future<void> loadFromLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final readingsString = prefs.getString('daily_readings');

      if (readingsString != null) {
        final List<dynamic> readingsJson = json.decode(readingsString);
        _dailyReadings =
            readingsJson.map((json) => DailyReading.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading daily readings from local storage: $e');
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
    _dailyReadings.clear();
    _error = null;
    notifyListeners();
  }
}
