import 'package:flutter/material.dart';

class Backgroundblob extends StatelessWidget {
  double? top, bottom, left, right, height, width;
  Color color;
  bool isDarkMode;
  Backgroundblob({super.key, this.top, this.bottom, this.left, this.right, this.height, this.width, required this.color, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(isDarkMode ? 0.2 : 0.1),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(isDarkMode ? 0.2 : 0.1),
              blurRadius: 100,
              spreadRadius: 20,
            ),
          ],
        ),
      ),
    );
  }
}