
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import '../models/eden_data_model.dart';
import '../models/kitchen_model.dart';
import '../models/daily_kitchen_orders_model.dart';

class StorageService {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> _localFile(int edenId) async {
    final path = await _localPath;
    final String fileName = _getEdenFileName(edenId);
    return File('$path/$fileName.json');
  }

  Future<EdenData> loadEdenData(int edenId) async {
    try {
      final file = await _localFile(edenId);
      final contents = await file.readAsString();
      final jsonResponse = json.decode(contents);
      return EdenData.fromJson(jsonResponse);
    } catch (e) {
      // If the file doesn't exist, return a default structure
      return EdenData(
        dates: {},
        kitchen: Kitchen(breakfast: [], lunch: [], dinner: []),
        dailyKitchenOrders: DailyKitchenOrders.empty(),
      );
    }
  }

  Future<File> saveEdenData(int edenId, EdenData data) async {
    final file = await _localFile(edenId);
    return file.writeAsString(json.encode(data.toJson()));
  }

  String _getEdenFileName(int edenId) {
    switch (edenId) {
      case 1:
      case 2:
      case 3:
      case 4:
      case 6:
      case 7:
        return 'eden$edenId';
      case 8:
        return 'koonoor';
      case 9:
        return 'kodanadu';
      case 10:
        return 'others';
      default:
        return 'eden$edenId';
    }
  }
}
