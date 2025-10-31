// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Booking _$BookingFromJson(Map<String, dynamic> json) => Booking(
      name: json['name'] as String,
      contact: json['contact'] as String,
      checkin: json['checkin'] as String,
      checkout: json['checkout'] as String,
    );

Map<String, dynamic> _$BookingToJson(Booking instance) => <String, dynamic>{
      'name': instance.name,
      'contact': instance.contact,
      'checkin': instance.checkin,
      'checkout': instance.checkout,
    };
