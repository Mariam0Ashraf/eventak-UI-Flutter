import 'dart:developer';

import 'package:eventak/customer-UI/features/service_details/data/service_model.dart';
class PackageData {
  final int id;
  final String name;
  final String description;
  final String price;
  final int itemsCount;
  final List<PackageItem> items;
  final ServiceData provider;
  final double averageRating;
  final int reviewsCount;

  PackageData({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.itemsCount,
    required this.items,
    required this.provider,
    required this.averageRating,
    required this.reviewsCount,
  });

  factory PackageData.fromJson(Map<String, dynamic> json) {
    return PackageData(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'],
      itemsCount: json['items_count'],
      items: (json['items'] as List)
          .map((e) => PackageItem.fromJson(e))
          .toList(),
      provider: ServiceData.fromJson(json['provider']),
      averageRating: (json['average_rating'] as num).toDouble(),
      reviewsCount: json['reviews_count'],
    );
  }
}

class PackageItem {
  final int quantity;
  final ServiceData service;

  PackageItem({required this.quantity, required this.service});

  factory PackageItem.fromJson(Map<String, dynamic> json) {
    return PackageItem(
      quantity: json['quantity'],
      service: ServiceData.fromJson(json['service']),
    );
  }
}

