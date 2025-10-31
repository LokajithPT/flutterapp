// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kitchen_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Kitchen _$KitchenFromJson(Map<String, dynamic> json) => Kitchen(
      breakfast:
          (json['breakfast'] as List<dynamic>).map((e) => e as String).toList(),
      lunch: (json['lunch'] as List<dynamic>).map((e) => e as String).toList(),
      dinner:
          (json['dinner'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$KitchenToJson(Kitchen instance) => <String, dynamic>{
      'breakfast': instance.breakfast,
      'lunch': instance.lunch,
      'dinner': instance.dinner,
    };
