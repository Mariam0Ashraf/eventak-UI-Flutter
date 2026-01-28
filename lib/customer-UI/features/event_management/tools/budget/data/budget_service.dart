import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eventak/core/constants/api_constants.dart';
import 'budget_model.dart';

class BudgetService {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token')?.replaceAll('"', '');
  }

  Future<List<BudgetItem>> fetchBudget(int eventId) async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/events/$eventId/budget'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = jsonDecode(response.body);
      final List<dynamic> items = decoded['data']['budget_items'];
      return items.map((item) => BudgetItem.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load budget');
    }
  }

  Future<bool> deleteBudgetItem(int eventId, int itemId) async {
    final token = await _getToken();
    final response = await http.delete(
      Uri.parse('${ApiConstants.baseUrl}/events/$eventId/budget/$itemId'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return response.statusCode == 200;
  }
  Future<bool> createBudgetItem(int eventId, Map<String, dynamic> data) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/events/$eventId/budget'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
    return response.statusCode == 201 || response.statusCode == 200;
  }

  Future<bool> updateBudgetItem(int eventId, int itemId, Map<String, dynamic> data) async {
    final token = await _getToken();
    final response = await http.put(
      Uri.parse('${ApiConstants.baseUrl}/events/$eventId/budget/$itemId'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
    return response.statusCode == 200;
  }
  Future<bool> recordPayment(int eventId, int itemId, double amount) async {
  final token = await _getToken();
  final response = await http.post(
    Uri.parse('${ApiConstants.baseUrl}/events/$eventId/budget/$itemId/record-payment'),
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({"amount": amount}),
  );
  return response.statusCode == 200;
}
  Future<Map<String, dynamic>> fetchBudgetSummary(int eventId) async {
  final token = await _getToken();
  final response = await http.get(
    Uri.parse('${ApiConstants.baseUrl}/events/$eventId/budget/summary'),
    headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body)['data'];
  } else {
    throw Exception('Failed to load budget summary');
  }
}
}