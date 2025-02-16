import 'package:dio/dio.dart';
import '../Model/models.dart' as app_models;
import 'DioHelper.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  final Dio _dio = DioHelper().dio;

  ApiService._internal();

  Map<String, dynamic> _ensureJsonMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    } else if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    throw FormatException('Invalid JSON data format');
  }

  Future<List<app_models.Category>> getCategories() async {
    return _executeRequest(() async {
      final response = await _dio.get('/categories');
      print(response.data);

      if (response.data is Map<String, dynamic> && response.data.containsKey('categories')) {
        final List<dynamic> data = response.data['categories'];
        return data.map((json) => app_models.Category.fromJson(_ensureJsonMap(json))).toList();
      } else {
        throw Exception('Unexpected response format: Missing "categories" key');
      }
    });
  }
  Future<Map<String, dynamic>> getCarParts({
    String? query,
    double? minPrice,
    double? maxPrice,
    String? condition,
    String? sortBy,
    int page = 1,
    int perPage = 10,
    int? categoryId,
    int? sellerId,
  }) async {
    return _executeRequest(() async {
      final response = await _dio.get('/car-parts', queryParameters: {
        if (query != null) 'query': query,
        if (minPrice != null) 'min_price': minPrice,
        if (maxPrice != null) 'max_price': maxPrice,
        if (condition != null) 'condition': condition,
        if (sortBy != null) 'sort_by': sortBy,
        if (categoryId != null) 'category': categoryId,
        if (sellerId != null) 'seller_id': sellerId,
        'page': page,
        'per_page': perPage,
      });

      if (response.data is Map<String, dynamic>) {
        return response.data;
      } else {
        throw Exception('Unexpected response format: Expected Map<String, dynamic>');
      }
    });
  }

  Future<void> createCarPart(Map<String, dynamic> carPartData, String imagePath) async {
    return _executeRequest(() async {
      FormData formData = FormData.fromMap(carPartData);

      if (imagePath != null) {
        formData.files.add(
          MapEntry('photo', await MultipartFile.fromFile(imagePath)),
        );

      } else {
        throw Exception('At least one image is required');
      }

      final response = await _dio.post('/car-parts', data: formData);
      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');
    });
  }

  Future<void> updateCarPart(int id, Map<String, dynamic> updates, String imagePath) async {
    return _executeRequest(() async {
      FormData formData = FormData.fromMap(updates);

      formData.files.add(
        MapEntry('photo', await MultipartFile.fromFile(imagePath)),
      );

      await _dio.put('/car-parts/$id/', data: formData);
    });
  }

  Future<void> updateCarPartNoPhoto(int id, Map<String, dynamic> updates) async {
    return _executeRequest(() async {
      FormData formData = FormData.fromMap(updates);

      await _dio.put('/car-parts/$id/', data: formData);
    });
  }

  Future<List<app_models.Seller>> getSellers() async {
    return _executeRequest(() async {
      try {
        final response = await _dio.get('/seller-accounts');

        print("Raw Response Data: ${response.data}");

        if (response.data is Map<String, dynamic> && response.data.containsKey('sellers')) {
          final sellersData = response.data['sellers'];

          if (sellersData is List) {
            return sellersData.map((json) {
              try {
                return app_models.Seller.fromJson(_ensureJsonMap(json));
              } catch (e) {
                print("Error parsing seller JSON: $e");
                return null;
              }
            }).whereType<app_models.Seller>().toList();
          } else {
            print("Unexpected sellersData format: $sellersData");
            return [];
          }
        } else {
          print("Invalid response format: ${response.data}");
          return [];
        }
      } on DioException catch (e) {
        print("❌ DioException - Status Code: ${e.response?.statusCode}");
        print("❌ DioException - Data: ${e.response?.data}");
        print("❌ DioException - Headers: ${e.response?.headers}");
        return [];
      } catch (e) {
        print("❌ Unknown Error: $e");
        return [];
      }
    });
  }





  Future<T> _executeRequest<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        final refreshResponse = await _dio.post('/refresh-token');
        if (refreshResponse.statusCode == 200) {
          final newAccessToken = refreshResponse.data['access_token'];
          _dio.options.headers['Authorization'] = 'Bearer $newAccessToken';
          return await request();
        } else {
          throw Exception('Authentication failed. Please login again.');
        }
      }
      throw _handleError(e);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Exception _handleError(dynamic error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      final errorMessage = error.response?.data?['error'] ?? error.message;

      switch (statusCode) {
        case 400:
          return Exception('Invalid request: $errorMessage');
        case 401:
          return Exception('Authentication required. Please login again.');
        case 403:
          return Exception('You do not have permission to perform this action');
        case 404:
          return Exception('Resource not found');
        case 422:
          return Exception('Validation error: $errorMessage');
        default:
          return Exception('HTTP Error: $errorMessage');
      }
    }
    if (error is FormatException) {
      return Exception('Invalid data format received from server');
    }
    return Exception('An unexpected error occurred');
  }
}
