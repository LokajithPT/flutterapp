
import 'package:flutter/material.dart';
import 'meal_order_screen.dart';

class KitchenScreen extends StatelessWidget {
  const KitchenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kitchen Orders'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MealOrderScreen(mealType: 'Breakfast')),
                );
              },
              child: const Text('Breakfast'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MealOrderScreen(mealType: 'Lunch')),
                );
              },
              child: const Text('Lunch'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MealOrderScreen(mealType: 'Dinner')),
                );
              },
              child: const Text('Dinner'),
            ),
          ],
        ),
      ),
    );
  }
}
