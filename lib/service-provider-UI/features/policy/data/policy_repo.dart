import 'package:dio/dio.dart';
import 'package:eventak/service-provider-UI/features/policy/data/policy_model.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eventak/core/constants/api_constants.dart';

class CancellationPolicyRepo {
  final Dio _dio = Dio();

  Future<Options> getOptions() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token')?.replaceAll('"', '');
    return Options(
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
  }

  String _handleDioError(DioException e) {
    if (e.response != null && e.response!.data != null) {
      final data = e.response!.data;
      if (data is Map) {
        if (data['message'] != null) return data['message'].toString();
        if (data['error'] != null) return data['error'].toString();
        if (data['errors'] != null) return data['errors'].toString();
      }
    }
    return "An unexpected error occurred: ${e.message}";
  }

  Future<void> createCustomPolicy({
    required int itemId,
    required bool isPackage,
    required Map<String, dynamic> policyData,
  }) async {
    try {
      final String type = isPackage ? 'packages' : 'services';
      final String url = '${ApiConstants.baseUrl}/cancellation-policies/$type/$itemId';
      final options = await getOptions();
      await _dio.post(url, data: policyData, options: options);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> updateProviderPolicy(Map<String, dynamic> policyData) async {
    try {
      final options = await getOptions();
      final String url = '${ApiConstants.baseUrl}/cancellation-policies/provider';
      await _dio.post(url, data: policyData, options: options);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<CancellationPolicy?> getServicePolicy(int serviceId) async {
    try {
      final options = await getOptions();
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

  Future<CancellationPolicy?> getProviderPolicy() async {
    try {
      final options = await getOptions();
      final response = await _dio.get('${ApiConstants.baseUrl}/cancellation-policies/provider', options: options);
      if (response.data['success'] == true && response.data['data'] != null) {
        final data = response.data['data'];
        if (data['has_custom_policy'] == true) {
          return CancellationPolicy.fromJson(data['policy']);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> deleteServicePolicy(int serviceId) async {
    final options = await getOptions();
    await _dio.delete('${ApiConstants.baseUrl}/cancellation-policies/services/$serviceId', options: options);
  }

  Future<void> deleteProviderPolicy() async {
    final options = await getOptions();
    await _dio.delete('${ApiConstants.baseUrl}/cancellation-policies/provider', options: options);
  }
}