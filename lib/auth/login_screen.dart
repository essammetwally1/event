import 'package:event/app_theme.dart';
import 'package:event/auth/register_scree.dart';
import 'package:event/components/custom_elevated_button.dart';
import 'package:event/components/custom_textfield.dart';
import 'package:event/firebase/firebase_service.dart';
import 'package:event/screens/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/Logo.png'),
            SizedBox(height: 24),
            CustomTextFormField(
              hintText: 'Mail',
              iconPathName: 'mail',
              controller: emailController,
            ),
            SizedBox(height: 16),
            CustomTextFormField(
              hintText: 'Password',
              iconPathName: 'password',
              controller: passwordController,
            ),
            SizedBox(height: 24),

            CustomElevatedButton(onPressed: login, textElevatedButton: 'Login'),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Don’t Have Account ?',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: AppTheme.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(
                    context,
                  ).pushReplacementNamed(RegisterScreen.routeName),
                  child: Text('Create Account'),
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
    );
  }

  void login() {
    FirebaseService.logIn(
      email: emailController.text,
      password: passwordController.text,
    ).then((user) {
      Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
    });
  }
}
