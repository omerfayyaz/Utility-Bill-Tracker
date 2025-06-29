import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utility_bill_logger/providers/auth_provider.dart';
import 'package:utility_bill_logger/providers/billing_cycle_provider.dart';
import 'package:utility_bill_logger/providers/daily_reading_provider.dart';
import 'package:utility_bill_logger/screens/auth/login_screen.dart';
import 'package:utility_bill_logger/screens/auth/register_screen.dart';
import 'package:utility_bill_logger/screens/dashboard/dashboard_screen.dart';
import 'package:utility_bill_logger/screens/billing_cycles/billing_cycle_create_screen.dart';
import 'package:utility_bill_logger/screens/daily_readings/daily_reading_create_screen.dart';
import 'package:utility_bill_logger/screens/billing_cycles/billing_cycle_edit_screen.dart';
import 'package:utility_bill_logger/screens/billing_cycles/billing_cycle_show_screen.dart';
import 'package:utility_bill_logger/screens/daily_readings/daily_reading_edit_screen.dart';
import 'package:utility_bill_logger/screens/daily_readings/daily_reading_show_screen.dart';
import 'package:utility_bill_logger/utils/theme.dart';
import 'package:utility_bill_logger/utils/constants.dart';

void main() {
  runApp(const UtilityBillLoggerApp());
}

class UtilityBillLoggerApp extends StatelessWidget {
  const UtilityBillLoggerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BillingCycleProvider()),
        ChangeNotifierProvider(create: (_) => DailyReadingProvider()),
      ],
      child: MaterialApp(
        title: 'Utility Bill Logger',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.splash,
        routes: {
          AppRoutes.splash: (context) => const SplashScreen(),
          AppRoutes.login: (context) => const LoginScreen(),
          AppRoutes.register: (context) => const RegisterScreen(),
          AppRoutes.dashboard: (context) => const DashboardScreen(),
          AppRoutes.billingCycleCreate: (context) =>
              const BillingCycleCreateScreen(),
          AppRoutes.dailyReadingCreate: (context) =>
              const DailyReadingCreateScreen(),
          AppRoutes.billingCycleEdit: (context) =>
              const BillingCycleEditScreen(),
          AppRoutes.billingCycleShow: (context) =>
              const BillingCycleShowScreen(),
          AppRoutes.dailyReadingEdit: (context) =>
              const DailyReadingEditScreen(),
          AppRoutes.dailyReadingShow: (context) =>
              const DailyReadingShowScreen(),
        },
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isLoggedIn = await authProvider.checkAuthStatus();

    if (isLoggedIn) {
      // Load data before navigating to dashboard
      final billingCycleProvider =
          Provider.of<BillingCycleProvider>(context, listen: false);
      final dailyReadingProvider =
          Provider.of<DailyReadingProvider>(context, listen: false);

      await Future.wait([
        billingCycleProvider.fetchBillingCycles(),
        dailyReadingProvider.fetchDailyReadings(),
        dailyReadingProvider.fetchDailyUnits(),
      ]);

      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
      }
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.electric_meter,
                size: 60,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 30),

            // App Name
            const Text(
              'Utility Bill Logger',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),

            // App Description
            const Text(
              'Track your utility consumption daily',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 50),

            // Loading Indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
