
import 'package:flutter/material.dart';
import 'dates/dates_screen.dart';
import 'pictures/pictures_screen.dart';
import 'kitchen/kitchen_screen.dart';

class EdenHomeScreen extends StatelessWidget {
  final int edenId;

  const EdenHomeScreen({super.key, required this.edenId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('EDEN $edenId'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DatesScreen()),
                );
              },
              child: const Text('Dates'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PicturesScreen(edenId: edenId)),
                );
              },
              child: const Text('Pictures'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const KitchenScreen()),
                );
              },
              child: const Text('Kitchen'),
            ),
          ],
        ),
      ),
    );
  }
}
