import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../Model/order.dart';
import 'dio_helper.dart';
import '../../Services/localizations.dart';

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

  Future<LoginResponse> login({
    required BuildContext context,
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/login',
        data: jsonEncode({'username': username, 'password': password}),
      );
      if (response.statusCode == 200) {
        final loginResponse = LoginResponse.fromJson(response.data);
        if (loginResponse.requires2FA) {
          return loginResponse;
        }

        return await _completeHandshake(
          context: context,
          username: username,
          serverChallenge: loginResponse.serverChallenge ?? '',
          timenow: loginResponse.challengecreatedat ?? '',
        );
      } else {
        throw Exception('Invalid credentials');
      }
    } catch (e) {


      if (e is DioException) {
        if (e.response?.statusCode == 401) {
          throw Exception(AppLocalizations.of(context)!.translate('invalid_credentials')!);
        }
      }

      throw Exception(AppLocalizations.of(context)!.translate('login_failed')!);
    }
  }

  Future<void> sendVerificationCode({
    required BuildContext context,
    required String email,
  }) async {
    try {
      final response = await _dio.post('/send-verification-code', data: {
        'email': email,
      });

      if (response.statusCode != 200) {
        throw DioException(requestOptions: RequestOptions(path: ''), error: response.data);
      }
    } catch (e) {
      throw Exception(AppLocalizations.of(context)!.translate('verification_code_failed')!);
    }
  }
  Future<void> sendVerificationCodeReg({
    required BuildContext context,
    required String email,
  }) async {
    try {
      final response = await _dio.post('/send-verification-code-reg', data: {
        'email': email,
      });

      if (response.statusCode != 200) {
        throw DioException(requestOptions: RequestOptions(path: ''), error: response.data);
      }
    } catch (e) {
      throw Exception(AppLocalizations.of(context)!.translate('verification_code_failed_exist')!);
    }
  }
  Future<void> resetPassword({
    required BuildContext context,
    required String email,
    required String newPassword,
  }) async {
    try {
      final response = await _dio.post(
        '/reset-password',
        data: {
          'email': email,
          'new_password': newPassword,
        },
      );

      if (response.statusCode != 200) {
        throw DioException(
          requestOptions: RequestOptions(path: '/reset-password'),
          error: response.data,
        );
      }
    } catch (e) {
      throw e;
    }
  }

  Future<bool> verifyEmail({
    required BuildContext context,
    required String email,
    required String verificationCode,
  }) async {
    try {
      final response = await _dio.post('/verify-email', data: {
        'email': email,
        'verification_code': verificationCode,
      });

      if (response.statusCode == 200) {
        return true;
      } else {
        throw DioException(requestOptions: RequestOptions(path: ''), error: response.data);
      }
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 400) {
          throw Exception(AppLocalizations.of(context)!.translate('invalid_verification_code')!);
        }
      }
      throw Exception(AppLocalizations.of(context)!.translate('email_verification_failed')!);
    }
  }

  Future<LoginResponse> _completeHandshake({
    required BuildContext context,
    required String username,
    required String serverChallenge,
    required String timenow,
  }) async {
    try {
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

      await _persistAuthData(
        loginResponse.accessToken!,
        loginResponse.refreshToken!,
        username,
        response.data['role'],
        response.data['id'],
      );
      return loginResponse;
    } catch (e) {
      throw Exception(AppLocalizations.of(context)!.translate('handshake_failed')!);
    }
  }

  Future<void> verify2FA({
    required BuildContext context,
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

      final loginResponse = LoginResponse.fromJson(response.data);
      await _persistAuthData(
        loginResponse.accessToken!,
        loginResponse.refreshToken!,
        username,
        response.data['role'],
        response.data['id'],
      );
    } catch (e) {
      if (e is DioException) {
        final statusCode = e.response?.statusCode;
        if (statusCode == 400) {
          throw Exception(AppLocalizations.of(context)!.translate('invalid_verification_code')!);
        }
      }
      throw Exception(AppLocalizations.of(context)!.translate('2fa_verification_failed')!);
    }
  }

  Future<void> register({
    required BuildContext context,
    required String username,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/register',
        data: jsonEncode({'username': username, 'email': email, 'phone': phone, 'password': password}),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      await _persistAuthData(
        response.data['access_token'],
        response.data['refresh_token'],
        username,
        response.data['role'],
        response.data['id'],
      );
    } catch (e) {
      throw Exception(AppLocalizations.of(context)!.translate('registration_failed')!);
    }
  }

  Future<void> logout(context) async {
    try {
      await _dio.post('/logout');
      final _cartBox = Hive.box<CartItem>('cartBox');
      await _authBox.clear();
      await _cartBox.clear();
    } catch (e) {
      throw Exception(AppLocalizations.of(context)!.translate('logout_failed')!);
    }
  }

  Future<void> _persistAuthData(String accessToken, String refreshToken, String username, String role, int id) async {
    await _authBox.putAll({
      'accessToken': accessToken,
      'username': username,
      'id': id,
      'role': role,
      'refreshToken': refreshToken,
    });
  }

  Future<bool> isSeller() async {
    return _authBox.get('role') == 'seller';
  }

  String _generateChallengeResponse(String challenge) {
    final bytes = utf8.encode(challenge + _sharedSecret);
    return sha256.convert(bytes).toString();
  }
}