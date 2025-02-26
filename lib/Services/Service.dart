import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../Model/models.dart' as app_models;
import 'dio_helper.dart';
import '../../Services/localizations.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  final Dio _dio = DioHelper().dio;

  ApiService._internal();

  Map<String, dynamic> _ensureJsonMap(dynamic data,context) {
    if (data is Map<String, dynamic>) {
      return data;
    } else if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    throw FormatException(AppLocalizations.of(context)!.translate('invalid_json_format')!);
  }

  Future<List<app_models.Category>> getCategories(BuildContext context) async {
    return _executeRequest(context, () async {
      final response = await _dio.get('/categories');
      print(response.data);

      if (response.data is Map<String, dynamic> && response.data.containsKey('categories')) {
        final List<dynamic> data = response.data['categories'];
        return data.map((json) => app_models.Category.fromJson(_ensureJsonMap(json,context))).toList();
      } else {
        throw Exception(AppLocalizations.of(context)!.translate('unexpected_response_format')!);
      }
    });
  }

  Future<Map<String, dynamic>> getCarParts({
    required BuildContext context,
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
    return _executeRequest(context, () async {
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
        throw Exception(AppLocalizations.of(context)!.translate('unexpected_response_format')!);
      }
    });
  }

  Future<void> createCarPart({
    required BuildContext context,
    required Map<String, dynamic> carPartData,
    required String imagePath,
  }) async {
    return _executeRequest(context, () async {
      FormData formData = FormData.fromMap(carPartData);

      if (imagePath != null) {
        formData.files.add(
          MapEntry('photo', await MultipartFile.fromFile(imagePath)),
        );
      } else {
        throw Exception(AppLocalizations.of(context)!.translate('image_required')!);
      }

      final response = await _dio.post('/car-parts', data: formData);
      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');
    });
  }

  Future<void> updateCarPart({
    required BuildContext context,
    required int id,
    required Map<String, dynamic> updates,
    required String imagePath,
  }) async {
    return _executeRequest(context, () async {
      FormData formData = FormData.fromMap(updates);

      formData.files.add(
        MapEntry('photo', await MultipartFile.fromFile(imagePath)),
      );

      await _dio.put('/car-parts/$id/', data: formData);
    });
  }

  Future<void> updateCarPartNoPhoto({
    required BuildContext context,
    required int id,
    required Map<String, dynamic> updates,
  }) async {
    return _executeRequest(context, () async {
      FormData formData = FormData.fromMap(updates);

      await _dio.put('/car-parts/$id/', data: formData);
    });
  }

  Future<List<app_models.Seller>> getSellers(BuildContext context) async {
    return _executeRequest(context, () async {
      try {
        final response = await _dio.get('/seller-accounts');

        print("Raw Response Data: ${response.data}");

        if (response.data is Map<String, dynamic> && response.data.containsKey('sellers')) {
          final sellersData = response.data['sellers'];

          if (sellersData is List) {
            return sellersData.map((json) {
              try {
                return app_models.Seller.fromJson(_ensureJsonMap(json,context));
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

  Future<T> _executeRequest<T>(BuildContext context, Future<T> Function() request) async {
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
          throw Exception(AppLocalizations.of(context)!.translate('authentication_failed')!);
        }
      }
      throw _handleError(context, e);
    } catch (e) {
      throw Exception(AppLocalizations.of(context)!.translate('unexpected_error')!);
    }
  }

  Exception _handleError(BuildContext context, dynamic error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      final errorMessage = error.response?.data?['error'] ?? error.message;

      switch (statusCode) {
        case 400:
          return Exception(AppLocalizations.of(context)!.translate('invalid_request')!);
        case 401:
          return Exception(AppLocalizations.of(context)!.translate('authentication_required')!);
        case 403:
          return Exception(AppLocalizations.of(context)!.translate('permission_denied')!);
        case 404:
          return Exception(AppLocalizations.of(context)!.translate('resource_not_found')!);
        case 422:
          return Exception(AppLocalizations.of(context)!.translate('validation_error')!);
        default:
          return Exception(AppLocalizations.of(context)!.translate('http_error')!);
      }
    }
    if (error is FormatException) {
      return Exception(AppLocalizations.of(context)!.translate('invalid_data_format')!);
    }
    return Exception(AppLocalizations.of(context)!.translate('unexpected_error')!);
  }
}