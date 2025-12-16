import 'dart:convert';
import 'package:eventak/core/constants/api_constants.dart';
import 'package:http/http.dart' as http;

class SearchService {
  Future<List<String>> search(String query) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}/search',
    ).replace(queryParameters: {'q': query});

    final response = await http.get(
      uri,
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      // أنا بافترض إن الـ response بالشكل ده مثلاً:
      // { "data": [ { "name": "...", "type": "...", ... }, ... ] }
      final List<dynamic> list = decoded['data'] ?? decoded;

      return list
          .map<String>((item) {
            if (item is Map<String, dynamic>) {
              return (item['name'] ?? item['title'] ?? item['label'] ?? '')
                  .toString();
            }
            return item.toString();
          })
          .where((name) => name.isNotEmpty)
          .toList();
    } else {
      throw Exception(
        'Search failed: ${response.statusCode} - ${response.body}',
      );
    }
  }
}
