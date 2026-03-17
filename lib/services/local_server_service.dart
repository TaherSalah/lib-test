import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_static/shelf_static.dart';
import 'package:path_provider/path_provider.dart';

class LocalServerService {
  static final LocalServerService _instance = LocalServerService._internal();
  factory LocalServerService() => _instance;
  LocalServerService._internal();

  HttpServer? _server;

  /// Starts the local HTTP server to serve files from the app documents directory
  Future<void> start() async {
    if (_server != null) return;

    try {
      final directory = await getApplicationDocumentsDirectory();
      
      // Ensure the 'books' directory exists
      final booksDir = Directory('${directory.path}/books');
      if (!await booksDir.exists()) {
        await booksDir.create(recursive: true);
      }

      final handler = const Pipeline()
          .addMiddleware(logRequests())
          .addHandler(createStaticHandler(directory.path, defaultDocument: 'index.html'));

      _server = await io.serve(handler, InternetAddress.loopbackIPv4, 8080);
      debugPrint('Serving at http://${_server!.address.host}:${_server!.port}');
    } catch (e) {
      debugPrint('Error starting local server: $e');
    }
  }

  /// Stops the local HTTP server
  Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;
    debugPrint('Server stopped.');
  }

  bool get isRunning => _server != null;
}
