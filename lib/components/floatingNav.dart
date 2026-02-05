import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme.dart';

class FloatingNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final bool isDarkMode;

  const FloatingNav({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final glassBorder = FinTrackTheme.getGlassBorder(isDarkMode);

    return Positioned(
      bottom: 30,
      left: 20,
      right: 20,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.black.withOpacity(0.4)
                  : Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: glassBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home_rounded, 0),
                _buildNavItem(Icons.account_balance_wallet_rounded, 1),
                _buildNavItem(Icons.analytics_rounded, 2),
                _buildNavItem(Icons.person_rounded, 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    bool isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () => onItemSelected(index),
      child: Icon(
        icon,
        color: isSelected 
            ? FinTrackTheme.primaryColor 
            : (isDarkMode ? Colors.white38 : Colors.black38),
        size: isSelected ? 28 : 24,
      ),
    );
  }
}