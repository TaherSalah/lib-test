import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../services/local_server_service.dart';

class ReaderScreen extends StatefulWidget {
  final String title;
  final String? url;
  final String? localServerUrl;

  const ReaderScreen({
    super.key,
    required this.title,
    this.url,
    this.localServerUrl,
  }) : assert(url != null || localServerUrl != null, 'Either url or localServerUrl must be provided');

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  final LocalServerService _serverService = LocalServerService();

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView Error: ${error.description}');
          },
        ),
      );

    _initContent();
  }

  Future<void> _initContent() async {
    if (widget.localServerUrl != null) {
      // Start server if it's not running
      if (!_serverService.isRunning) {
        await _serverService.start();
      }
      _controller.loadRequest(Uri.parse(widget.localServerUrl!));
    } else if (widget.url != null) {
      _controller.loadRequest(Uri.parse(widget.url!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
