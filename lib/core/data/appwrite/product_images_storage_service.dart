import 'dart:typed_data';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import 'package:admin/config/environment.dart';

import '../../../config/network/appwrite_client.dart';

class UploadedImageInfo {
  final String fileId;
  final String viewUrl;

  const UploadedImageInfo({
    required this.fileId,
    required this.viewUrl,
  });
}

class ProductImagesStorageService {
  Storage get _storage => AppwriteClient.instance.storage;

  Future<UploadedImageInfo> upload({required XFile file}) async {
    final inputFile = await _toInputFile(file);

    final models.File uploaded = await _storage.createFile(
      bucketId: Environment.BucketImages,
      fileId: ID.unique(),
      file: inputFile,
    );


    final String viewUrl =
        '${Environment.appwriteEndpoint}/storage/buckets/${Environment.BucketImages}/files/${uploaded.$id}/view?project=${Environment.appwriteProjectId}';

    return UploadedImageInfo(
      fileId: uploaded.$id,
      viewUrl: viewUrl,
    );
  }

  Future<void> deleteManyByViewUrls(List<String> urls) async {
    for (final u in urls) {
      final s = u.trim();
      if (s.isEmpty) continue;
      if (!s.startsWith('http')) continue;
      if (s.startsWith('Instance of')) continue;
      await deleteByViewUrl(s);
    }
  }

  Future<void> deleteByViewUrl(String viewUrl) async {
    final fileId = _extractFileIdFromViewUrl(viewUrl);
    if (fileId == null || fileId.isEmpty) return;

    try {
      await _storage.deleteFile(
        bucketId: Environment.BucketImages,
        fileId: fileId,
      );
    } catch (_) {
      // silent
    }
  }

  Future<InputFile> _toInputFile(XFile file) async {
    if (kIsWeb) {
      final Uint8List bytes = await file.readAsBytes();
      return InputFile.fromBytes(bytes: bytes, filename: file.name);
    }
    return InputFile.fromPath(path: file.path, filename: file.name);
  }

  String? _extractFileIdFromViewUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final seg = uri.pathSegments;
      final filesIndex = seg.indexOf('files');
      if (filesIndex == -1) return null;
      if (filesIndex + 1 >= seg.length) return null;
      return seg[filesIndex + 1];
    } catch (_) {
      return null;
    }
  }
}
