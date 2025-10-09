import 'package:event/components/custom_elevated_button.dart';
import 'package:event/components/custom_textfield.dart';
import 'package:event/provider/settings_provider.dart';
import 'package:event/services/firebase_service.dart';
import 'package:event/shared/app_theme.dart';
import 'package:event/shared/utilis.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

class ResetPasswordSheet extends StatefulWidget {
  const ResetPasswordSheet({super.key});

  @override
  State<ResetPasswordSheet> createState() => _ResetPasswordSheetState();
}

class _ResetPasswordSheetState extends State<ResetPasswordSheet> {
  GlobalKey<FormState> globalKey = GlobalKey<FormState>();
  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmNewPasswordController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmNewPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Provider.of<SettingsProvider>(context).isDark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Form(
        key: globalKey,
        child: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 16),

                CustomTextFormField(
                  controller: oldPasswordController,
                  isPassword: true,
                  hintText: 'Old password',
                  iconPathName: 'password',
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Enter password';
                    } else if (value.length < 9) {
                      return 'Password must be at least 9 characters';
                    } else if (!RegExp(r'^(?=.*[a-z])').hasMatch(value)) {
                      return 'Password must contain lowercase letter';
                    } else if (!RegExp(r'^(?=.*[A-Z])').hasMatch(value)) {
                      return 'Password must contain uppercase letter';
                    } else if (!RegExp(r'^(?=.*[0-9])').hasMatch(value)) {
                      return 'Password must contain number';
                    } else if (!RegExp(
                      r'^(?=.*[!@#$%^&*(),.?":{}|<>])',
                    ).hasMatch(value)) {
                      return 'Password must contain special character';
                    } else {
                      return null;
                    }
                  },
                  isDark: isDark,
                ),
                const SizedBox(height: 16),
                CustomTextFormField(
                  isPassword: true,
                  controller: newPasswordController,
                  hintText: 'New password',
                  iconPathName: 'password',
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Enter password';
                    } else if (value.length < 9) {
                      return 'Password must be at least 9 characters';
                    } else if (!RegExp(r'^(?=.*[a-z])').hasMatch(value)) {
                      return 'Password must contain lowercase letter';
                    } else if (!RegExp(r'^(?=.*[A-Z])').hasMatch(value)) {
                      return 'Password must contain uppercase letter';
                    } else if (!RegExp(r'^(?=.*[0-9])').hasMatch(value)) {
                      return 'Password must contain number';
                    } else if (!RegExp(
                      r'^(?=.*[!@#$%^&*(),.?":{}|<>])',
                    ).hasMatch(value)) {
                      return 'Password must contain special character';
                    } else {
                      return null;
                    }
                  },
                  isDark: isDark,
                ),

                const SizedBox(height: 16),
                CustomTextFormField(
                  isDark: isDark,
                  isPassword: true,
                  controller: confirmNewPasswordController,
                  hintText: 'Confirm new password',
                  iconPathName: 'password',
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Enter confirm password';
                    } else if (value != newPasswordController.text) {
                      return 'Passwords do not match';
                    } else {
                      return null;
                    }
                  },
                ),

                const SizedBox(height: 16),
                CustomElevatedButton(
                  color: isDark
                      ? AppTheme.primary.withValues(alpha: .5)
                      : AppTheme.primary,
                  textElevatedButton: 'Reset Password',
                  onPressed: resetPassword,
                  isLoading: isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> resetPassword() async {
    // optional guard: same old/new
    if (oldPasswordController.text.trim() ==
        newPasswordController.text.trim()) {
      Utils.showErrorMessage(
        'New password must be different from old password.',
      );
      return;
    }

    if (!globalKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    try {
      await FirebaseService.resetPassword(
        oldPassword: oldPasswordController.text.trim(),
        newPassword: newPasswordController.text.trim(),
      );

      if (!mounted) return;
      Utils.showSuccessMessage('Password updated successfully.');
      Navigator.of(context).pop(); // close bottom sheet
    } on FirebaseAuthException catch (e) {
      // friendlier messages
      String msg;
      switch (e.code) {
        case 'wrong-password':
          msg = 'Old password is incorrect.';
          break;
        case 'weak-password':
          msg = 'The new password is too weak.';
          break;
        case 'requires-recent-login':
          msg = 'Please sign in again and try updating your password.';
          break;
        case 'no-current-user':
          msg = 'No authenticated user. Please log in again.';
          break;
        default:
          msg = e.message ?? 'Failed to update password.';
      }
      if (mounted) Utils.showErrorMessage(msg);
    } catch (e) {
      if (mounted) Utils.showErrorMessage(e.toString());
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }
}
