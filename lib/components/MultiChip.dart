import 'package:flutter/material.dart';
import 'package:penny_wise/model/expenseCategory.dart';
import 'package:penny_wise/theme.dart';

class MultiChip extends StatelessWidget {
  final List<String> selectedCategories; // Changed to List for multi-select
  final CategoryItem val;
  final bool isDarkMode;
  final Function(CategoryItem) onTap;

  const MultiChip({
    super.key,
    required this.selectedCategories,
    required this.val,
    required this.isDarkMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Check if this specific chip's name is in our active filter list
    final bool isSelected = selectedCategories.contains(val.name);

    return GestureDetector(
      onTap: () => onTap(val),
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
                  ? Colors.white.withOpacity(0.05) // Slightly more visible
                  : Colors.black.withOpacity(0.03)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? FinTrackTheme.primaryColor
                : Colors.white.withOpacity(0.1),
            width: isSelected ? 1.5 : 1, // Slimmer border for "less fat" look
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              val.icon,
              size: isSelected ? 18 : 16, // Scaled down for sleekness
              color: isSelected ? Colors.white : (isDarkMode ? Colors.white54 : FinTrackTheme.primaryColor),
            ),
            const SizedBox(width: 8),
            Text(
              val.name,
              style: TextStyle(
                fontSize: isSelected ? 13 : 13, // Uniform size for cleaner grid
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : (isDarkMode ? Colors.white70 : Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }
}