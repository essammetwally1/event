import 'dart:io';
import 'package:event/provider/settings_provider.dart';
import 'package:event/shared/utilis.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:provider/provider.dart';

import 'package:event/provider/user_provider.dart';
import 'package:event/shared/app_theme.dart';

class ImagePickerService {
  static final ImagePicker _picker = ImagePicker();

  /// Full flow: pick -> crop -> upload to Supabase -> update provider
  static Future<void> pickAndUploadAvatar(BuildContext context) async {
    final bool isDark = Provider.of<SettingsProvider>(
      context,
      listen: false,
    ).isDark;

    bool showProgress = false;

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final user = userProvider.currentUser;

      if (user == null) {
        _showToast(context, 'No user logged in');
        return;
      }

      final source = await _showSourceSelection(context, isDark);
      if (source == null) return;

      final XFile? pickedFile = await _pickImage(source);
      if (pickedFile == null) return;

      final File? croppedFile = await _cropImage(
        File(pickedFile.path),
        context,
      );
      if (croppedFile == null) return;

      showProgress = true;
      _showProgressDialog(context);

      await userProvider.updateUserProfileImage(croppedFile.path);
      _showToast(context, 'Profile image updated successfully!');
    } on PlatformException catch (e) {
      _showToast(context, 'Permission error: ${e.message}');
    } catch (e) {
      _showToast(context, 'Failed to update image');
    } finally {
      if (showProgress && context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    }
  }

  /// Alternative: Just pick and crop without upload (returns File)
  static Future<File?> pickAndCropImage(BuildContext context) async {
    final bool isDark = Provider.of<SettingsProvider>(
      context,
      listen: false,
    ).isDark;

    try {
      final source = await _showSourceSelection(context, isDark);
      if (source == null) return null;

      final XFile? pickedFile = await _pickImage(source);
      if (pickedFile == null) return null;

      return await _cropImage(File(pickedFile.path), context);
    } catch (e) {
      _showToast(context, 'Failed to pick image');
      return null;
    }
  }

  static Future<ImageSource?> _showSourceSelection(
    BuildContext context,
    bool isDark,
  ) {
    final TextTheme theme = Theme.of(context).textTheme;

    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: isDark
          ? AppTheme.backgroundDark
          : AppTheme.backgroundWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo_library, color: AppTheme.primary),
              title: Text('Choose from Gallery', style: theme.titleMedium),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: Icon(Icons.photo_camera, color: AppTheme.primary),
              title: Text('Take a Photo', style: theme.titleMedium),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: Icon(Icons.delete, color: AppTheme.red),
              title: Text(
                'Delete Profile Image',
                style: theme.titleMedium!.copyWith(color: AppTheme.red),
              ),
              onTap: () {
                Navigator.pop(context); // Close the bottom sheet first

                // Show confirmation dialog
                showDialog(
                  barrierColor: AppTheme.primary.withValues(alpha: 0.3),
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: AppTheme.backgroundWhite,
                    title: Text(
                      'Delete Profile Image',
                      style: theme.titleLarge!.copyWith(color: AppTheme.red),
                    ),
                    content: Text(
                      'Are you sure you want to delete your profile image?',
                      style: theme.titleMedium!.copyWith(color: AppTheme.black),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Cancel',
                          style: theme.titleMedium!.copyWith(
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(context); // Close confirmation dialog
                          try {
                            final userProvider = Provider.of<UserProvider>(
                              context,
                              listen: false,
                            );
                            await userProvider.deleteProfileImage();
                          } catch (e) {
                            Utils.showErrorMessage(
                              'Failed to delete image: ${e.toString()}',
                            );
                          }
                        },
                        child: Text(
                          'Delete',
                          style: theme.titleMedium!.copyWith(
                            color: AppTheme.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  static Future<XFile?> _pickImage(ImageSource source) async {
    try {
      return await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );
    } catch (e) {
      rethrow;
    }
  }

  static Future<File?> _cropImage(File imageFile, BuildContext context) async {
    final theme = Theme.of(context);

    try {
      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 90,
        maxWidth: 800,
        maxHeight: 800,
        uiSettings: [
          AndroidUiSettings(
            // Toolbar styling
            toolbarTitle: 'Crop Profile Image',
            toolbarColor: AppTheme.primary,
            toolbarWidgetColor: AppTheme.backgroundWhite,

            // Controls styling
            activeControlsWidgetColor: AppTheme.primary,

            // Layout and behavior
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
            hideBottomControls: false,
            showCropGrid: true,

            // Status bar
            statusBarLight: true,
            backgroundColor: theme.scaffoldBackgroundColor,

            // Button styling
            navBarLight: true,
            cropFrameColor: AppTheme.primary,
            cropGridColor: AppTheme.primary.withValues(alpha: 0.4),
            cropGridRowCount: 3,
            cropGridColumnCount: 3,
          ),
          IOSUiSettings(
            title: 'Crop Profile Image',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
            resetButtonHidden: false,
            doneButtonTitle: 'Done',
            cancelButtonTitle: 'Cancel',

            // iOS styling
            minimumAspectRatio: 1.0,
            showCancelConfirmationDialog: true,
          ),
        ],
      );

      return croppedFile != null ? File(croppedFile.path) : null;
    } catch (e) {
      return imageFile;
    }
  }

  static void _showProgressDialog(BuildContext context) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: theme.cardColor,
        content: Row(
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
            ),
            const SizedBox(width: 16),
            Text('Uploading image...', style: theme.textTheme.titleMedium),
          ],
        ),
      ),
    );
  }

  static void _showToast(BuildContext context, String message) {
    if (!context.mounted) return;

    final theme = Theme.of(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: theme.textTheme.titleMedium?.copyWith(
            color: AppTheme.backgroundWhite,
          ),
        ),
        backgroundColor: AppTheme.primary,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
