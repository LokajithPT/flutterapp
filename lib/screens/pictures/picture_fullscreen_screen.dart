import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class PictureFullscreenScreen extends StatefulWidget {
  final String imagePath;

  const PictureFullscreenScreen({super.key, required this.imagePath});

  @override
  State<PictureFullscreenScreen> createState() => _PictureFullscreenScreenState();
}

class _PictureFullscreenScreenState extends State<PictureFullscreenScreen> {
  bool _isPlaceholder = false;

  Future<void> _shareImage() async {
    if (_isPlaceholder) return; // Don't share placeholders

    try {
      final byteData = await rootBundle.load(widget.imagePath);
      final file = File('${(await getTemporaryDirectory()).path}/${widget.imagePath.split('/').last}');
      await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
      await Share.shareXFiles([XFile(file.path)]);
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: InteractiveViewer(
              child: Center(
                child: Image.asset(
                  widget.imagePath,
                  errorBuilder: (context, error, stackTrace) {
                    // Since this builder is called in a `build` method,
                    // we need to schedule a state update, not call it directly.
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        setState(() {
                          _isPlaceholder = true;
                        });
                      }
                    });
                    return Container(
                      color: Colors.grey[800],
                      child: const Center(
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                          size: 80.0,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back'),
                ),
                ElevatedButton.icon(
                  // Disable button if it's a placeholder
                  onPressed: _isPlaceholder ? null : _shareImage,
                  icon: const Icon(Icons.share),
                  label: const Text('Share'),
                  style: _isPlaceholder
                      ? ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.grey),
                        )
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}