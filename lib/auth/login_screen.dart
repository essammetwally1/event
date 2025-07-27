import 'package:event/components/custom_textfield.dart';
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomTextFormField(
            hintText: 'Mail',
            iconPathName: 'mail',
            controller: emailController,
          ),
          CustomTextFormField(
            hintText: 'Password',
            iconPathName: 'password',
            controller: passwordController,
          ),
        ],
      ),
    );
  }
}
