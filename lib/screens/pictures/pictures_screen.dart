
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'picture_fullscreen_screen.dart';

class PicturesScreen extends StatelessWidget {
  final int edenId;

  const PicturesScreen({super.key, required this.edenId});

  @override
  Widget build(BuildContext context) {
    // Generating a list of 10 placeholder image paths
    final List<String> imagePaths = List.generate(10, (i) => 'assets/images/eden$edenId/pic${i + 1}.jpg');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pictures'),
      ),
      body: MasonryGridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        itemCount: imagePaths.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PictureFullscreenScreen(
                    imagePath: imagePaths[index],
                  ),
                ),
              );
            },
            child: Image.asset(
              imagePaths[index],
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(
                      Icons.image_not_supported,
                      color: Colors.grey,
                      size: 40.0,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
