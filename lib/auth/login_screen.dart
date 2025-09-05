import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event/app_theme.dart';
import 'package:event/auth/register_scree.dart';
import 'package:event/components/custom_elevated_button.dart';
import 'package:event/components/custom_textfield.dart';
import 'package:event/firebase/firebase_service.dart';
import 'package:event/provider/settings_provider.dart';
import 'package:event/provider/user_provider.dart';
import 'package:event/screens/home_screen.dart';
import 'package:event/utilis.dart';
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
          style: Theme.of(
            context,
          ).textTheme.titleLarge!.copyWith(color: AppTheme.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Form(
            key: globalKey,
            child: Column(
              children: [
                const SizedBox(height: 50),
                Image.asset('assets/Logo.png'),
                const SizedBox(height: 24),
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
                    } else if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
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
