import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import '../../providers/auth_provider.dart';
import '../../providers/billing_cycle_provider.dart';
import '../../providers/daily_reading_provider.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account'), elevation: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: FormBuilder(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),

                // App Logo
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.electric_meter,
                    size: 40,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 24),

                // Welcome Text
                Text(
                  'Join Utility Bill Logger',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                Text(
                  'Create your account to start tracking utility consumption',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // Name Field
                FormBuilderTextField(
                  name: 'name',
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    hintText: 'Enter your full name',
                    prefixIcon: Icon(Icons.person_outlined),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(
                      errorText: AppConstants.requiredField,
                    ),
                    FormBuilderValidators.minLength(
                      2,
                      errorText: 'Name must be at least 2 characters',
                    ),
                  ]),
                ),

                const SizedBox(height: 20),

                // Email Field
                FormBuilderTextField(
                  name: 'email',
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    hintText: 'Enter your email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(
                      errorText: AppConstants.requiredField,
                    ),
                    FormBuilderValidators.email(
                      errorText: AppConstants.invalidEmail,
                    ),
                  ]),
                ),

                const SizedBox(height: 20),

                // Password Field
                FormBuilderTextField(
                  name: 'password',
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Create a password',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  obscureText: !_isPasswordVisible,
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(
                      errorText: AppConstants.requiredField,
                    ),
                    FormBuilderValidators.minLength(
                      8,
                      errorText: AppConstants.passwordTooShort,
                    ),
                  ]),
                ),

                const SizedBox(height: 20),

                // Confirm Password Field
                FormBuilderTextField(
                  name: 'password_confirmation',
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    hintText: 'Confirm your password',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                  ),
                  obscureText: !_isConfirmPasswordVisible,
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(
                      errorText: AppConstants.requiredField,
                    ),
                    (value) {
                      final password =
                          _formKey.currentState?.fields['password']?.value;
                      if (value != password) {
                        return AppConstants.passwordsDoNotMatch;
                      }
                      return null;
                    },
                  ]),
                ),

                const SizedBox(height: 32),

                // Register Button
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return ElevatedButton(
                      onPressed:
                          authProvider.isLoading ? null : _handleRegister,
                      child: authProvider.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text('Create Account'),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // Error Message
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    if (authProvider.error != null) {
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.errorColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.errorColor.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: AppTheme.errorColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                authProvider.error!,
                                style: TextStyle(
                                  color: AppTheme.errorColor,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),

                const SizedBox(height: 24),

                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      child: const Text('Sign In'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleRegister() async {
    final formState = _formKey.currentState;
    if (formState == null || !formState.saveAndValidate()) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    final name = formState.value['name'] as String;
    final email = formState.value['email'] as String;
    final password = formState.value['password'] as String;
    final passwordConfirmation =
        formState.value['password_confirmation'] as String;
    final success = await authProvider.register(
        name, email, password, passwordConfirmation);
    if (context.mounted) Navigator.pop(context); // Close loading dialog
    if (success) {
      if (context.mounted) {
        // Fetch data before navigating
        final billingCycleProvider =
            Provider.of<BillingCycleProvider>(context, listen: false);
        final dailyReadingProvider =
            Provider.of<DailyReadingProvider>(context, listen: false);
        await Future.wait([
          billingCycleProvider.fetchBillingCycles(),
          dailyReadingProvider.fetchDailyReadings(),
        ]);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'Registration successful!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
              top: kToolbarHeight + MediaQuery.of(context).padding.top + 8,
              left: 20,
              right: 20,
              bottom: 16,
            ),
          ),
        );
        Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
      }
    } else if (authProvider.error != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error!),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            top: kToolbarHeight + MediaQuery.of(context).padding.top + 8,
            left: 20,
            right: 20,
            bottom: 16,
          ),
        ),
      );
    }
  }
}
