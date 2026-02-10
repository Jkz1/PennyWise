import 'package:flutter/material.dart';
import '../theme.dart';

class NetWorthSummary extends StatelessWidget {
  final bool isDarkMode;
  final String totalBalance; // Renamed from totalAssets for clarity
  final String monthlyChange; // A nice "bonus" stat instead of debt

  const NetWorthSummary({
    super.key,
    required this.isDarkMode,
    required this.totalBalance,
    this.monthlyChange = "+2.4%", // Default mock data for now
  });

  @override
  Widget build(BuildContext context) {
    final textColor = FinTrackTheme.getTextColor(isDarkMode);
    final glassColor = FinTrackTheme.getGlassColor(isDarkMode);
    final glassBorder = FinTrackTheme.getGlassBorder(isDarkMode);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: glassColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "TOTAL BALANCE",
            style: TextStyle(
              color: textColor.withOpacity(0.4),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                totalBalance,
                style: TextStyle(
                  color: textColor,
                  fontSize: 32, // Made it bigger since it's the main star
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Monthly Trend Indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.lightGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.arrow_upward_rounded, size: 14, color: Colors.lightGreen),
                    const SizedBox(width: 4),
                    Text(
                      monthlyChange,
                      style: const TextStyle(
                        color: Colors.lightGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: textColor.withOpacity(0.05)),
          const SizedBox(height: 10),
          // A helpful summary tip instead of a ratio
          Row(
            children: [
              Icon(Icons.insights_rounded, color: FinTrackTheme.primaryColor, size: 16),
              const SizedBox(width: 8),
              Text(
                "You've saved \$450 more than last month",
                style: TextStyle(
                  color: textColor.withOpacity(0.5),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}