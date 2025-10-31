
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/eden_data_provider.dart';
import 'eden_home_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select EDEN Unit'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            int edenId = index + 1;
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  Provider.of<EdenDataProvider>(context, listen: false).loadData(edenId);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EdenHomeScreen(edenId: edenId),
                    ),
                  );
                },
                child: Text('EDEN $edenId'),
              ),
            );
          }),
        ),
      ),
    );
  }
}
