import 'package:flutter/material.dart';
import 'package:penny_wise/theme.dart';

class SheetLabel extends StatelessWidget {
  String text;
  bool isDarkMode;
  SheetLabel({super.key, required this.isDarkMode, required this.text});

  @override
  Widget build(BuildContext context) {
    final textColor = FinTrackTheme.getTextColor(isDarkMode);
    return Text(
      text,
      style: TextStyle(
        color: textColor.withOpacity(0.4),
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
    );
  }
}