import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class SimpleImagesScreen extends StatefulWidget {
  const SimpleImagesScreen({super.key});

  @override
  State<SimpleImagesScreen> createState() => _SimpleImagesScreenState();
}

class _SimpleImagesScreenState extends State<SimpleImagesScreen> {
  final ImagePicker _picker = ImagePicker();
  final List<File> _images = [];

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${directory.path}/simple_images');
      
      if (await imagesDir.exists()) {
        final files = await imagesDir.list().where((entity) => 
          entity is File && 
          (entity.path.endsWith('.jpg') || entity.path.endsWith('.png') || entity.path.endsWith('.jpeg'))
        ).cast<File>().toList();
        
        files.sort((a, b) => a.path.compareTo(b.path));
        
        if (mounted) {
          setState(() {
            _images.clear();
            _images.addAll(files);
          });
        }
      }
    } catch (e) {
      print('Error loading images: $e');
    }
  }

  Future<File> _saveImageToAppDirectory(File sourceFile) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${directory.path}/simple_images');
      
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }
      
      final fileName = '${DateTime.now().millisecondsSinceEpoch}${path.extension(sourceFile.path)}';
      final savedFile = await sourceFile.copy('${imagesDir.path}/$fileName');
      
      return savedFile;
    } catch (e) {
      print('Error saving image: $e');
      rethrow;
    }
  }

  Future<void> _requestPermissions() async {
    await Permission.camera.request();
    await Permission.photos.request();
    await Permission.storage.request();
  }

  Future<void> _pickImage() async {
    await _requestPermissions();
    
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );

    if (image != null) {
      try {
        final savedFile = await _saveImageToAppDirectory(File(image.path));
        setState(() {
          _images.add(savedFile);
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving image: $e')),
          );
        }
      }
    }
  }

  void _shareImages() async {
    if (_images.isEmpty) return;

    final List<XFile> filesToShare = _images
        .map((file) => XFile(file.path))
        .toList();

    try {
      await Share.shareXFiles(filesToShare, text: 'Shared from Elox!');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing: $e')),
        );
      }
    }
  }

  Future<void> _deleteImage(int index) async {
    try {
      final fileToDelete = _images[index];
      await fileToDelete.delete();
      
      setState(() {
        _images.removeAt(index);
      });
    } catch (e) {
      print('Error deleting image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Images'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_images.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.share, color: Colors.white),
              onPressed: _shareImages,
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              Color(0xFF1a1a1a),
              Colors.black,
            ],
          ),
        ),
        child: _images.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.photo_library,
                        size: 80,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'No Images Yet',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap + to add images',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              )
            : MasonryGridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                itemCount: _images.length,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        children: [
                          Image.file(
                            _images[index],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[800],
                                child: const Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    color: Colors.grey,
                                    size: 40.0,
                                  ),
                                ),
                              );
                            },
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () => _deleteImage(index),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImage,
        backgroundColor: Colors.purple[600],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}