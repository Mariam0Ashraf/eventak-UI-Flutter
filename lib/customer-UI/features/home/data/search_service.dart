import 'dart:convert';
import 'package:eventak/core/constants/api_constants.dart';
import 'package:http/http.dart' as http;

class SearchService {
  static const List<String> _dummyData = [
    'Birthday Party',
    'Graduation Event',
    'Catering Service',
    'Photographer',
    'Venue Rental',
    'Decor Services',
    'Wedding Planner',
    'Wedding Photographer',
  ];

  Future<List<String>> search(String query) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}/search',
    ).replace(queryParameters: {'q': query});

    try {
      final response = await http.get(
        uri,
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

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
      }

      return _filterDummy(query);
    } catch (e) {
      return _filterDummy(query);
    }
  }

  List<String> _filterDummy(String query) {
    final lower = query.toLowerCase();
    return _dummyData
        .where((item) => item.toLowerCase().contains(lower))
        .toList();
  }
}
