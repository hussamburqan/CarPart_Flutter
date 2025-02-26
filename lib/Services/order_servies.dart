import 'package:dio/dio.dart';
import 'package:flutter/material.dart'; // Import for BuildContext
import '../Model/order.dart';
import 'dio_helper.dart';
import '../../Services/localizations.dart';

class OrderService {
  final Dio _dio = DioHelper().dio;

  Future<Order> createOrder({
    required BuildContext context,
    required List<CartItem> cartItems,
  }) async {
    if (cartItems.isEmpty) {
      throw Exception(AppLocalizations.of(context)!.translate('cart_empty')!);
    }

    final items = cartItems.where((item) => item.carPart.id != null).map((item) {
      return {
        'part_id': item.carPart.id,
        'quantity': item.quantity,
      };
    }).toList();

    if (items.isEmpty) {
      throw Exception(AppLocalizations.of(context)!.translate('no_valid_items')!);
    }

    print(items);
    try {
      final response = await _dio.post(
        '/orders',
        data: {'items': items},
      );
      print(response.data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Order.fromJson(response.data);
      } else {
        throw Exception(AppLocalizations.of(context)!.translate('failed_create_order')!);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getOrders({
    required BuildContext context,
    int page = 1,
    int perPage = 5,
  }) async {
    try {
      final response = await _dio.get('/orders', queryParameters: {
        'page': page.toString(),
        'per_page': perPage.toString(),
      });

      return {
        'orders': (response.data['results'] as List).map((json) => Order.fromJson(json)).toList(),
        'total_pages': response.data['total_pages'],
      };
    } catch (e) {
      throw Exception(AppLocalizations.of(context)!.translate('failed_get_orders')!);
    }
  }

  Future<Map<String, dynamic>> getSoldOrders({
    required BuildContext context,
    int page = 1,
    int perPage = 5,
  }) async {
    try {
      final response = await _dio.get('/seller-orders', queryParameters: {
        'page': page.toString(),
        'per_page': perPage.toString(),
      });

      print("📢 API Response: ${response.data}"); // ✅ اطبع البيانات القادمة

      return {
        'orders': (response.data['orders'] as List)
            .map((json) => Order.fromJson(json))
            .toList(),
        'total_pages': response.data['total_pages'],
      };
    } catch (e) {
      throw Exception(AppLocalizations.of(context)!.translate('failed_get_sold_orders')!);
    }
  }

  Future<Order> updateOrderStatus({
    required BuildContext context,
    required int orderId,
    required String newStatus,
  }) async {
    try {
      final response = await _dio.put(
        '/orders/$orderId',
        data: {'status': newStatus},
      );

      return Order.fromJson(response.data);
    } catch (e) {
      throw Exception(AppLocalizations.of(context)!.translate('failed_update_order_status')!);
    }
  }
}