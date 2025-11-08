import 'package:json_annotation/json_annotation.dart';

part 'daily_kitchen_orders_model.g.dart';

@JsonSerializable()
class DailyKitchenOrders {
  Map<String, DailyOrder> orders;

  DailyKitchenOrders({
    required this.orders,
  });

  factory DailyKitchenOrders.fromJson(Map<String, dynamic> json) => _$DailyKitchenOrdersFromJson(json);
  Map<String, dynamic> toJson() => _$DailyKitchenOrdersToJson(this);

  factory DailyKitchenOrders.empty() {
    return DailyKitchenOrders(orders: {});
  }

  DailyOrder? getOrderForDate(String dateKey) {
    return orders[dateKey];
  }

  void setOrderForDate(String dateKey, DailyOrder order) {
    orders[dateKey] = order;
  }
}

@JsonSerializable()
class DailyOrder {
  List<String> breakfast;
  List<String> lunch;
  List<String> dinner;

  DailyOrder({
    required this.breakfast,
    required this.lunch,
    required this.dinner,
  });

  factory DailyOrder.fromJson(Map<String, dynamic> json) => _$DailyOrderFromJson(json);
  Map<String, dynamic> toJson() => _$DailyOrderToJson(this);

  factory DailyOrder.empty() {
    return DailyOrder(
      breakfast: [],
      lunch: [],
      dinner: [],
    );
  }

  List<String> getMealOrders(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return breakfast;
      case 'lunch':
        return lunch;
      case 'dinner':
        return dinner;
      default:
        return [];
    }
  }

  void setMealOrders(String mealType, List<String> items) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        breakfast = items;
        break;
      case 'lunch':
        lunch = items;
        break;
      case 'dinner':
        dinner = items;
        break;
    }
  }
}