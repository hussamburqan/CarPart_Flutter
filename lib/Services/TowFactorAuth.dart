import 'package:dio/dio.dart';
import 'dio_helper.dart';
import 'package:flutter/material.dart';
import '../../Services/localizations.dart';

class TwoFactorAuthService {
  final Dio _dio = DioHelper().dio;

  TwoFactorAuthService();

  Future<Map<String, dynamic>?> setup2FA(BuildContext context) async {
    try {
      final response = await _dio.get('/setup-2fa');
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception(AppLocalizations.of(context)!.translate('error_connecting')!);
      }
    } catch (e) {
      return null;
    }
  }

  Future<bool> verifySetup2FA(String verificationCode, BuildContext context) async {
    try {
      final response = await _dio.post('/verify-setup-2fa', data: {'verification_code': verificationCode});
      return response.statusCode == 200;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.translate('invalid_verification')!)),
      );
      return false;
    }
  }

  Future<Map<String, dynamic>> verify2FA(BuildContext context) async {
    try {
      final response = await _dio.get('/verify-2fa');
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception(AppLocalizations.of(context)!.translate('error_connecting')!);
      }
    } catch (e) {
      throw Exception(AppLocalizations.of(context)!.translate('an_unexpected')! + e.toString());
    }
  }

  Future<bool> verifyPassword(String password, BuildContext context) async {
    try {
      final response = await _dio.post('/verify-password', data: {'password': password});
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      Exception(AppLocalizations.of(context)!.translate('something_wrong')!);
      return false;
    }
  }

  Future<bool> disable2FA(BuildContext context) async {
    try {
      final response = await _dio.post('/disable-2fa');
      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception(AppLocalizations.of(context)!.translate('error_connecting')!);
      }
    } catch (e) {
      throw Exception(AppLocalizations.of(context)!.translate('an_unexpected')! + e.toString());
    }
  }
}