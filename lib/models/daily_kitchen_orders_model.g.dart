// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_kitchen_orders_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DailyKitchenOrders _$DailyKitchenOrdersFromJson(Map<String, dynamic> json) =>
    DailyKitchenOrders(
      orders: (json['orders'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, DailyOrder.fromJson(e as Map<String, dynamic>)),
      ),
    );

Map<String, dynamic> _$DailyKitchenOrdersToJson(DailyKitchenOrders instance) =>
    <String, dynamic>{
      'orders': instance.orders,
    };

DailyOrder _$DailyOrderFromJson(Map<String, dynamic> json) => DailyOrder(
      breakfast:
          (json['breakfast'] as List<dynamic>).map((e) => e as String).toList(),
      lunch: (json['lunch'] as List<dynamic>).map((e) => e as String).toList(),
      dinner:
          (json['dinner'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$DailyOrderToJson(DailyOrder instance) =>
    <String, dynamic>{
      'breakfast': instance.breakfast,
      'lunch': instance.lunch,
      'dinner': instance.dinner,
    };
