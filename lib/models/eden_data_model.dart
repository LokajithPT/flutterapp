
import 'package:json_annotation/json_annotation.dart';
import 'booking_model.dart';
import 'kitchen_model.dart';

part 'eden_data_model.g.dart';

@JsonSerializable()
class EdenData {
  final Map<String, Booking> dates;
  final Kitchen kitchen;

  EdenData({required this.dates, required this.kitchen});

  factory EdenData.fromJson(Map<String, dynamic> json) => _$EdenDataFromJson(json);
  Map<String, dynamic> toJson() => _$EdenDataToJson(this);
}
