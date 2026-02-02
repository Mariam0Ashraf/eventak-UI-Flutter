import 'package:eventak/core/constants/app-colors.dart';
import 'package:flutter/material.dart';

class ServiceRow extends StatelessWidget {
  final String? imageUrl;
  final String title;
  final String date;
  final String time;

  const ServiceRow({
    required this.imageUrl,
    required this.title,
    required this.date,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: imageUrl != null
              ? Image.network(
                  imageUrl!,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                )
              : Container(
                  width: 60,
                  height: 60,
                  color: AppColor.lightGrey.withOpacity(0.3),
                  child: const Icon(Icons.image_not_supported),
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColor.blueFont,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$date • $time',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColor.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}