import 'package:event/components/custom_textfield.dart';
import 'package:event/components/custom_elevated_button.dart';
import 'package:event/models/user_model.dart';
import 'package:event/provider/settings_provider.dart';
import 'package:event/provider/user_provider.dart';
import 'package:event/services/firebase_service.dart';
import 'package:event/shared/app_theme.dart';
import 'package:event/shared/utilis.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UpdateNameSheet extends StatefulWidget {
  const UpdateNameSheet({super.key});

  @override
  State<UpdateNameSheet> createState() => _UpdateNameSheetState();
}

class _UpdateNameSheetState extends State<UpdateNameSheet> {
  final GlobalKey<FormState> globalKey = GlobalKey<FormState>();
  late final TextEditingController nameController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    final currentName = context.read<UserProvider>().currentUser?.name ?? '';
    nameController = TextEditingController(text: currentName);
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!globalKey.currentState!.validate()) return;
    setState(() => isLoading = true);
    try {
      final UserModel updated = await FirebaseService.updateProfileName(
        name: nameController.text.trim(),
      );
      // update provider’s in-memory user
      Provider.of<UserProvider>(
        context,
        listen: false,
      ).updateCurrentUser(updated);

      if (mounted) {
        Utils.showSuccessMessage('Name updated successfully');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) Utils.showErrorMessage(e.toString());
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<SettingsProvider>().isDark;

    return Form(
      key: globalKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomTextFormField(
            controller: nameController,
            hintText: 'Enter new name',
            iconPathName: 'profile',
            validator: (value) {
              if (value == null || value.trim().isEmpty) return 'Name required';
              if (value.trim().length < 3) {
                return 'Name must be at least 3 chars';
              }
              return null;
            },
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: CustomElevatedButton(
              color: isDark
                  ? AppTheme.primary.withValues(alpha: .5)
                  : AppTheme.primary,
              textElevatedButton: 'Save',
              isLoading: isLoading,
              onPressed: _save,
            ),
          ),
        ],
      ),
    );
  }
}
