
import 'package:dio/dio.dart';
import 'DioHelper.dart';

class TwoFactorAuthService {
  final Dio _dio = DioHelper().dio;

  Future<Map<String, dynamic>> setup2FA() async {
    try {
      final response = await _dio.get('/setup-2FA');
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to initiate 2FA setup');
      }
    } catch (e) {
      throw Exception('Error during 2FA setup: $e');
    }
  }

  Future<Map<String, dynamic>> verify2FA() async {
    try {
      final response = await _dio.get('/verify-2FA');
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to initiate 2FA setup');
      }
    } catch (e) {
      throw Exception('Error during 2FA setup: $e');
    }
  }
  Future<bool> verifyPassword(String password) async {
    try {
      final response = await _dio.post('/verify-password', data: {'password': password});
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {

      print('Error verifying password: $e');
      return false;
    }
  }

  Future<bool> disable2FA() async {
    try {
      final response = await _dio.post('/disable-2FA');
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      throw Exception('Error during disabling 2FA: $e');
    }
  }
}
