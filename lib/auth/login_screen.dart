import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event/app_theme.dart';
import 'package:event/auth/register_scree.dart';
import 'package:event/components/custom_elevated_button.dart';
import 'package:event/components/custom_textfield.dart';
import 'package:event/firebase/firebase_service.dart';
import 'package:event/provider/user_provider.dart';
import 'package:event/screens/home_screen.dart';
import 'package:event/utilis.dart';
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Form(
            key: globalKey,
            child: Column(
              children: [
                SizedBox(height: 50),
                Image.asset('assets/Logo.png'),
                SizedBox(height: 24),
                CustomTextFormField(
                  hintText: 'Mail',
                  iconPathName: 'mail',
                  controller: emailController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Enter Email';
                    } else if (!value.contains('@gmail.com')) {
                      return 'Enter Valid Email';
                    } else {
                      return null;
                    }
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
                  onPressed: login,
                  textElevatedButton: 'Login',
                ),
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
        ),
      ),
    );
  }

  void login() {
    if (globalKey.currentState!.validate()) {
      FirebaseService.logIn(
            email: emailController.text,
            password: passwordController.text,
          )
          .then((user) {
            Provider.of<UserProvider>(
              context,
              listen: false,
            ).updateCurrentUser(user);
            Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);

            Utils.showSuccessMessage('Login Success');
          })
          .catchError((error) {
            String? message;
            if (error is FirebaseException) {
              message = error.message;
            }
            Utils.showErrorMessage(message);
          });
    }
  }
}
