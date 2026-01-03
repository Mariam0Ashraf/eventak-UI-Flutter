import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:eventak/core/constants/api_constants.dart';

class PackageDetailsService {
  Future<Map<String, dynamic>> getPackage(int id) async {
    final res = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/packages/$id'),
    );

    if (res.statusCode == 200) {
      return json.decode(res.body);
    } else {
      throw Exception('Failed to load package');
    }
  }
}
