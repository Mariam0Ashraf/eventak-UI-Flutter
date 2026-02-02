enum PackageItemType { service, package }

class PackageRequestModel {
  final String name; 
  final String description; 
  final double basePrice; 
  final int capacity; 
  final String priceUnit; 
  final bool fixedCapacity; 
  
  final String inventoryCount;
  final String minimumNoticeHours;
  final String minimumDurationHours;
  final String bufferTimeMinutes;

  final List<int> categoryIds; 
  final List<int> availableAreaIds; 
  final Map<String, dynamic> pricingConfig; 
  final List<PackageItemInput> items; 

  PackageRequestModel({
    required this.name,
    required this.description,
    required this.basePrice,
    required this.capacity,
    this.priceUnit = "package",
    required this.fixedCapacity,
    required this.inventoryCount,
    required this.minimumNoticeHours,
    required this.minimumDurationHours,
    required this.bufferTimeMinutes,
    required this.categoryIds,
    required this.availableAreaIds,
    required this.pricingConfig,
    required this.items,
  });

  Map<String, dynamic> toJson() => {
        "name": name,
        "description": description,
        "base_price": basePrice,
        "capacity": capacity,
        "price_unit": priceUnit,
        "fixed_capacity": fixedCapacity,
        "inventory_count": inventoryCount,
        "minimum_notice_hours": minimumNoticeHours,
        "minimum_duration_hours": minimumDurationHours,
        "buffer_time_minutes": bufferTimeMinutes,
        "category_ids": categoryIds,
        "available_area_ids": availableAreaIds,
        "pricing_config": pricingConfig,
        "items": items.map((i) => i.toJson()).toList(),
      };
}
class PackageItemInput {
  final int serviceId;
  final int quantity;

  PackageItemInput({required this.serviceId, required this.quantity});

  Map<String, dynamic> toJson() => {
        "service_id": serviceId,
        "quantity": quantity,
      };
}