import 'package:flutter/material.dart';

class SectionHeader extends StatefulWidget {
  String title;
  Color textColor;
  SectionHeader({super.key, required this.title,required this.textColor});

  @override
  State<SectionHeader> createState() => _SectionHeaderState();
}

class _SectionHeaderState extends State<SectionHeader> {
  @override
  Widget build(BuildContext context) {
    return Text(
      widget.title,
      style: TextStyle(
        color: widget.textColor.withOpacity(0.5),
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}