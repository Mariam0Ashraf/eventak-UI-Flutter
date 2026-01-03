import 'dart:convert';
import 'package:eventak/core/constants/api_constants.dart';
import 'package:eventak/customer-UI/features/home/data/search_result_model.dart';
import 'package:http/http.dart' as http;

class SearchService {
  Future<List<SearchResult>> search(String query) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}/global-search',
    ).replace(queryParameters: {
      'search': query,
    });

    final response = await http.get(
      uri,
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Search failed');
    }

    final decoded = jsonDecode(response.body);
    final List<SearchResult> results = [];

    // SERVICES
    final services =
        decoded['data']?['services']?['data'] as List<dynamic>? ?? [];

    for (final s in services) {
      results.add(
        SearchResult(
          id: s['id'],
          title: s['name'],
          description: s['description'],
          price: double.tryParse(s['base_price'] ?? ''),
          rating: (s['average_rating'] as num?)?.toDouble(),
          reviewsCount: s['reviews_count'],
          image: s['provider']?['avatar'],
          type: SearchResultType.service,
        ),
      );
    }

    // PACKAGES
    final packages =
        decoded['data']?['packages']?['data'] as List<dynamic>? ?? [];

    for (final p in packages) {
      results.add(
        SearchResult(
          id: p['id'],
          title: p['name'],
          description: p['description'],
          price: double.tryParse(p['price'] ?? ''),
          rating: (p['average_rating'] as num?)?.toDouble(),
          reviewsCount: p['reviews_count'],
          image: p['provider']?['avatar'],
          type: SearchResultType.package,
        ),
      );
    }

    return results;
  }
}
