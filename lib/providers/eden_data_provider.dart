
import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../models/eden_data_model.dart';
import '../services/storage_service.dart';

class EdenDataProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  EdenData? _edenData;
  int? _currentEdenId;

  EdenData? get edenData => _edenData;

  Future<void> loadData(int edenId) async {
    _currentEdenId = edenId;
    _edenData = await _storageService.loadEdenData(edenId);
    notifyListeners();
  }

  Future<void> addBooking(String date, Booking booking) async {
    if (_edenData != null && _currentEdenId != null) {
      _edenData!.dates[date] = booking;
      await _storageService.saveEdenData(_currentEdenId!, _edenData!);
      notifyListeners();
    }
  }

  Future<void> addKitchenItem(String meal, String item) async {
    if (_edenData != null && _currentEdenId != null) {
      switch (meal) {
        case 'Breakfast':
          _edenData!.kitchen.breakfast.add(item);
          break;
        case 'Lunch':
          _edenData!.kitchen.lunch.add(item);
          break;
        case 'Dinner':
          _edenData!.kitchen.dinner.add(item);
          break;
      }
      await _storageService.saveEdenData(_currentEdenId!, _edenData!);
      notifyListeners();
    }
  }

  Future<void> clearKitchenMeal(String meal) async {
    if (_edenData != null && _currentEdenId != null) {
      switch (meal) {
        case 'Breakfast':
          _edenData!.kitchen.breakfast.clear();
          break;
        case 'Lunch':
          _edenData!.kitchen.lunch.clear();
          break;
        case 'Dinner':
          _edenData!.kitchen.dinner.clear();
          break;
      }
      await _storageService.saveEdenData(_currentEdenId!, _edenData!);
      notifyListeners();
    }
  }
}
