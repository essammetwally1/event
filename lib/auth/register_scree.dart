import 'package:event/app_theme.dart';
import 'package:event/auth/login_screen.dart';
import 'package:event/components/custom_elevated_button.dart';
import 'package:event/components/custom_textfield.dart';
import 'package:event/firebase/firebase_service.dart';
import 'package:event/models/user_model.dart';
import 'package:event/provider/user_provider.dart';
import 'package:event/screens/home_screen.dart';
import 'package:event/utilis.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Register',
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/Logo.png'),
                SizedBox(height: 24),
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
        ),
      ),
    );
  }

  void register() {
    if (globalKey.currentState!.validate()) {
      FirebaseService.register(
            name: nameController.text,
            password: passwordController.text,
            email: emailController.text,
          )
          .then((user) {
            Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
            Provider.of<UserProvider>(context).updateCurrentUder(user);
            Utils.showSuccessMessage('Register Succes');
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
