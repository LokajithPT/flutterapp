
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import '../models/eden_data_model.dart';
import '../models/kitchen_model.dart';

class StorageService {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> _localFile(int edenId) async {
    final path = await _localPath;
    return File('$path/eden$edenId.json');
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
      );
    }
  }

  Future<File> saveEdenData(int edenId, EdenData data) async {
    final file = await _localFile(edenId);
    return file.writeAsString(json.encode(data.toJson()));
  }
}
