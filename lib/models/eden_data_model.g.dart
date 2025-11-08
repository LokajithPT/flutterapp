// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'eden_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EdenData _$EdenDataFromJson(Map<String, dynamic> json) => EdenData(
      dates: (json['dates'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, Booking.fromJson(e as Map<String, dynamic>)),
      ),
      kitchen: Kitchen.fromJson(json['kitchen'] as Map<String, dynamic>),
      dailyKitchenOrders: DailyKitchenOrders.fromJson(
          json['dailyKitchenOrders'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$EdenDataToJson(EdenData instance) => <String, dynamic>{
      'dates': instance.dates,
      'kitchen': instance.kitchen,
      'dailyKitchenOrders': instance.dailyKitchenOrders,
    };
