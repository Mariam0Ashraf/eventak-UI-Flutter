import 'package:dio/dio.dart';
import 'package:eventak/service-provider-UI/features/policy/data/policy_model.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eventak/core/constants/api_constants.dart';

class CancellationPolicyRepo {
  final Dio _dio = Dio();

  Future<Options> _getOptions() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token')?.replaceAll('"', '');
    return Options(
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
  }

  Future<void> createCustomPolicy({
    required int itemId,
    required bool isPackage,
    required Map<String, dynamic> policyData,
  }) async {
    final String type = isPackage ? 'packages' : 'services';
    final String url = '${ApiConstants.baseUrl}/cancellation-policies/$type/$itemId';
    final options = await _getOptions();

    await _dio.post(url, data: policyData, options: options);
  }

  Future<CancellationPolicy?> getServicePolicy(int serviceId) async {
    try {
      final options = await _getOptions();
      final response = await _dio.get(
        '${ApiConstants.baseUrl}/cancellation-policies/services/$serviceId',
        options: options,
      );
      
      if (response.data['success'] == true && response.data['data'] != null) {
        final data = response.data['data'];
        
        if (data['has_custom_policy'] == true && data['policy'] != null) {
          return CancellationPolicy.fromJson(data['policy']);
        }
      }
      return null; 
    } catch (e) {
      debugPrint("Error fetching policy: $e");
      return null; 
    }
  }
  Future<void> updateCustomPolicy({
  required int itemId,
  required bool isPackage,
  required Map<String, dynamic> policyData,
}) async {
  final options = await _getOptions();
  final String type = isPackage ? 'packages' : 'services';
  
  final String url = '${ApiConstants.baseUrl}/cancellation-policies/$type/$itemId';

  await _dio.put(
    url,
    data: policyData,
    options: options,
  );
}
Future<void> deleteServicePolicy(int serviceId) async {
  final options = await _getOptions(); 
  final url = '${ApiConstants.baseUrl}/cancellation-policies/services/$serviceId';

  await _dio.delete(
    url,
    options: options,
  );
}
}