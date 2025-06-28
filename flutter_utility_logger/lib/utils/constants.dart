class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String billingCycles = '/billing-cycles';
  static const String billingCycleCreate = '/billing-cycles/create';
  static const String billingCycleEdit = '/billing-cycles/edit';
  static const String billingCycleShow = '/billing-cycles/show';
  static const String dailyReadings = '/daily-readings';
  static const String dailyReadingCreate = '/daily-readings/create';
  static const String dailyReadingEdit = '/daily-readings/edit';
  static const String dailyReadingShow = '/daily-readings/show';
  static const String profile = '/profile';
  static const String settings = '/settings';
}

class ApiEndpoints {
  // Base URL - Update this to match your Laravel backend
  static const String baseUrl = 'http://192.168.1.9:8000';

  // Auth endpoints
  static const String login = '/api/login';
  static const String register = '/api/register';
  static const String logout = '/api/logout';

  // Billing cycles endpoints
  static const String billingCycles = '/api/billing-cycles';

  // Daily readings endpoints
  static const String dailyReadings = '/api/daily-readings';
}

class AppConstants {
  // App info
  static const String appName = 'Utility Bill Logger';
  static const String appVersion = '1.0.0';

  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String themeKey = 'app_theme';
  static const String languageKey = 'app_language';

  // Validation messages
  static const String requiredField = 'This field is required';
  static const String invalidEmail = 'Please enter a valid email address';
  static const String passwordTooShort =
      'Password must be at least 8 characters';
  static const String passwordsDoNotMatch = 'Passwords do not match';
  static const String invalidReadingValue =
      'Reading value must be greater than 0';
  static const String invalidDate = 'Date cannot be in the future';
  static const String duplicateReading =
      'A reading already exists for this date and time';

  // Success messages
  static const String loginSuccess = 'Login successful';
  static const String registerSuccess = 'Registration successful';
  static const String logoutSuccess = 'Logout successful';
  static const String billingCycleCreated =
      'Billing cycle created successfully';
  static const String billingCycleUpdated =
      'Billing cycle updated successfully';
  static const String billingCycleDeleted =
      'Billing cycle deleted successfully';
  static const String readingAdded = 'Daily reading added successfully';
  static const String readingUpdated = 'Daily reading updated successfully';
  static const String readingDeleted = 'Daily reading deleted successfully';

  // Error messages
  static const String networkError =
      'Network error. Please check your connection';
  static const String serverError = 'Server error. Please try again later';
  static const String unauthorized = 'Unauthorized. Please login again';
  static const String validationError = 'Please check your input and try again';

  // UI constants
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 12.0;
  static const double defaultElevation = 2.0;
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);

  // Chart colors
  static const List<int> chartColors = [
    0xFF3B82F6, // Blue
    0xFF10B981, // Green
    0xFFF59E0B, // Yellow
    0xFFEF4444, // Red
    0xFF8B5CF6, // Purple
    0xFF06B6D4, // Cyan
    0xFF84CC16, // Lime
    0xFFF97316, // Orange
  ];
}

class DatabaseConstants {
  static const String databaseName = 'utility_logger.db';
  static const int databaseVersion = 1;

  // Table names
  static const String usersTable = 'users';
  static const String billingCyclesTable = 'billing_cycles';
  static const String dailyReadingsTable = 'daily_readings';

  // Column names
  static const String id = 'id';
  static const String userId = 'user_id';
  static const String name = 'name';
  static const String email = 'email';
  static const String password = 'password';
  static const String startDate = 'start_date';
  static const String startReading = 'start_reading';
  static const String endDate = 'end_date';
  static const String endReading = 'end_reading';
  static const String isActive = 'is_active';
  static const String billingCycleId = 'billing_cycle_id';
  static const String readingDate = 'reading_date';
  static const String readingTime = 'reading_time';
  static const String readingValue = 'reading_value';
  static const String notes = 'notes';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
}
