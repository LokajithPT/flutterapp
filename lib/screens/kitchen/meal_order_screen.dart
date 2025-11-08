import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/eden_data_provider.dart';
import '../../models/menu_model.dart';

class MealOrderScreen extends StatefulWidget {
  final String mealType;
  final DateTime selectedDate;
  final List<MenuItem> menuItems;
  final List<String> savedOrders;

  const MealOrderScreen({
    super.key,
    required this.mealType,
    required this.selectedDate,
    required this.menuItems,
    this.savedOrders = const [],
  });

  @override
  State<MealOrderScreen> createState() => _MealOrderScreenState();
}

class _MealOrderScreenState extends State<MealOrderScreen> {
  final Set<String> _selectedItems = {};
  bool _nopeSelected = false;

  @override
  void initState() {
    super.initState();
    _loadSavedOrders();
  }

  void _loadSavedOrders() {
    if (widget.savedOrders.isNotEmpty) {
      if (widget.savedOrders.contains('Nope')) {
        _nopeSelected = true;
      } else {
        _selectedItems.clear();
        for (final order in widget.savedOrders) {
          final menuItem = widget.menuItems.where((item) => item.name == order).firstOrNull;
          if (menuItem != null) {
            _selectedItems.add(menuItem.id);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.mealType} - ${DateFormat('yyyy-MM-dd').format(widget.selectedDate)}'),
        actions: [
          if (_selectedItems.isNotEmpty || _nopeSelected)
            TextButton(
              onPressed: _saveOrder,
              child: const Text('Save'),
            ),
        ],
      ),
      body: widget.menuItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.no_food,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No ${widget.mealType.toLowerCase()} items in menu',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please add items to menu first',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Nope option
                Card(
                  margin: const EdgeInsets.all(16.0),
                  child: ListTile(
                    title: const Text(
                      'Nope',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text('Not ordering this meal'),
                    leading: Radio<bool>(
                      value: true,
                      groupValue: _nopeSelected,
                      onChanged: (value) {
                        setState(() {
                          _nopeSelected = value!;
                          if (_nopeSelected) {
                            _selectedItems.clear();
                          }
                        });
                      },
                    ),
                    tileColor: _nopeSelected ? Colors.red[900] : null,
                  ),
                ),
                
                // Menu items
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: widget.menuItems.length,
                    itemBuilder: (context, index) {
                      final item = widget.menuItems[index];
                      final isSelected = _selectedItems.contains(item.id);
                      
                      return Card(
                        color: isSelected ? Colors.blue[900] : Colors.grey[800],
                        margin: const EdgeInsets.only(bottom: 8.0),
                        child: CheckboxListTile(
                          title: Text(
                            item.name,
                            style: const TextStyle(fontSize: 16),
                          ),
                          value: isSelected,
                          onChanged: _nopeSelected ? null : (bool? value) {
                            setState(() {
                              if (value == true) {
                                _selectedItems.add(item.id);
                                _nopeSelected = false;
                              } else {
                                _selectedItems.remove(item.id);
                              }
                            });
                          },
                          activeColor: Colors.blue,
                          tileColor: isSelected ? Colors.blue[900] : null,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  void _saveOrder() {
    final provider = Provider.of<EdenDataProvider>(context, listen: false);
    
    List<String> orderedItems = [];
    
    if (_nopeSelected) {
      orderedItems = ['Nope'];
    } else {
      orderedItems = widget.menuItems
          .where((item) => _selectedItems.contains(item.id))
          .map((item) => item.name)
          .toList();
    }
    
    // Save order for this specific date and meal
    final dateKey = DateFormat('yyyy-MM-dd').format(widget.selectedDate);
    final mealType = widget.mealType.toLowerCase();
    
    provider.addKitchenItems(mealType, orderedItems, dateKey);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.mealType} order saved for ${DateFormat('yyyy-MM-dd').format(widget.selectedDate)}!'),
        backgroundColor: Colors.green,
      ),
    );
    
    Navigator.pop(context);
  }
}