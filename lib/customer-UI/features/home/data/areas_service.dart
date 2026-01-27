import 'dart:convert';
import 'package:eventak/core/constants/api_constants.dart';
import 'package:eventak/customer-UI/features/home/view/area_view.dart';
import 'package:http/http.dart' as http;

class AreasService {
  Future<List<AreaNode>> getAreasTree() async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/areas');
    final res = await http.get(uri, headers: {'Accept': 'application/json'});
    if (res.statusCode != 200) {
      throw Exception('Failed to load areas: ${res.statusCode}');
    }
    final decoded = jsonDecode(res.body);
    final data = decoded['data'] ?? decoded;
    return (data as List)
        .whereType<Map<String, dynamic>>()
        .map((e) => AreaNode.fromJson(e))
        .toList();
  }
}
