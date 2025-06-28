# Utility Bill Logger - Flutter Mobile App 📱

A modern Flutter mobile application that mirrors all features from the Laravel web application for tracking daily utility consumption. Built with Flutter and Provider state management, this app provides a native mobile experience for managing utility readings and billing cycles.

![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue?style=flat-square&logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.0+-blue?style=flat-square&logo=dart)
![Provider](https://img.shields.io/badge/Provider-6.1.1-blue?style=flat-square)
![Material Design](https://img.shields.io/badge/Material_Design-3.0-blue?style=flat-square)

## ✨ Features

### 🔐 Authentication
- **User Registration**: Create new accounts with email and password
- **User Login**: Secure authentication with email/password
- **Session Management**: Persistent login sessions
- **Form Validation**: Real-time validation with helpful error messages

### 📅 Billing Cycle Management
- **Create Cycles**: Set up new billing periods with start dates and readings
- **Active Cycle Tracking**: Monitor current active billing cycle
- **Cycle Statistics**: View consumption totals and progress
- **Cycle History**: Browse all past and current cycles

### 📊 Daily Reading Tracking
- **Quick Add**: Fast entry for today's reading with current time
- **Detailed Entry**: Full form with date, time, value, and notes
- **Reading Validation**: Smart validation prevents data inconsistencies
- **Reading History**: View all readings with filtering and sorting
- **Consumption Tracking**: Automatic calculation of consumed units

### 🎨 Modern UI/UX
- **Material Design 3**: Latest Material Design guidelines
- **Dark/Light Themes**: Automatic theme switching based on system
- **Responsive Design**: Optimized for all screen sizes
- **Smooth Animations**: Fluid transitions and micro-interactions
- **Intuitive Navigation**: Bottom navigation with clear sections

### 📱 Mobile-First Features
- **Touch-Optimized**: Large touch targets and gesture support
- **Offline-Ready**: Local data caching and offline support
- **Push Notifications**: Reminders for daily readings (planned)
- **Biometric Auth**: Fingerprint/Face ID support (planned)

## 🛠️ Technology Stack

- **Framework**: Flutter 3.0+
- **Language**: Dart 3.0+
- **State Management**: Provider 6.1.1
- **HTTP Client**: HTTP package with Dio
- **Local Storage**: SharedPreferences + SQLite
- **UI Components**: Material Design 3
- **Forms**: Flutter Form Builder
- **Validation**: Form Builder Validators
- **Date/Time**: Intl package
- **Charts**: FL Chart (planned)
- **Notifications**: Flutter Local Notifications

## 📋 Prerequisites

Before you begin, ensure you have the following installed:
- **Flutter SDK** 3.0 or higher
- **Dart SDK** 3.0 or higher
- **Android Studio** or **VS Code** with Flutter extensions
- **Android SDK** (for Android development)
- **Xcode** (for iOS development, macOS only)
- **Git**

## 🚀 Installation

### 1. Clone the Repository
```bash
git clone https://github.com/yourusername/utility-bill-logger.git
cd utility-bill-logger/flutter_utility_logger
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Configure Backend URL
Update the API base URL in `lib/utils/constants.dart`:
```dart
class ApiEndpoints {
  static const String baseUrl = 'http://your-laravel-backend-url.com';
  // ... rest of the endpoints
}
```

### 4. Run the App
```bash
# For development
flutter run

# For specific platform
flutter run -d android
flutter run -d ios
```

## 📱 App Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── user.dart
│   ├── billing_cycle.dart
│   └── daily_reading.dart
├── providers/                # State management
│   ├── auth_provider.dart
│   ├── billing_cycle_provider.dart
│   └── daily_reading_provider.dart
├── screens/                  # UI screens
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── dashboard/
│   │   └── dashboard_screen.dart
│   ├── billing_cycles/
│   │   ├── billing_cycles_screen.dart
│   │   ├── create_billing_cycle_screen.dart
│   │   └── edit_billing_cycle_screen.dart
│   ├── daily_readings/
│   │   ├── daily_readings_screen.dart
│   │   ├── create_reading_screen.dart
│   │   ├── edit_reading_screen.dart
│   │   └── quick_add_screen.dart
│   └── profile/
│       └── profile_screen.dart
├── utils/                    # Utilities
│   ├── constants.dart
│   └── theme.dart
└── widgets/                  # Reusable widgets
    ├── custom_app_bar.dart
    ├── loading_widget.dart
    └── error_widget.dart
```

## 🎨 UI Components

### Screens
- **Splash Screen**: App loading with logo animation
- **Login/Register**: Authentication forms with validation
- **Dashboard**: Overview with active cycle and quick actions
- **Daily Readings**: List of all readings with grouping by date
- **Billing Cycles**: Management of billing periods
- **Profile**: User settings and account management

### Widgets
- **Custom App Bar**: Consistent navigation header
- **Loading Widgets**: Various loading states
- **Error Widgets**: Error handling and display
- **Form Widgets**: Reusable form components
- **Card Widgets**: Information display cards

## 🔧 Configuration

### Environment Setup
1. **Development**: Uses local Laravel backend
2. **Production**: Configure production API endpoints
3. **Testing**: Mock data for testing scenarios

### API Integration
- **RESTful API**: Communicates with Laravel backend
- **Authentication**: CSRF token-based authentication
- **Error Handling**: Comprehensive error management
- **Data Sync**: Real-time data synchronization

### Local Storage
- **User Preferences**: Theme, language, settings
- **Authentication**: Token and user data caching
- **Offline Data**: Local database for offline access

## 🧪 Testing

### Unit Tests
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run with coverage
flutter test --coverage
```

### Widget Tests
```bash
# Test specific widget
flutter test test/widgets/custom_app_bar_test.dart
```

### Integration Tests
```bash
# Run integration tests
flutter drive --target=test_driver/app.dart
```

## 📦 Building for Production

### Android
```bash
# Build APK
flutter build apk --release

# Build App Bundle
flutter build appbundle --release
```

### iOS
```bash
# Build for iOS
flutter build ios --release
```

### Web (Optional)
```bash
# Build for web
flutter build web --release
```

## 🔄 State Management

### Provider Pattern
- **AuthProvider**: Manages user authentication state
- **BillingCycleProvider**: Handles billing cycle operations
- **DailyReadingProvider**: Manages daily reading data

### Data Flow
1. **UI** triggers action in Provider
2. **Provider** makes API call to backend
3. **Backend** processes request and returns response
4. **Provider** updates state and notifies UI
5. **UI** rebuilds with new data

## 🎯 Key Features Implementation

### Authentication Flow
```dart
// Login process
final authProvider = Provider.of<AuthProvider>(context, listen: false);
final success = await authProvider.login(email, password);
if (success) {
  Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
}
```

### Billing Cycle Management
```dart
// Create new billing cycle
final billingCycleProvider = Provider.of<BillingCycleProvider>(context, listen: false);
await billingCycleProvider.createBillingCycle(
  name: 'Summer 2024',
  startDate: DateTime.now(),
  startReading: 1000.0,
);
```

### Daily Reading Tracking
```dart
// Quick add reading
final dailyReadingProvider = Provider.of<DailyReadingProvider>(context, listen: false);
await dailyReadingProvider.quickAddReading(
  billingCycleId: activeCycle.id,
  readingValue: 1050.0,
  readingTime: DateTime.now(),
);
```

## 🚀 Performance Optimizations

### Code Optimization
- **Lazy Loading**: Load data only when needed
- **Caching**: Cache API responses locally
- **Image Optimization**: Compressed images and icons
- **Memory Management**: Proper disposal of resources

### UI Optimization
- **ListView.builder**: Efficient list rendering
- **const Constructors**: Reduce widget rebuilds
- **Hero Animations**: Smooth transitions
- **Skeleton Loading**: Better perceived performance

## 🔒 Security Features

### Data Protection
- **Secure Storage**: Encrypted local storage
- **Token Management**: Secure token handling
- **Input Validation**: Client-side validation
- **HTTPS Only**: Secure API communication

### Authentication Security
- **Password Requirements**: Strong password validation
- **Session Management**: Secure session handling
- **Logout**: Proper session cleanup
- **Biometric Auth**: Future implementation

## 📊 Analytics & Monitoring

### App Analytics
- **User Behavior**: Track user interactions
- **Performance Metrics**: Monitor app performance
- **Error Tracking**: Capture and report errors
- **Usage Statistics**: Understand app usage patterns

### Crash Reporting
- **Error Logging**: Comprehensive error logging
- **Crash Reports**: Automatic crash reporting
- **Performance Monitoring**: Real-time performance tracking

## 🗺️ Roadmap

### Phase 1 (Current)
- [x] **Core Features**: Authentication, billing cycles, readings
- [x] **UI/UX**: Material Design 3 implementation
- [x] **API Integration**: Full backend integration
- [x] **State Management**: Provider implementation

### Phase 2 (Next)
- [ ] **Offline Support**: Full offline functionality
- [ ] **Push Notifications**: Daily reading reminders
- [ ] **Charts & Analytics**: Visual data representation
- [ ] **Data Export**: CSV/PDF export functionality

### Phase 3 (Future)
- [ ] **Biometric Authentication**: Fingerprint/Face ID
- [ ] **Multi-language**: Internationalization support
- [ ] **Dark Mode**: Enhanced theme support
- [ ] **Widgets**: Home screen widgets

## 🤝 Contributing

### Development Setup
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Write tests for new features
5. Submit a pull request

### Code Standards
- **Dart Style**: Follow Dart style guide
- **Flutter Best Practices**: Use Flutter conventions
- **Testing**: Write unit and widget tests
- **Documentation**: Update documentation as needed

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Flutter](https://flutter.dev/) - Beautiful native apps in record time
- [Provider](https://pub.dev/packages/provider) - A wrapper around InheritedWidget
- [Material Design](https://material.io/) - Design system by Google
- [Laravel](https://laravel.com/) - The PHP framework for web artisans

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/yourusername/utility-bill-logger/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/utility-bill-logger/discussions)
- **Documentation**: [Flutter Docs](https://docs.flutter.dev/)

---

**Built with ❤️ using Flutter**

If you find this project helpful, please consider giving it a ⭐ on GitHub! 
