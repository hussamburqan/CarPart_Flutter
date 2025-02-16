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
    dio = Dio(BaseOptions(
      baseUrl: 'https://carparts1234.pythonanywhere.com/mypartapi',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 5),
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final accessToken = _authBox.get('accessToken');
        final refreshToken = _authBox.get('refreshToken');
        if (accessToken != null && options.path != '/refresh-token') {
          options.headers['Authorization'] = 'Bearer $accessToken';
        } else
          if (accessToken == null && refreshToken == null && !(options.path != '/login' || options.path != '/register' || options.path != '/verify-handshake')){
            WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(navigatorKey.currentContext!).pushReplacementNamed('/login');
          });
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if(error.response!.data['error'] == 'Incorrect password' || error.response!.data['error'] == 'Invalid credentials'){
          return handler.next(error);
        }
        if (error.response?.statusCode == 401 && !_isRefreshing) {
          _isRefreshing = true;
          final refreshed = await _refreshToken();
          if(refreshed == null){
            await _authBox.clear();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(navigatorKey.currentContext!).pushReplacementNamed('/login');
            });
          }
          if (refreshed!.statusCode == 200) {
            final requestOptions = error.requestOptions;
            requestOptions.headers['Authorization'] = 'Bearer ${_authBox.get('accessToken')}';

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
          } else if(refreshed!.statusCode == 400){
            await _authBox.clear();
            await _cartBox.clear();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(navigatorKey.currentContext!).pushReplacementNamed('/login');
            });

          } else{
          }
        }
        handler.next(error);
      },
    ));
  }

  Future<Response?> _refreshToken() async {
    final refreshToken = _authBox.get('refreshToken');
    if (refreshToken == null) {
      _isRefreshing = false;
      return null;
    }

    try {
      final response = await dio.post('/refresh-token', options: Options(headers: {
        'Refresh-Token': '$refreshToken',
      }));

      if (response.statusCode == 200 && response.data != null) {
        final newAccessToken = response.data['access_token'];

        await _authBox.put('accessToken', newAccessToken);
        _isRefreshing = false;
        return response;
      }
    } catch (e) {
      _isRefreshing = false;
    }

    _isRefreshing = false;
    return null;
  }
}

