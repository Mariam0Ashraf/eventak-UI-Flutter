import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:eventak/core/constants/api_constants.dart';
import 'package:eventak/customer-UI/features/packages/package_details/data/package_model.dart';

class ListPackagesService {
  
  int lastPage = 1;

  
  Future<List<PackageData>> fetchPackages({required int page}) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}/packages?page=$page',
    );

    final res = await http.get(uri);

    if (res.statusCode == 200) {
      final decoded = json.decode(res.body);

      
      lastPage = decoded['meta']['last_page'];

      final List list = decoded['data'];

      return list
          .map((json) => PackageData.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load packages');
    }
  }
}
