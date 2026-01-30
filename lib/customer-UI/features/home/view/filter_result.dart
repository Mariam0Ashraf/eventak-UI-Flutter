import 'package:eventak/customer-UI/features/home/view/area_view.dart';

class FilterResult {
  final String? categoryId;
  final String? serviceTypeId;
  final double? minPrice;
  final double? maxPrice;
  final bool popular;

  // null => don't send
  final bool? includeServices;
  final bool? includePackages;

  final AreaNode? selectedCountry;
  final AreaNode? selectedGov;
  final AreaNode? selectedCity;
  final int? selectedAreaId;

  const FilterResult({
    required this.categoryId,
    required this.serviceTypeId,
    required this.minPrice,
    required this.maxPrice,
    required this.popular,
    required this.includeServices,
    required this.includePackages,
    required this.selectedCountry,
    required this.selectedGov,
    required this.selectedCity,
    required this.selectedAreaId,
  });
}
