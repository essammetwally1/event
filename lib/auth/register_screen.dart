import 'dart:developer';

import 'package:event/shared/app_theme.dart';
import 'package:event/auth/login_screen.dart';
import 'package:event/components/custom_elevated_button.dart';
import 'package:event/components/custom_textfield.dart';
import 'package:event/firebase/firebase_service.dart';
import 'package:event/provider/settings_provider.dart';
import 'package:event/provider/user_provider.dart';
import 'package:event/shared/utilis.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  static const routeName = '/register';
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  GlobalKey<FormState> globalKey = GlobalKey<FormState>();
  late bool isDark;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    isDark = Provider.of<SettingsProvider>(context).isDark;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Register',
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
              mainAxisAlignment: MainAxisAlignment.center,
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
                  hintText: 'Name',
                  iconPathName: 'name',
                  controller: nameController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Enter Name';
                    } else if (value.length < 4) {
                      return 'Name must be 4 or more letters';
                    } else {
                      return null;
                    }
                  },
                ),
                SizedBox(height: 16),
                CustomTextFormField(
                  hintText: 'Mail',
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
                SizedBox(height: 16),
                CustomTextFormField(
                  hintText: 'Password',
                  iconPathName: 'password',
                  controller: passwordController,
                  isPassword: true,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Enter password';
                    } else if (value.length < 9) {
                      return 'Enter valid password -more than 9 letters-';
                    } else {
                      return null;
                    }
                  },
                ),
                SizedBox(height: 24),

                CustomElevatedButton(
                  isLoading: isLoading,
                  onPressed: register,
                  textElevatedButton: 'Create Account',
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already Have Account ?',
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
                      onPressed: () => Navigator.of(
                        context,
                      ).pushReplacementNamed(LoginScreen.routeName),
                      child: Text('Login'),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> register() async {
    if (globalKey.currentState!.validate()) {
      if (isLoading) return; // Prevent multiple clicks

      setState(() {
        isLoading = true;
      });

      try {
        final user = await FirebaseService.register(
          name: nameController.text.trim(),
          password: passwordController.text.trim(),
          email: emailController.text.trim(),
        );

        Provider.of<UserProvider>(
          context,
          listen: false,
        ).updateCurrentUser(user);

        Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
        Utils.showSuccessMessage('Register Success');
      } catch (error) {
        log('Registration error: $error');

        String errorMessage = 'Registration failed. Please try again.';

        if (error is FirebaseAuthException) {
          switch (error.code) {
            case 'email-already-in-use':
              errorMessage = 'This email is already registered.';
              break;
            case 'invalid-email':
              errorMessage = 'Please enter a valid email address.';
              break;
            case 'operation-not-allowed':
              errorMessage = 'Email/password accounts are not enabled.';
              break;
            case 'weak-password':
              errorMessage = 'Password is too weak.';
              break;
            default:
              errorMessage = error.message ?? 'Registration failed.';
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
