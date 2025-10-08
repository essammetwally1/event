import 'package:event/auth/register_screen.dart';
import 'package:event/components/custom_elevated_button.dart';
import 'package:event/components/custom_textfield.dart';
import 'package:event/services/firebase_service.dart';
import 'package:event/provider/settings_provider.dart';
import 'package:event/provider/user_provider.dart';
import 'package:event/screens/home_screen.dart';
import 'package:event/shared/app_theme.dart';
import 'package:event/services/user_storage_service.dart';
import 'package:event/shared/utilis.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  GlobalKey<FormState> globalKey = GlobalKey<FormState>();
  late bool isDark;
  bool isLoading = false;
  bool isGoogleLoading = false;
  bool rememberMe = false;

  @override
  void initState() {
    super.initState();
    _checkRememberMeStatus();
  }

  Future<void> _checkRememberMeStatus() async {
    final isRememberMeEnabled = await UserStorageService.isRememberMeEnabled();
    setState(() {
      rememberMe = isRememberMeEnabled;
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    isDark = Provider.of<SettingsProvider>(context).isDark;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Login',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            color: AppTheme.primary,
            shadows: [
              Shadow(
                color: AppTheme.black.withValues(alpha: 0.5),
                blurRadius: 1,
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Form(
            key: globalKey,
            child: Column(
              children: [
                SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadiusGeometry.circular(28),
                  child: Image.asset(
                    'assets/logoimage.png',
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 50),

                CustomTextFormField(
                  hintText: 'Email',
                  iconPathName: 'mail',
                  controller: emailController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Enter Email';
                    } else if (!RegExp(
                      r'^[^@]+@[^@]+\.[^@]+',
                    ).hasMatch(value)) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextFormField(
                  hintText: 'Password',
                  iconPathName: 'password',
                  controller: passwordController,
                  isPassword: true,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Enter password';
                    } else if (value.length < 9) {
                      return 'Password should be -more than 9 letters-';
                    } else {
                      return null;
                    }
                  },
                ),

                // Add Remember Me checkbox here
                SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: rememberMe,
                      onChanged: (val) {
                        setState(() => rememberMe = val ?? false);
                      },
                      // fill color of the box (white when unchecked, still white when checked)
                      fillColor: WidgetStateProperty.resolveWith<Color>(
                        (states) => AppTheme.primary,
                      ),
                      // the tick/check color
                      checkColor: AppTheme.backgroundWhite,
                      // rounded corners
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          6,
                        ), // adjust roundness
                      ),
                      side: BorderSide(
                        color: AppTheme.primary, // outline color when unchecked
                        width: 2,
                        strokeAlign: 1,
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    Text(
                      "Remember me",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                CustomElevatedButton(
                  isLoading: isLoading,
                  onPressed: login,
                  textElevatedButton: 'Login',
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Don\'t Have Account?',
                      style: isDark
                          ? Theme.of(context).textTheme.titleMedium!.copyWith(
                              color: AppTheme.backgroundWhite,
                              fontWeight: FontWeight.w500,
                            )
                          : Theme.of(context).textTheme.titleMedium!.copyWith(
                              color: AppTheme.black,
                              fontWeight: FontWeight.w500,
                            ),
                    ),
                    TextButton(
                      onPressed: isLoading
                          ? null
                          : () => Navigator.of(
                              context,
                            ).pushReplacementNamed(RegisterScreen.routeName),
                      child: const Text('Create Account'),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        thickness: 1,
                        indent: 30,
                        color: AppTheme.primary,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        'or',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        thickness: 1,
                        endIndent: 30,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                CustomElevatedButton(
                  isGoogle: true,
                  isLoading: isGoogleLoading,
                  textElevatedButton: 'Continue With Google',
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> login() async {
    if (globalKey.currentState!.validate()) {
      if (isLoading) return;

      setState(() {
        isLoading = true;
      });

      try {
        final user = await FirebaseService.logIn(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        // Save user ID if Remember Me is checked
        await UserStorageService.saveUserCredentials(
          userId: user.id,
          rememberMe: rememberMe,
        );

        Provider.of<UserProvider>(
          context,
          listen: false,
        ).updateCurrentUser(user);

        Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
        Utils.showSuccessMessage('Login Success');
      } catch (error) {
        String errorMessage = 'Login failed. Please try again.';

        if (error is FirebaseAuthException) {
          switch (error.code) {
            case 'user-not-found':
              errorMessage = 'No user found with this email.';
              break;
            case 'wrong-password':
              errorMessage = 'Incorrect password. Please try again.';
              break;
            case 'invalid-email':
              errorMessage = 'Please enter a valid email address.';
              break;
            case 'user-disabled':
              errorMessage = 'This account has been disabled.';
              break;
            default:
              errorMessage = error.message ?? 'Login failed.';
          }
        } else if (error is FirebaseException) {
          errorMessage = error.message ?? 'Firebase error occurred.';
        }

        Utils.showErrorMessage(errorMessage);
      } finally {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    }
  }
}
