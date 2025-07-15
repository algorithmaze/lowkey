
import 'dart:typed_data';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

class FileService {
  final SupabaseClient _supabaseClient;

  FileService(this._supabaseClient);

  Future<String> uploadFile(File file, String bucketName, String path) async {
    await _supabaseClient.storage.from(bucketName).upload(
          path,
          file,
          fileOptions: const FileOptions(upsert: true),
        );
    return _supabaseClient.storage.from(bucketName).getPublicUrl(path);
  }

  Future<Uint8List> downloadFile(String fileUrl) async {
    final uri = Uri.parse(fileUrl);
    final path = uri.pathSegments.skip(1).join('/'); // Remove bucket name
    final bucketName = uri.pathSegments.first;

    final data = await _supabaseClient.storage.from(bucketName).download(path);
    return data;
  }

  Future<void> deleteFile(String fileUrl) async {
    final uri = Uri.parse(fileUrl);
    final path = uri.pathSegments.skip(1).join('/'); // Remove bucket name
    final bucketName = uri.pathSegments.first;
    await _supabaseClient.storage.from(bucketName).remove([path]);
  }
}
