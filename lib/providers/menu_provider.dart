import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../models/menu_model.dart';

class MenuProvider with ChangeNotifier {
  Menu _menu = Menu.empty();
  bool _isLoading = false;

  Menu get menu => _menu;
  bool get isLoading => _isLoading;

  Future<void> loadMenu() async {
    _isLoading = true;
    notifyListeners();

    try {
      final file = await _localFile;
      if (await file.exists()) {
        final contents = await file.readAsString();
        final jsonResponse = json.decode(contents);
        _menu = Menu.fromJson(jsonResponse);
      } else {
        _menu = Menu.empty();
      }
    } catch (e) {
      _menu = Menu.empty();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveMenu() async {
    try {
      final file = await _localFile;
      await file.writeAsString(json.encode(_menu.toJson()));
    } catch (e) {
      if (kDebugMode) {
        print('Error saving menu: $e');
      }
    }
  }

  Future<File> get _localFile async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/menu.json');
  }

  void addMenuItem(String mealType, String itemName) {
    final menuItem = MenuItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: itemName.trim(),
    );

    switch (mealType.toLowerCase()) {
      case 'breakfast':
        _menu = Menu(
          breakfast: [..._menu.breakfast, menuItem],
          lunch: _menu.lunch,
          dinner: _menu.dinner,
        );
        break;
      case 'lunch':
        _menu = Menu(
          breakfast: _menu.breakfast,
          lunch: [..._menu.lunch, menuItem],
          dinner: _menu.dinner,
        );
        break;
      case 'dinner':
        _menu = Menu(
          breakfast: _menu.breakfast,
          lunch: _menu.lunch,
          dinner: [..._menu.dinner, menuItem],
        );
        break;
    }

    notifyListeners();
    saveMenu();
  }

  void addMultipleMenuItems(String mealType, String itemsText) {
    final items = itemsText.split(',').map((item) => item.trim()).where((item) => item.isNotEmpty);
    
    for (final item in items) {
      addMenuItem(mealType, item);
    }
  }

  void removeMenuItem(String mealType, String itemId) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        _menu = Menu(
          breakfast: _menu.breakfast.where((item) => item.id != itemId).toList(),
          lunch: _menu.lunch,
          dinner: _menu.dinner,
        );
        break;
      case 'lunch':
        _menu = Menu(
          breakfast: _menu.breakfast,
          lunch: _menu.lunch.where((item) => item.id != itemId).toList(),
          dinner: _menu.dinner,
        );
        break;
      case 'dinner':
        _menu = Menu(
          breakfast: _menu.breakfast,
          lunch: _menu.lunch,
          dinner: _menu.dinner.where((item) => item.id != itemId).toList(),
        );
        break;
    }

    notifyListeners();
    saveMenu();
  }

  List<MenuItem> getMenuItems(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return _menu.breakfast;
      case 'lunch':
        return _menu.lunch;
      case 'dinner':
        return _menu.dinner;
      default:
        return [];
    }
  }
}