import 'models.dart';
import 'package:hive/hive.dart';
part 'order.g.dart';

class Order {
  final int id;
  final int userId;
  final String userName;
  final DateTime createdAt;
  final double totalPrice;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.userId,
    required this.userName,
    required this.createdAt,
    required this.totalPrice,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      userId: json['user'],
      userName: json['user_name'],
      createdAt: DateTime.parse(json['created_at']),
      totalPrice: double.parse(json['total_price'].toString()),
      items: (json['items'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
    );
  }
}

class OrderItem {
  final int id;
  final String carPartName;
  final int quantity;
  final String photo;
  final double totalPrice;

  OrderItem({
    required this.id,
    required this.carPartName,
    required this.quantity,
    required this.photo,
    required this.totalPrice,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      carPartName: json['car_part_name'],
      quantity: json['quantity'],
      photo: json['photo'],
      totalPrice: double.parse(json['total_price'].toString()),
    );
  }
}


@HiveType(typeId: 1)
class CartItem {
  @HiveField(0)
  final CarPart carPart;

  @HiveField(1)
  final int quantity;

  @HiveField(2)
  final double price;

  CartItem({
    required this.carPart,
    required this.quantity,
    required this.price,
  });

  double get totalPrice => price * quantity;

  CartItem copyWith({CarPart? carPart, int? quantity, double? price}) {
    return CartItem(
      carPart: carPart ?? this.carPart,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
    );
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      carPart: CarPart.fromJson(json['car_part']),
      quantity: json['quantity'],
      price: double.parse(json['price'].toString()),
    );
  }

  Map<String, dynamic> toJson() => {
    'car_part': carPart.toJson(),
    'quantity': quantity,
    'price': price,
  };
}
