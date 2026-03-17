import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/activity.dart';
import '../services/file_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'reader_screen.dart';

class ActivityDetailScreen extends StatefulWidget {
  final Activity activity;

  const ActivityDetailScreen({super.key, required this.activity});

  @override
  State<ActivityDetailScreen> createState() => _ActivityDetailScreenState();
}

class _ActivityDetailScreenState extends State<ActivityDetailScreen> {
  final FileService _fileService = FileService();
  bool _isDownloaded = false;
  double _downloadProgress = 0;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final status = await widget.activity.isDownloaded;
    setState(() {
      _isDownloaded = status;
    });
  }

  Future<void> _download() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'تحقق من اتصالك بالإنترنت لتبدأ تحميل الكتاب',
              textAlign: TextAlign.right,
            ),
          ),
        );
      }
      return;
    }

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0;
    });

    try {
      // 1. Download ZIP
      final zipPath = await _fileService.downloadFile(
        url: widget.activity.fileUrl,
        fileName: widget.activity.fileName,
        onProgress: (progress) {
          setState(() => _downloadProgress = progress);
        },
      );

      // 2. Extract ZIP
      final extractPath = await widget.activity.extractedPath;
      await _fileService.extractZip(zipPath, extractPath);

      // 3. Delete ZIP to save space
      await _fileService.deleteFile(zipPath);

      await _checkStatus();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم التحميل الكتاب بنجاح',textAlign: TextAlign.right,)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل العملية: $e',textAlign: TextAlign.right,)),
        );
      }
    } finally {
      setState(() => _isDownloading = false);
    }
  }

  Future<void> _delete() async {
    try {
      final path = await widget.activity.extractedPath;
      await _fileService.deleteDirectory(path);
      await _checkStatus();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حذف الملفات',textAlign: TextAlign.right,)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل الحذف: $e',textAlign: TextAlign.right,)),
        );
      }
    }
  }


  Future<void> _openOffline() async {
    final serverUrl = await widget.activity.localServerUrl;
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReaderScreen(
            title: widget.activity.arName,
            localServerUrl: serverUrl,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.activity.arName),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Hero(
              tag: 'logo_${widget.activity.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  widget.activity.logoUrl,
                  height: 200,
                  width: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.book, size: 100, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              widget.activity.arName,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              widget.activity.enName,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 48),
            if (_isDownloading) ...[
              LinearProgressIndicator(value: _downloadProgress,minHeight: 15,borderRadius: BorderRadius.circular(15),),
              const SizedBox(height: 8),
              Text('${(_downloadProgress * 100).toStringAsFixed(0)}%'),
              const SizedBox(height: 24),
            ],
            _buildActionButton(
              icon: Icons.download,
              label: 'تحميل الكتاب',
              onPressed: _isDownloading ? null : _download,
              color: Colors.blue,
              isVisible: !_isDownloaded,
            ),
            _buildActionButton(
              icon: Icons.menu_book,
              label: 'قراءة الكتاب بدون إنترنت',
              onPressed: _isDownloaded ? _openOffline : null,
              color: CupertinoColors.systemIndigo,
              isVisible: _isDownloaded,
            ),
            // const SizedBox(height: 16),
            // _buildActionButton(
            //   icon: Icons.remove_red_eye,
            //   label: 'معاينة أونلاين',
            //   onPressed: _openOnline,
            //   color: Colors.orange,
            //   isVisible: true,
            // ),
            const SizedBox(height: 16),
            _buildActionButton(
              icon: Icons.delete,
              label: 'حذف الكتاب',
              onPressed: _isDownloaded ? _delete : null,
              color: CupertinoColors.label,
              isVisible: _isDownloaded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    required Color color,
    required bool isVisible,
  }) {
    if (!isVisible) return const SizedBox.shrink();

    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          disabledBackgroundColor: Colors.grey[300],
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
