// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CarPartAdapter extends TypeAdapter<CarPart> {
  @override
  final int typeId = 0;

  @override
  CarPart read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CarPart(
      id: fields[0] as int,
      name: fields[1] as String,
      description: fields[2] as String,
      price: fields[3] as double,
      quantity: fields[4] as int,
      categoryId: fields[5] as int,
      seller: fields[6] as Seller?,
      photo: fields[7] as String?,
      categoryName: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CarPart obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.price)
      ..writeByte(4)
      ..write(obj.quantity)
      ..writeByte(5)
      ..write(obj.categoryId)
      ..writeByte(6)
      ..write(obj.seller)
      ..writeByte(7)
      ..write(obj.photo)
      ..writeByte(8)
      ..write(obj.categoryName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CarPartAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SellerAdapter extends TypeAdapter<Seller> {
  @override
  final int typeId = 2;

  @override
  Seller read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Seller(
      id: fields[0] as int?,
      username: fields[1] as String?,
      email: fields[2] as String?,
      phone: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Seller obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.username)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.phone);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SellerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Category _$CategoryFromJson(Map<String, dynamic> json) => Category(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      photo: json['photo'] as String,
    );

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'photo': instance.photo,
    };

CarPart _$CarPartFromJson(Map<String, dynamic> json) => CarPart(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: (json['quantity'] as num).toInt(),
      categoryId: (json['categoryId'] as num).toInt(),
      seller: json['seller'] == null
          ? null
          : Seller.fromJson(json['seller'] as Map<String, dynamic>),
      photo: json['photo'] as String?,
      categoryName: json['categoryName'] as String?,
    );

Map<String, dynamic> _$CarPartToJson(CarPart instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'price': instance.price,
      'quantity': instance.quantity,
      'categoryId': instance.categoryId,
      'seller': instance.seller,
      'photo': instance.photo,
      'categoryName': instance.categoryName,
    };

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: (json['id'] as num).toInt(),
      username: json['username'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      role: json['role'] as String,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'email': instance.email,
      'phone': instance.phone,
      'role': instance.role,
    };

PaginatedResponse<T> _$PaginatedResponseFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) =>
    PaginatedResponse<T>(
      results: (json['results'] as List<dynamic>).map(fromJsonT).toList(),
      totalPages: (json['total_pages'] as num).toInt(),
      currentPage: (json['current_page'] as num).toInt(),
      totalItems: (json['total_items'] as num).toInt(),
    );

Map<String, dynamic> _$PaginatedResponseToJson<T>(
  PaginatedResponse<T> instance,
  Object? Function(T value) toJsonT,
) =>
    <String, dynamic>{
      'results': instance.results.map(toJsonT).toList(),
      'total_pages': instance.totalPages,
      'current_page': instance.currentPage,
      'total_items': instance.totalItems,
    };

Seller _$SellerFromJson(Map<String, dynamic> json) => Seller(
      id: (json['id'] as num?)?.toInt(),
      username: json['username'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
    );

Map<String, dynamic> _$SellerToJson(Seller instance) => <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'email': instance.email,
      'phone': instance.phone,
    };
