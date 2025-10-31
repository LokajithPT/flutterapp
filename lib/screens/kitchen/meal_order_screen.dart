
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/eden_data_provider.dart';

class MealOrderScreen extends StatelessWidget {
  final String mealType;

  const MealOrderScreen({super.key, required this.mealType});

  void _showAddItemDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add $mealType Item'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Item Name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  Provider.of<EdenDataProvider>(context, listen: false)
                      .addKitchenItem(mealType, controller.text);
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(mealType),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () {
              Provider.of<EdenDataProvider>(context, listen: false)
                  .clearKitchenMeal(mealType);
            },
            tooltip: 'Clear All',
          ),
        ],
      ),
      body: Consumer<EdenDataProvider>(
        builder: (context, provider, child) {
          if (provider.edenData == null) {
            return const Center(child: CircularProgressIndicator());
          }

          List<String> items;
          switch (mealType) {
            case 'Breakfast':
              items = provider.edenData!.kitchen.breakfast;
              break;
            case 'Lunch':
              items = provider.edenData!.kitchen.lunch;
              break;
            case 'Dinner':
              items = provider.edenData!.kitchen.dinner;
              break;
            default:
              items = [];
          }

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(items[index]),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddItemDialog(context),
        child: const Icon(Icons.add),
        tooltip: 'Add Item',
      ),
    );
  }
}
