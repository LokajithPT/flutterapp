
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'room_fullscreen_screen.dart';

class RoomsScreen extends StatefulWidget {
  final int edenId;

  const RoomsScreen({super.key, required this.edenId});

  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
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
    // Load existing images from storage if needed
    // For now, we'll start with empty list
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
      setState(() {
        _images.add(File(image.path));
      });
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

    final List<XFile> filesToShare = _selectedImages
        .map((index) => XFile(_images[index].path))
        .toList();

    try {
      await Share.shareXFiles(filesToShare, text: 'Shared from ${_getEdenName(widget.edenId)}');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing: $e')),
        );
      }
    }
  }

  void _deleteSelectedImages() {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isSelectionMode ? '${_selectedImages.length} Selected' : _getEdenName(widget.edenId)),
        actions: [
          if (_isSelectionMode) ...[
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _shareSelectedImages,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteSelectedImages,
            ),
            IconButton(
              icon: const Icon(Icons.close),
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
      body: _images.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.photo_library_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No pictures yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button to add pictures',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
          : MasonryGridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              itemCount: _images.length,
              itemBuilder: (context, index) {
                final bool isSelected = _selectedImages.contains(index);
                return GestureDetector(
                  onTap: () {
                    if (_isSelectionMode) {
                      _toggleSelection(index);
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RoomFullscreenScreen(
                            imagePath: _images[index].path,
                            isFile: true,
                          ),
                        ),
                      );
                    }
                  },
                  onLongPress: () {
                    _toggleSelection(index);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected
                          ? Border.all(color: Colors.blue, width: 3)
                          : null,
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _images[index],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
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
                                color: Colors.blue,
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
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImage,
        child: const Icon(Icons.add),
        tooltip: 'Add Picture',
      ),
    );
  }

  String _getEdenName(int edenId) {
    switch (edenId) {
      case 1:
        return 'EDEN 1';
      case 2:
        return 'EDEN 2';
      case 3:
        return 'EDEN 3';
      case 4:
        return 'EDEN 4';
      case 6:
        return 'EDEN 6';
      case 7:
        return 'EDEN 7';
      case 8:
        return 'Kunnur';
      case 9:
        return 'Kodanadu';
      case 10:
        return 'Others';
      default:
        return 'EDEN $edenId';
    }
  }
}
