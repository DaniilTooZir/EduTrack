import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class Skeleton extends StatelessWidget {
  final double? height, width;
  final double borderRadius;

  const Skeleton({super.key, this.height, this.width, this.borderRadius = 12});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(borderRadius)),
      ),
    );
  }
}
