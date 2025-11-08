import 'package:json_annotation/json_annotation.dart';

part 'menu_model.g.dart';

@JsonSerializable()
class MenuItem {
  final String id;
  final String name;

  MenuItem({
    required this.id,
    required this.name,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) => _$MenuItemFromJson(json);
  Map<String, dynamic> toJson() => _$MenuItemToJson(this);
}

@JsonSerializable()
class Menu {
  final List<MenuItem> breakfast;
  final List<MenuItem> lunch;
  final List<MenuItem> dinner;

  Menu({
    required this.breakfast,
    required this.lunch,
    required this.dinner,
  });

  factory Menu.fromJson(Map<String, dynamic> json) => _$MenuFromJson(json);
  Map<String, dynamic> toJson() => _$MenuToJson(this);

  factory Menu.empty() {
    return Menu(
      breakfast: [],
      lunch: [],
      dinner: [],
    );
  }
}