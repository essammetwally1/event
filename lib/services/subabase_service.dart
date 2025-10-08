import 'dart:io';
import 'package:event/shared/utilis.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const String bucket = 'avatars';

  static SupabaseClient get _client => Supabase.instance.client;

  /// Deterministic public URL for a user's avatar.
  static String publicUrl(String uid, {String? version}) {
    final base = _client.storage.from(bucket).getPublicUrl('$uid/profile.jpg');
    return version == null ? base : '$base?v=$version';
  }

  /// Upload/overwrite the single avatar file and return a cache-busted public URL.
  static Future<String?> upload({
    required String uid,
    required File file,
  }) async {
    try {
      final path = '$uid/profile.jpg';

      await _client.storage
          .from(bucket)
          .upload(
            path,
            file,
            fileOptions: const FileOptions(
              upsert: true,
              contentType: 'image/jpeg',
              cacheControl: '3600',
            ),
          );

      // Return a URL that forces refresh in the UI
      return publicUrl(
        uid,
        version: DateTime.now().millisecondsSinceEpoch.toString(),
      );
    } catch (e) {
      Utils.showErrorMessage('Failed to upload image');
      return null;
    }
  }

  /// Delete user's avatar from Supabase storage
  static Future<bool> delete(String uid) async {
    try {
      await _client.storage.from(bucket).remove(['$uid/profile.jpg']);
      Utils.showSuccessMessage('Profile image removed');
      return true;
    } catch (e) {
      Utils.showErrorMessage('Failed to remove image');
      return false;
    }
  }

  static Future<bool> exists(String uid) async {
    try {
      final files = await _client.storage.from(bucket).list(path: uid);
      return files.any((f) => f.name == 'profile.jpg');
    } catch (e) {
      return false;
    }
  }

  /// Check if bucket exists and is accessible
  static Future<bool> checkBucketAccess() async {
    try {
      await _client.storage.from(bucket).list();
      return true;
    } catch (e) {
      Utils.showErrorMessage('Storage service unavailable');
      return false;
    }
  }
}
