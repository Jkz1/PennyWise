import 'package:flutter/material.dart';
import 'package:penny_wise/theme.dart';

class QuickActions extends StatefulWidget {
  bool isDarkMode;
  Color textColor;
  List<dynamic> actionsList;
  QuickActions({super.key, required this.isDarkMode, required this.textColor, required this.actionsList});

  @override
  State<QuickActions> createState() => _QuickActionsState();
}

class _QuickActionsState extends State<QuickActions> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: widget.actionsList.map((action) {
        return GestureDetector(
          onTap: action['onTap'] != null ? action['onTap'] as void Function()? : null,
          child: Column(
            children: [
              Container(
                width: 85,
                height: 65,
                decoration: BoxDecoration(
                  color: widget.isDarkMode
                      ? Colors.white.withOpacity(0.05)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: widget.isDarkMode
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.05),
                  ),
                  boxShadow: [
                    if (!widget.isDarkMode)
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: Icon(
                  action['icon'],
                  color: FinTrackTheme.primaryColor,
                  size: 28,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                action['label'],
                style: TextStyle(
                  color: widget.textColor.withOpacity(0.7),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );;
  }
}