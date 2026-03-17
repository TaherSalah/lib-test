import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive.dart';

class FileService {
  final Dio _dio = Dio();

  /// Downloads a file from the given URL and saves it locally
  Future<String> downloadFile({
    required String url,
    required String fileName,
    required Function(double progress) onProgress,
  }) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final savePath = '${directory.path}/$fileName';

      await _dio.download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            onProgress(received / total);
          }
        },
      );
      return savePath;
    } catch (e) {
      throw Exception('Failed to download file: $e');
    }
  }

  /// Extracts a ZIP file to the target directory
  Future<void> extractZip(String zipPath, String targetDir) async {
    try {
      final bytes = await File(zipPath).readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      for (final file in archive) {
        final filename = file.name;
        if (file.isFile) {
          final data = file.content as List<int>;
          File('$targetDir/$filename')
            ..createSync(recursive: true)
            ..writeAsBytesSync(data);
        } else {
          Directory('$targetDir/$filename').create(recursive: true);
        }
      }
    } catch (e) {
      throw Exception('Failed to extract ZIP: $e');
    }
  }

  /// Deletes a local file
  Future<void> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }

  /// Deletes a directory
  Future<void> deleteDirectory(String dirPath) async {
    try {
      final directory = Directory(dirPath);
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
    } catch (e) {
      throw Exception('Failed to delete directory: $e');
    }
  }

  /// Checks if a file exists locally
  Future<bool> fileExists(String filePath) async {
    return File(filePath).exists();
  }
}
