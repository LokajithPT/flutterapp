import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class SiteSeeingScreen extends StatefulWidget {
  const SiteSeeingScreen({super.key});

  @override
  State<SiteSeeingScreen> createState() => _SiteSeeingScreenState();
}

class _SiteSeeingScreenState extends State<SiteSeeingScreen> {
  final ImagePicker _picker = ImagePicker();
  final List<File> _images = [];
  final Set<int> _selectedImages = {};
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    _loadExistingImages();
  }

  Future<void> _loadExistingImages() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${directory.path}/site_seeing_images');
      
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
      final imagesDir = Directory('${directory.path}/site_seeing_images');
      
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
        
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Image added! Total: ${_images.length}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving image: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _toggleSelection(int index) {
    setState(() {
      if (_selectedImages.contains(index)) {
        _selectedImages.remove(index);
      } else {
        _selectedImages.add(index);
      }
      _isSelectionMode = _selectedImages.isNotEmpty;
    });
  }

  void _shareSelectedImages() async {
    if (_selectedImages.isEmpty) return;

    final List<XFile> filesToShare = [];
    for (final index in _selectedImages) {
      if (index >= 0 && index < _images.length) {
        filesToShare.add(XFile(_images[index].path));
      }
    }

    if (filesToShare.isEmpty) return;

    try {
      await Share.shareXFiles(filesToShare, text: 'Beautiful places from EDEN Resorts!');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing: $e')),
        );
      }
    }
  }

  void _deleteSelectedImages() async {
    try {
      // Delete the actual files
      for (final index in _selectedImages) {
        if (index >= 0 && index < _images.length) {
          await _images[index].delete();
        }
      }
      
      setState(() {
        final List<File> remainingImages = [];
        for (int i = 0; i < _images.length; i++) {
          if (!_selectedImages.contains(i)) {
            remainingImages.add(_images[i]);
          }
        }
        _images.clear();
        _images.addAll(remainingImages);
        _selectedImages.clear();
        _isSelectionMode = false;
      });
    } catch (e) {
      print('Error deleting images: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Site Seeing',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_isSelectionMode) ...[
            IconButton(
              icon: const Icon(Icons.share, color: Colors.white),
              onPressed: _shareSelectedImages,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: _deleteSelectedImages,
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () {
                setState(() {
                  _selectedImages.clear();
                  _isSelectionMode = false;
                });
              },
            ),
          ],
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
                      child: Icon(
                        Icons.landscape,
                        size: 80,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No Site Seeing Photos Yet',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Capture beautiful moments and places',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: _images.length,
                itemBuilder: (context, index) {
                  print('Building image item at index: $index, total images: ${_images.length}');
                  if (index >= _images.length) {
                    print('Index out of bounds!');
                    return Container();
                  }
                  final bool isSelected = _selectedImages.contains(index);
                  return GestureDetector(
                    onTap: () {
                      if (_isSelectionMode) {
                        _toggleSelection(index);
                      } else {
                        _viewImage(index);
                      }
                    },
                    onLongPress: () {
                      _toggleSelection(index);
                    },
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected
                            ? Border.all(color: Colors.purple, width: 3)
                            : null,
                      ),
                      height: 300,
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _images[index],
                              fit: BoxFit.cover,
                              gaplessPlayback: true,
                              height: 200, // Add explicit height
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                print('Error loading image at index $index: $error');
                                return Container(
                                  height: 200,
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
                          ),
                          if (isSelected)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.purple,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 20,
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _pickImage,
        backgroundColor: Colors.purple[600],
        icon: const Icon(Icons.add_a_photo, color: Colors.white),
        label: const Text('Add Photo', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  void _viewImage(int index) {
    if (index < 0 || index >= _images.length) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _ImageViewerScreen(
          imagePath: _images[index].path,
          isFile: true,
        ),
      ),
    );
  }
}

class _ImageViewerScreen extends StatelessWidget {
  final String imagePath;
  final bool isFile;

  const _ImageViewerScreen({required this.imagePath, required this.isFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          child: isFile
              ? Image.file(
                  File(imagePath),
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image,
                            color: Colors.white,
                            size: 64,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Error loading image',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    );
                  },
                )
              : Image.asset(imagePath),
        ),
      ),
    );
  }
}