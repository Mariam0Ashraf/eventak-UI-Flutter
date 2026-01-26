import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';

class PrevPageButton extends StatelessWidget {
  final Color? color;
  final double size;

  const PrevPageButton({
    super.key,
    this.color,
    this.size = 22,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      icon: Icon(
        Icons.arrow_back,
        size: size,
      ),
      color: color ?? AppColor.primary,
      onPressed: () => Navigator.of(context).pop(),
    );
  }
}

