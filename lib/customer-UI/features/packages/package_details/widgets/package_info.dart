import 'package:eventak/core/constants/app-colors.dart';
import 'package:flutter/material.dart';
import '../data/package_model.dart';

class PackageInfoSection extends StatelessWidget {
  final PackageData package;

  const PackageInfoSection({super.key, required this.package});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (package.description.isNotEmpty)
            Text(
              package.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),

          const SizedBox(height: 16),

          Row(
            children: [
              Text(
                "Rating:",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColor.blueFont,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.star, color: Colors.amber, size: 18),
              const SizedBox(width: 4),
              Text(
                package.averageRating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '(${package.reviewsCount} reviews)',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // --- Available Areas ---
          if (package.availableAreas.isNotEmpty) ...[
            Text(
              "Available in Areas:",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColor.blueFont,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: package.availableAreas.map((area) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blueGrey.withOpacity(0.15)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_on, size: 12, color: Colors.blueGrey[600]),
                      const SizedBox(width: 4),
                      Text(
                        area['name'] ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blueGrey[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],

          Text(
            "Package Categories:",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColor.blueFont,
            ),
          ),
          const SizedBox(height: 8),
          if (package.categories.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: package.categories
                  .map((cat) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColor.beige.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.grid_view_rounded, size: 14, color: AppColor.beige),
                            const SizedBox(width: 4),
                            Text(
                              cat,
                              style: TextStyle(
                                color: AppColor.blueFont,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            )
          else
            const Text("No categories provided", style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Colors.grey)),

          const SizedBox(height: 16),

          Row(
            children: [
              Icon(Icons.people_alt_outlined, size: 20, color: AppColor.blueFont),
              const SizedBox(width: 10),
              Text(
                "Capacity: ${package.capacity} Guests",
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 8),
              Text(
                "(${package.fixedCapacity ? 'Fixed' : 'Variable'})",
                style: TextStyle(fontSize: 12, color: package.fixedCapacity ? Colors.blue : Colors.orange),
              ),
            ],
          ),

          if (!package.fixedCapacity && package.pricingConfig != null) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              "Flexible Pricing Details:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 12),
            _buildPricingGrid(package.pricingConfig!),
            const SizedBox(height: 8),
          ],

          const SizedBox(height: 20),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F1F8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.payments_outlined, color: AppColor.primary, size: 20),
                const SizedBox(width: 12),
                Text(
                  package.price.toStringAsFixed(0),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColor.primary,
                  ),
                ),
                const SizedBox(width: 4),
                const Text("EGP", style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingGrid(PricingConfig config) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildConfigItem("Capacity Step", "${config.capacityStep} guests"),
        _buildConfigItem("Step Fee", "EGP ${config.stepFee}"),
        _buildConfigItem("Max Capacity", "${config.maxCapacity ?? 'N/A'}"),
        _buildConfigItem("Incl. Hours", "${config.includedHours} hrs"),
        _buildConfigItem("Max Duration", "${config.maxDuration ?? 'N/A'} hrs"),
        _buildConfigItem("Overtime Rate", "EGP ${config.overtimeRate}/hr"),
      ],
    );
  }

  Widget _buildConfigItem(String label, String value) {
    return SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}