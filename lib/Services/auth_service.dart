import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../Model/user.dart';

class LoginResponse {
  final bool requires2FA;
  final String? serverChallenge;
  final String? token;
  final String? email;
  final String? detail;

  LoginResponse({
    required this.requires2FA,
    this.serverChallenge,
    this.token,
    this.email,
    this.detail,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      requires2FA: json['2fa_required'] ?? false,
      serverChallenge: json['server_challenge'],
      token: json['encrypted_token'],
      email: json['email'],
      detail: json['detail'],
    );
  }
}

class AuthService {
  final Dio _dio;
  static const String baseUrl = 'http://10.0.2.2:8000/mypartapi';
  static const String sharedSecret = "5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8";

  AuthService() : _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  )) {
    _initializeInterceptors();
  }
  void _initializeInterceptors() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final box = await Hive.openBox('auth');
        final sessionId = box.get('session_id');

        if (sessionId != null) {
          options.headers['Cookie'] = sessionId; // إرسال session_id
        }

        print('REQUEST [${options.method}] => PATH: ${options.path}');
        print('HEADERS: ${options.headers}');
        print('BODY: ${options.data}');

        return handler.next(options);
      },
      onResponse: (response, handler) async {
        print('RESPONSE [${response.statusCode}] => DATA: ${response.data}');
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        print('ERROR [${e.response?.statusCode}] => MESSAGE: ${e.message}');
        return handler.next(e);
      },
    ));
  }


  String _generateChallengeResponse(String challenge) {
    final input = challenge + sharedSecret;
    final bytes = utf8.encode(input);
    return sha256.convert(bytes).toString();
  }

  Future<LoginResponse> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/login',
        data: {'username': username, 'password': password},
      );

      if (response.statusCode == 200) {
        final cookies = response.headers['set-cookie'];
        if (cookies != null && cookies.isNotEmpty) {
          for (var cookie in cookies) {
            if (cookie.startsWith('sessionid=')) {
              final sessionId = cookie.split(';')[0]; // استخلاص sessionid فقط
              final box = await Hive.openBox('auth');
              await box.put('session_id', sessionId); // تخزين السيشن في Hive
              print('Session ID stored: $sessionId');
              break;
            }
          }
        }

        // تخزين التحدي المستلم من السيرفر
        final box = await Hive.openBox('auth');
        await box.put('server_challenge', response.data['server_challenge']);

        return LoginResponse.fromJson(response.data);
      }
      throw Exception(response.data['detail'] ?? 'Login failed');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> verify2FA({
    required String username,
    required String totpToken,
  }) async {
    try {
      final box = await Hive.openBox('auth');
      final sessionId = box.get('session_id');
      final serverChallenge = box.get('server_challenge');

      if (serverChallenge == null || sessionId == null) {
        throw Exception('Session or challenge data not found');
      }

      final response = await _dio.post(
        '/verify-handshake',
        data: {
          'username': username,
          'client_response': _generateChallengeResponse(serverChallenge),
          'totp_token': totpToken,
        },
        options: Options(
          headers: {'Cookie': sessionId}, // إرسال session_id مع الطلب
        ),
      );

      if (response.statusCode != 200) {
        throw Exception(response.data['detail'] ?? 'Verification failed');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }


  Future<User> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/register',
        data: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Token will be saved by the interceptor from the cookie

        final user = User(
          username: username,
          email: email,
        );
        await _saveUser(user);
        return user;
      }

      throw Exception(response.data['detail'] ?? 'Registration failed');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('/logout');
    } finally {
      await clearSession();
    }
  }

  Future<void> setup2FA() async {
    try {
      final response = await _dio.get('/setup-2fa');

      if (response.statusCode == 200) {
        return response.data;
      }

      throw Exception(response.data['error'] ?? 'Failed to setup 2FA');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> disable2FA() async {
    try {
      final response = await _dio.post('/disable-2fa');

      if (response.statusCode != 200) {
        throw Exception(response.data['error'] ?? 'Failed to disable 2FA');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> _saveUser(User user) async {
    final box = await Hive.openBox<User>('users');
    await box.put('currentUser', user);
  }

  Future<User?> getCurrentUser() async {
    final box = await Hive.openBox<User>('users');
    return box.get('currentUser');
  }

  Future<void> clearSession() async {
    final authBox = await Hive.openBox('auth');
    final usersBox = await Hive.openBox<User>('users');
    await authBox.clear();
    await usersBox.clear();
  }

  Exception _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return Exception('Connection timeout. Please check your internet connection.');
    }

    if (e.response?.statusCode == 401) {
      return Exception('Invalid credentials');
    }

    if (e.response?.statusCode == 400) {
      final message = e.response?.data['detail'] ??
          e.response?.data['error'] ??
          'Bad request';
      return Exception(message);
    }

    return Exception('An unexpected error occurred. Please try again.');
  }

  Future<bool> hasValidSession() async {
    try {
      final box = await Hive.openBox('auth');
      return box.get('token') != null;
    } catch (e) {
      return false;
    }
  }
}