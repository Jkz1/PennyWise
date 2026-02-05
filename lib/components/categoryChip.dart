import 'package:flutter/material.dart';
import 'package:penny_wise/model/expenseCategory.dart';
import 'package:penny_wise/theme.dart';

class Categorychip extends StatelessWidget {
  CategoryItem selectedCategory;
  CategoryItem val;
  bool isDarkMode;
  Function(CategoryItem) onTap;
  Categorychip({super.key, 
    required this.selectedCategory,
    required this.val,
    required this.isDarkMode,
    required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected = selectedCategory == val;
    return GestureDetector(
      onTap: () {
        onTap(val);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 14 : 12,
          vertical: isSelected ? 8 : 6,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? FinTrackTheme.primaryColor
              : (isDarkMode
                    ? Colors.white.withOpacity(0.03)
                    : Colors.black.withOpacity(0.03)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? FinTrackTheme.primaryColor
                : Colors.white.withOpacity(0.05),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: isSelected ? 1.0 : 0.5,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                val.icon,
                size: isSelected ? 20 : 18,
                color: isSelected ? Colors.white : FinTrackTheme.primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                val.name,
                style: TextStyle(
                  fontSize: isSelected ? 15 : 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : (isDarkMode ? Colors.white70 : Colors.black54),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}