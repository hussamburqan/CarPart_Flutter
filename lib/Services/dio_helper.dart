import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

import '../Model/order.dart';
import '../main.dart';

class DioHelper {
  static final DioHelper _instance = DioHelper._internal();
  factory DioHelper() => _instance;

  late Dio dio;
  final _authBox = Hive.box('auth');
  final _cartBox = Hive.box<CartItem>('cartBox');
  bool _isRefreshing = false;

  DioHelper._internal() {
    _initDio();
  }

  void _initDio() {
    print('DioHelper: Initializing Dio...');

    dio = Dio(BaseOptions(
      baseUrl: 'https://carparts1234.pythonanywhere.com/mypartapi',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 5),
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        print('DioHelper: Requesting ${options.method} ${options.uri}');
        print('DioHelper: Request Headers: ${options.headers}');
        print('DioHelper: Request Data: ${options.data}');

        final accessToken = _authBox.get('accessToken');
        final refreshToken = _authBox.get('refreshToken');
        if (accessToken != null && options.path != '/refresh-token') {
          options.headers['Authorization'] = 'Bearer $accessToken';
        } else if (accessToken == null && refreshToken == null) {
          if (options.path != '/login' && options.path != '/register' && options.path != '/verify-handshake' && options.path != '/verify-email' && options.path != '/reset-password' && options.path != '/send-verification-code' && options.path != '/send-verification-code-reg') {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(navigatorKey.currentContext!).pushReplacementNamed('/login');
            });
          }
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        print('DioHelper: Response for ${response.requestOptions.uri}');
        print('DioHelper: Response Status: ${response.statusCode}');
        print('DioHelper: Response Data: ${response.data}');
        handler.next(response);
      },
      onError: (error, handler) async {
        print('DioHelper: Error for ${error.requestOptions.uri}');
        print('DioHelper: Error Message: ${error.message}');
        print('DioHelper: Error Response: ${error.response?.data}');
        if (error.response != null && error.response!.data is Map) {
          final errorData = error.response!.data as Map<String, dynamic>;
          if (errorData.containsKey('error')) {
            final errorMessage = errorData['error'];
            if (errorMessage == 'Invalid credentials') {
              return handler.next(error);
            }
          }
        }
        if (error.response?.statusCode == 401 && !_isRefreshing) {
          _isRefreshing = true;
          final refreshed = await _refreshToken();
          if (refreshed == null) {
            await _authBox.clear();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(navigatorKey.currentContext!)
                  .pushReplacementNamed('/login');
            });
          }
          if (refreshed!.statusCode == 200) {
            final requestOptions = error.requestOptions;
            requestOptions.headers['Authorization'] =
            'Bearer ${_authBox.get('accessToken')}';

            final retryResponse = await dio.request(
              requestOptions.path,
              options: Options(
                method: requestOptions.method,
                headers: requestOptions.headers,
              ),
              data: requestOptions.data,
              queryParameters: requestOptions.queryParameters,
            );

            return handler.resolve(retryResponse);
          } else if (refreshed!.statusCode == 400) {
            await _authBox.clear();
            await _cartBox.clear();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(navigatorKey.currentContext!)
                  .pushReplacementNamed('/login');
            });
          } else {}
        }
        handler.next(error);
      },
    ));
    print('DioHelper: Dio initialized with interceptors.');
  }

  Future<Response?> _refreshToken() async {
    print('DioHelper: Refreshing token...');
    final refreshToken = _authBox.get('refreshToken');
    if (refreshToken == null) {
      print('DioHelper: No refresh token available.');
      _isRefreshing = false;
      return null;
    }

    try {
      final response = await dio.post('/refresh-token',
          options: Options(headers: {
            'Refresh-Token': '$refreshToken',
          }));

      if (response.statusCode == 200 && response.data != null) {
        final newAccessToken = response.data['access_token'];

        await _authBox.put('accessToken', newAccessToken);
        _isRefreshing = false;
        print('DioHelper: Token refreshed successfully.');
        return response;
      }
    } catch (e) {
      print('DioHelper: Error refreshing token: $e');
      _isRefreshing = false;
    }

    _isRefreshing = false;
    print('DioHelper: Failed to refresh token.');
    return null;
  }
}
