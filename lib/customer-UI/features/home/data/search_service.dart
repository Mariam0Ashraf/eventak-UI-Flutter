import 'dart:convert';
import 'package:eventak/core/constants/api_constants.dart';
import 'package:eventak/customer-UI/features/home/data/search_result_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class SearchService {
  Future<Map<String, dynamic>> search({
    required String query,
    String? category, // This is the ID passed from the checkbox
    String? location,
    double? minPrice,
    double? maxPrice,
    bool? popular,
    String? type,
    int servicesPage = 1,
    int packagesPage = 1,
  }) async {
    final queryParams = {
      'search': query,
      
      if (category != null) 'category_id': category, 
      if (location != null) 'location': location,
      if (minPrice != null) 'min_price': minPrice.toString(),
      if (maxPrice != null) 'max_price': maxPrice.toString(),
      if (popular != null && popular) 'filter': 'popular',
      'services_page': servicesPage.toString(),
      'packages_page': packagesPage.toString(),
    };

    final uri = Uri.parse('${ApiConstants.baseUrl}/global-search')
        .replace(queryParameters: queryParams);

    debugPrint('Search Request URL: $uri');

    final response = await http.get(uri, headers: {'Accept': 'application/json'});

    if (response.statusCode != 200) {
      throw Exception('Search failed with status: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);

    final servicesData = decoded['data']?['services']?['data'] as List<dynamic>? ?? [];
    final servicesMeta = decoded['data']?['services']?['meta'] ?? {};
    final services = servicesData
        .map((s) => SearchResult.fromJson(s, SearchResultType.service))
        .toList();

    final packagesData = decoded['data']?['packages']?['data'] as List<dynamic>? ?? [];
    final packagesMeta = decoded['data']?['packages']?['meta'] ?? {};
    final packages = packagesData
        .map((p) => SearchResult.fromJson(p, SearchResultType.package))
        .toList();

    return {
      'services': services,
      'servicesMeta': servicesMeta,
      'packages': packages,
      'packagesMeta': packagesMeta,
    };
  }
}