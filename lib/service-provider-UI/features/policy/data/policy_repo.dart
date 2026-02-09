import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eventak/core/constants/api_constants.dart';

class CancellationPolicyRepo {
  final Dio _dio = Dio();

  Future<void> createCustomPolicy({
    required int itemId,
    required bool isPackage,
    required Map<String, dynamic> policyData,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token')?.replaceAll('"', '');

    final String type = isPackage ? 'packages' : 'services';
    final String url = '${ApiConstants.baseUrl}/cancellation-policies/$type/$itemId';

    await _dio.post(
      url,
      data: policyData,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ),
    );
  }
}