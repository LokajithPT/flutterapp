
import 'package:json_annotation/json_annotation.dart';

part 'booking_model.g.dart';

@JsonSerializable()
class Booking {
  final String name;
  final String contact;
  final String checkin;
  final String checkout;

  Booking({
    required this.name,
    required this.contact,
    required this.checkin,
    required this.checkout,
  });

  factory Booking.fromJson(Map<String, dynamic> json) => _$BookingFromJson(json);
  Map<String, dynamic> toJson() => _$BookingToJson(this);
}
