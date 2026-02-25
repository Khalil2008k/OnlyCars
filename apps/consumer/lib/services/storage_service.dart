import 'dart:typed_data';
import 'package:flutter/widgets.dart';
import 'package:oc_api/oc_api.dart';

/// Storage upload service for OnlyCars
/// Handles file uploads to 7 Supabase Storage buckets:
///   1. avatars          — user profile photos
///   2. vehicle-photos   — vehicle images
///   3. part-images      — parts catalog images
///   4. diagnosis-photos — workshop diagnosis photos
///   5. bill-photos      — before/after work photos
///   6. documents        — provider registration docs (CR, ID, license)
///   7. chat-media       — chat attachments (images, files)
class StorageService {
  static const _buckets = {
    'avatars': 'avatars',
    'vehicles': 'vehicle-photos',
    'parts': 'part-images',
    'diagnosis': 'diagnosis-photos',
    'bills': 'bill-photos',
    'documents': 'documents',
    'chat': 'chat-media',
  };

  /// Upload a file to the specified bucket
  /// Returns the public URL of the uploaded file
  static Future<String?> upload({
    required String bucket,
    required String fileName,
    required Uint8List fileBytes,
    String? contentType,
  }) async {
    try {
      final bucketName = _buckets[bucket] ?? bucket;
      final userId = OcSupabase.client.auth.currentUser?.id ?? 'anonymous';
      final path = '$userId/$fileName';

      await OcSupabase.client.storage.from(bucketName).uploadBinary(
        path,
        fileBytes,
        fileOptions: FileOptions(
          contentType: contentType ?? 'image/jpeg',
          upsert: true,
        ),
      );

      final url = OcSupabase.client.storage.from(bucketName).getPublicUrl(path);
      debugPrint('[Storage] Uploaded to $bucketName/$path → $url');
      return url;
    } catch (e) {
      debugPrint('[Storage] Upload error: $e');
      return null;
    }
  }

  /// Upload avatar photo
  static Future<String?> uploadAvatar(Uint8List bytes) async {
    final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
    return upload(bucket: 'avatars', fileName: fileName, fileBytes: bytes);
  }

  /// Upload vehicle photo
  static Future<String?> uploadVehiclePhoto(String vehicleId, Uint8List bytes) async {
    final fileName = '${vehicleId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    return upload(bucket: 'vehicles', fileName: fileName, fileBytes: bytes);
  }

  /// Upload part image (for shop catalog)
  static Future<String?> uploadPartImage(String partId, Uint8List bytes) async {
    final fileName = '${partId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    return upload(bucket: 'parts', fileName: fileName, fileBytes: bytes);
  }

  /// Upload diagnosis photo
  static Future<String?> uploadDiagnosisPhoto(String diagnosisId, Uint8List bytes) async {
    final fileName = '${diagnosisId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    return upload(bucket: 'diagnosis', fileName: fileName, fileBytes: bytes);
  }

  /// Upload bill photo (before/after)
  static Future<String?> uploadBillPhoto(String billId, String type, Uint8List bytes) async {
    final fileName = '${billId}_${type}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    return upload(bucket: 'bills', fileName: fileName, fileBytes: bytes);
  }

  /// Upload provider document (CR, license, ID)
  static Future<String?> uploadDocument(String docType, Uint8List bytes) async {
    final fileName = '${docType}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    return upload(bucket: 'documents', fileName: fileName, fileBytes: bytes, contentType: 'application/pdf');
  }

  /// Upload chat attachment
  static Future<String?> uploadChatMedia(String roomId, Uint8List bytes, {String? type}) async {
    final ext = type == 'pdf' ? 'pdf' : 'jpg';
    final ct = type == 'pdf' ? 'application/pdf' : 'image/jpeg';
    final fileName = '${roomId}_${DateTime.now().millisecondsSinceEpoch}.$ext';
    return upload(bucket: 'chat', fileName: fileName, fileBytes: bytes, contentType: ct);
  }

  /// Delete a file from a bucket
  static Future<bool> delete(String bucket, String path) async {
    try {
      final bucketName = _buckets[bucket] ?? bucket;
      await OcSupabase.client.storage.from(bucketName).remove([path]);
      return true;
    } catch (e) {
      debugPrint('[Storage] Delete error: $e');
      return false;
    }
  }

  /// List files in a user's folder within a bucket
  static Future<List<FileObject>> listFiles(String bucket, {String? subfolder}) async {
    try {
      final bucketName = _buckets[bucket] ?? bucket;
      final userId = OcSupabase.client.auth.currentUser?.id ?? 'anonymous';
      final path = subfolder != null ? '$userId/$subfolder' : userId;
      return await OcSupabase.client.storage.from(bucketName).list(path: path);
    } catch (e) {
      debugPrint('[Storage] List error: $e');
      return [];
    }
  }
}
