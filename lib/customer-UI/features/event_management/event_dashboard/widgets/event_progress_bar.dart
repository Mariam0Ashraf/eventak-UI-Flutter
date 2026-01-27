import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';

class EventProgressBar extends StatelessWidget {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;
  
  const EventProgressBar({
    super.key,
    required this.progress,
    this.backgroundColor = const Color(0xffe0e0e0),
    this.progressColor = const Color(0xff1d7399),
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress / 100,
            minHeight: 12,
            backgroundColor: backgroundColor,
            valueColor: AlwaysStoppedAnimation(progressColor),
          ),
        ),
        Positioned.fill(
          child: Center(
            child: Text(
              "${progress.toStringAsFixed(0)}%",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColor.blueFont,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
