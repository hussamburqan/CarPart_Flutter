import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import '../Model/order.dart';
import 'DioHelper.dart';

class LoginResponse {
  final bool requires2FA;
  final String? serverChallenge;
  final String? challengecreatedat;
  final String? accessToken;
  final String? refreshToken;

  LoginResponse({
    required this.requires2FA,
    this.serverChallenge,
    this.challengecreatedat,
    this.accessToken,
    this.refreshToken,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
    requires2FA: json['2fa_required'] ?? false,
    serverChallenge: json['server_challenge'],
    challengecreatedat: json['challenge_created_at'],
    accessToken: json['access_token'],
    refreshToken: json['refresh_token'],
  );
}


class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final Dio _dio = DioHelper().dio;
  final _authBox = Hive.box('auth');

  static const String _sharedSecret =
      '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8';

  Future<LoginResponse> login(String username, String password) async {
    try{
      final response = await _dio.post(
        '/login',
        data: jsonEncode({'username': username, 'password': password}),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      final loginResponse = LoginResponse.fromJson(response.data);
      if (loginResponse.requires2FA) {
        return loginResponse;
      }

      return await _completeHandshake(username , loginResponse.serverChallenge ?? '', loginResponse.challengecreatedat ?? '');
    } catch (e) {
      if (e is DioException) {
        final statusCode = e.response?.statusCode;
        if(statusCode==401){
          throw Exception('تاكد من اسم المستخدم او كلمة المرور');
        }
      }
      throw Exception('فشل تسجيل الدخول');
    }
  }

  Future<LoginResponse> _completeHandshake(String username,String serverChallenge,String timenow) async {

    final response = await _dio.post(
      '/verify-handshake',
      data: jsonEncode({
        'username': username,
        'client_response': _generateChallengeResponse(serverChallenge),
        'challenge_created_at': timenow,
        'server_challenge': serverChallenge,
      }),
      options: Options(headers: {'Content-Type': 'application/json'}),
    );

    final loginResponse = LoginResponse.fromJson(response.data);

    await _persistAuthData(loginResponse.accessToken!, loginResponse.refreshToken!,username,response.data['role'],response.data['id']);
    return loginResponse;
  }

  Future<void> verify2FA({
    required String username,
    required String serverChallenge,
    required String challenge_created_at,
    required String totp,
  }) async {
    try {
      final response = await _dio.post(
        '/verify-handshake',
        data: jsonEncode({
          'username': username,
          'client_response': _generateChallengeResponse(serverChallenge),
          'totp_token': totp,
          'challenge_created_at': challenge_created_at,
          'server_challenge': serverChallenge,
        }),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      print(response.data);
      final loginResponse = LoginResponse.fromJson(response.data);
      await _persistAuthData(loginResponse.accessToken!, loginResponse.refreshToken!,username,response.data['role'],response.data['id']);

    } catch (e) {
      if (e is DioException) {
        final statusCode = e.response?.statusCode;
        print(e.response?.data);
        if(statusCode==400){
          throw Exception('رمز التحقق خاطئ');
        }
      }
      throw Exception('فشل التحقق من المصادقة الثنائي');
    }
  }

  Future<void> register(String username, String email, String phone, String password) async {
    final response = await _dio.post(
      '/register',
      data: jsonEncode({'username': username, 'email': email, 'phone': phone, 'password': password}),
      options: Options(headers: {'Content-Type': 'application/json'}),
    );

    await _persistAuthData(response.data['access_token'], response.data['refresh_token'],username,response.data['role'],response.data['id']);
    return ;
  }

  Future<void> logout() async {
    await _dio.post('/logout');
    final _cartBox = Hive.box<CartItem>('cartBox');
    await _authBox.clear();
    await _cartBox.clear();

  }

  Future<void> _persistAuthData(String accessToken, String refreshToken,String username,String role,int id) async {
    print(accessToken);
    await _authBox.putAll({
      'accessToken': accessToken,
      'username': username,
      'id': id,
      'role': role,
      'refreshToken': refreshToken,
    });
  }
  Future<bool> isSeller() async {
    
    return _authBox.get('role');
  }
  String _generateChallengeResponse(String challenge) {
    final bytes = utf8.encode(challenge + _sharedSecret);
    return sha256.convert(bytes).toString();
  }
}
