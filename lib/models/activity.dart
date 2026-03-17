import 'dart:io';
import 'package:path_provider/path_provider.dart';

class Activity {
  final int id;
  final String arName;
  final String enName;
  final String fileUrl;
  final String logoUrl;
  final String fileType;

  const Activity({
    required this.id,
    required this.arName,
    required this.enName,
    required this.fileUrl,
    required this.logoUrl,
    required this.fileType,
  });

  /// Returns a unique local file name for the ZIP
  String get fileName => 'activity_${id}_${fileUrl.split('/').last}';

  /// Returns the directory where the ZIP should be extracted
  Future<String> get extractedPath async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/books/book_$id';
  }

  /// Returns the path to the internal index.html
  Future<String> get localIndexPath async {
    final path = await extractedPath;
    return '$path/index.html';
  }

  /// Returns the localhost URL for the offline book
  Future<String> get localServerUrl async {
    return 'http://localhost:8080/books/book_$id/index.html';
  }

  /// Checks if the book is downloaded and extracted (verified by index.html)
  Future<bool> get isDownloaded async {
    final path = await localIndexPath;
    return File(path).exists();
  }
}
