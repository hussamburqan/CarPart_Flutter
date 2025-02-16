import 'package:dio/dio.dart';
import '../Model/order.dart';
import 'DioHelper.dart';

class OrderService {
  final Dio _dio = DioHelper().dio;

  Future<Order> createOrder(List<CartItem> cartItems) async {
    if (cartItems.isEmpty) {
      throw Exception('Cart is empty. Cannot create an order.');
    }

    final items = cartItems.where((item) => item.carPart.id != null).map((item) {
      return {
        'part_id': item.carPart.id,
        'quantity': item.quantity,
      };
    }).toList();

    if (items.isEmpty) {
      throw Exception('No valid items to create an order.');
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
        throw Exception('Failed to create order: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
  Future<Map<String, dynamic>> getOrders({
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
      throw Exception('Failed to get orders: $e');
    }
  }

  Future<Map<String, dynamic>> getSoldOrders({int page = 1, int perPage = 5}) async {
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
      throw Exception('Failed to get sold orders: $e');
    }
  }


  Future<Order> updateOrderStatus(int orderId, String newStatus) async {
    try {
      final response = await _dio.put(
        '/orders/$orderId',
        data: {'status': newStatus},
      );

      return Order.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }
}