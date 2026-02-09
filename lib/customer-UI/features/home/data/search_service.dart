import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:eventak/core/constants/api_constants.dart';
import 'package:eventak/customer-UI/features/home/data/search_result_model.dart';

class SearchService {
  Future<Map<String, dynamic>> search({
    required String query,
    String? categoryId,
    int? areaId,
    String? address,
    double? minPrice,
    double? maxPrice,
    String? filter, // popular, top_rated, ...
    String? serviceTypeId,

    bool? includeServices,
    bool? includePackages,

    String? eventDate, // YYYY-MM-DD
    String? startTime, // HH:MM
    String? endTime, // HH:MM

    int servicesPage = 1,
    int packagesPage = 1,
  }) async {
    final qp = <String, String>{
      if (query.trim().isNotEmpty) 'search': query.trim(),
      if (areaId != null) 'area_id': areaId.toString(),
      if (categoryId != null && categoryId.isNotEmpty)
        'category_ids[]': categoryId,
      if (address != null && address.trim().isNotEmpty)
        'address': address.trim(),
      if (minPrice != null) 'min_price': minPrice.toString(),
      if (maxPrice != null) 'max_price': maxPrice.toString(),
      if (filter != null && filter.isNotEmpty) 'filter': filter,

      //  Service Type
      if (serviceTypeId != null && serviceTypeId.isNotEmpty)
        'service_type': serviceTypeId,

      // send only when user changed
      if (includeServices != null)
        'include_services': includeServices.toString(),
      if (includePackages != null)
        'include_packages': includePackages.toString(),

      if (eventDate != null && eventDate.trim().isNotEmpty)
        'event_date': eventDate.trim(),
      if (startTime != null && startTime.trim().isNotEmpty)
        'start_time': startTime.trim(),
      if (endTime != null && endTime.trim().isNotEmpty)
        'end_time': endTime.trim(),

      'services_page': servicesPage.toString(),
      'packages_page': packagesPage.toString(),
    };

    final uri = Uri.parse(
      '${ApiConstants.baseUrl}/global-search',
    ).replace(queryParameters: qp);

    if (kDebugMode) debugPrint('Search Request URL: $uri');

    final response = await http.get(
      uri,
      headers: const {'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Search failed with status: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);

    final servicesData =
        decoded['data']?['services']?['data'] as List<dynamic>? ?? [];
    final servicesMeta = decoded['data']?['services']?['meta'] ?? {};

    final services = servicesData
        .whereType<Map>()
        .map(
          (s) => SearchResult.fromJson(
            Map<String, dynamic>.from(s),
            SearchResultType.service,
          ),
        )
        .toList();

    final packagesData =
        decoded['data']?['packages']?['data'] as List<dynamic>? ?? [];
    final packagesMeta = decoded['data']?['packages']?['meta'] ?? {};

    final packages = packagesData
        .whereType<Map>()
        .map(
          (p) => SearchResult.fromJson(
            Map<String, dynamic>.from(p),
            SearchResultType.package,
          ),
        )
        .toList();

    return {
      'services': services,
      'servicesMeta': servicesMeta,
      'packages': packages,
      'packagesMeta': packagesMeta,
    };
  }
}
