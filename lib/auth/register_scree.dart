import 'package:event/app_theme.dart';
import 'package:event/auth/login_screen.dart';
import 'package:event/components/custom_elevated_button.dart';
import 'package:event/components/custom_textfield.dart';
import 'package:event/firebase/firebase_service.dart';
import 'package:event/screens/home_screen.dart';
import 'package:flutter/material.dart';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Register',
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
              hintText: 'Name',
              iconPathName: 'name',
              controller: nameController,
            ),
            SizedBox(height: 16),
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

            CustomElevatedButton(
              onPressed: register,
              textElevatedButton: 'Create Account',
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already Have Account ?',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
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
          ],
        ),
      ),
    );
  }

  void register() {
    FirebaseService.register(
      name: nameController.text,
      password: passwordController.text,
      email: emailController.text,
    ).then((user) {
      Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
    });
  }
}
