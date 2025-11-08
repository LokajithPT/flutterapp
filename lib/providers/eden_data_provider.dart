
import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../models/eden_data_model.dart';
import '../models/daily_kitchen_orders_model.dart';
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

  Future<void> removeBooking(String date) async {
    if (_edenData != null && _currentEdenId != null) {
      _edenData!.dates.remove(date);
      await _storageService.saveEdenData(_currentEdenId!, _edenData!);
      notifyListeners();
    }
  }

  Future<void> addKitchenItems(String meal, List<String> items, String date) async {
    if (_edenData != null && _currentEdenId != null) {
      DailyOrder? dailyOrder = _edenData!.dailyKitchenOrders.getOrderForDate(date);
      
      if (dailyOrder == null) {
        dailyOrder = DailyOrder.empty();
      }
      
      dailyOrder.setMealOrders(meal, items);
      _edenData!.dailyKitchenOrders.setOrderForDate(date, dailyOrder);
      
      await _storageService.saveEdenData(_currentEdenId!, _edenData!);
      notifyListeners();
    }
  }

  List<String> getDailyKitchenOrders(String date, String mealType) {
    if (_edenData == null) return [];
    
    DailyOrder? dailyOrder = _edenData!.dailyKitchenOrders.getOrderForDate(date);
    if (dailyOrder == null) return [];
    
    return dailyOrder.getMealOrders(mealType);
  }


}
