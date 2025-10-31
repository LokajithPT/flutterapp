
import 'package:json_annotation/json_annotation.dart';

part 'kitchen_model.g.dart';

@JsonSerializable()
class Kitchen {
  List<String> breakfast;
  List<String> lunch;
  List<String> dinner;

  Kitchen({
    required this.breakfast,
    required this.lunch,
    required this.dinner,
  });

  factory Kitchen.fromJson(Map<String, dynamic> json) => _$KitchenFromJson(json);
  Map<String, dynamic> toJson() => _$KitchenToJson(this);
}
