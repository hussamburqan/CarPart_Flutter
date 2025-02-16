import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'models.g.dart';

@JsonSerializable()
class Category {
  final int id;
  final String name;
  final String photo;

  Category({
    required this.id,
    required this.name,
    required this.photo,
  });

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryToJson(this);
}

@JsonSerializable()
@HiveType(typeId: 0)
class CarPart {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String description;
  @HiveField(3)
  final double price;
  @HiveField(4)
  final int quantity;
  @HiveField(5)
  final int categoryId;
  @HiveField(6)
  final Seller? seller;
  @HiveField(7)
  final String? photo;
  @HiveField(8)
  final String? categoryName;

  CarPart({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    required this.categoryId,
    this.seller,
    this.photo,
    this.categoryName,
  });

  factory CarPart.fromJson(Map<String, dynamic> json) {
    return CarPart(
      id: json['id'],
      name: json['name'] ?? 'Unknown',
      description: json['description'] ?? 'No description available',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      quantity: json['stock'] ?? 0,
      categoryId: json['category'] ?? 0,
      seller: json['seller'] != null ? Seller.fromJson(json['seller']) : null,
      photo: json['photo']?.toString(),
      categoryName: json['category_name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => _$CarPartToJson(this);
}


@JsonSerializable()
class User {
  final int id;
  final String username;
  final String email;
  final String phone;
  final String role;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.phone,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable(genericArgumentFactories: true)
class PaginatedResponse<T> {
  final List<T> results;

  @JsonKey(name: 'total_pages')
  final int totalPages;

  @JsonKey(name: 'current_page')
  final int currentPage;

  @JsonKey(name: 'total_items')
  final int totalItems;

  PaginatedResponse({
    required this.results,
    required this.totalPages,
    required this.currentPage,
    required this.totalItems,
  });

  factory PaginatedResponse.fromJson(
      Map<String, dynamic> json,
      T Function(Object? json) fromJsonT,
      ) =>
      _$PaginatedResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$PaginatedResponseToJson(this, toJsonT);
}
@JsonSerializable()
@HiveType(typeId: 2)
class Seller {
  @HiveField(0)
  final int? id;
  @HiveField(1)
  final String? username;
  @HiveField(2)
  final String? email;
  @HiveField(3)
  final String? phone;

  Seller({
    required this.id,
    required this.username,
    required this.email,
    required this.phone,
  });

  factory Seller.fromJson(Map<String, dynamic> json) {
    return Seller(
      id: json['user__id'] ?? json['id'] ,
      username: json['user__username'] ?? json['username'] ,
      email: json['user__email'] ?? json['email'] ,
      phone: json['phone'] ?? 'No Phone',
    );
  }



  Map<String, dynamic> toJson() => _$SellerToJson(this);
}
