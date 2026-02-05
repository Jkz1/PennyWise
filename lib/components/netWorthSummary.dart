import 'package:flutter/material.dart';
import '../theme.dart';

class NetWorthSummary extends StatelessWidget {
  final bool isDarkMode;
  final String totalAssets;
  final String totalDebt;

  const NetWorthSummary({
    super.key,
    required this.isDarkMode,
    required this.totalAssets,
    required this.totalDebt,
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryColumn("TOTAL ASSETS", totalAssets, Colors.lightGreen, textColor),
              Container(width: 1, height: 40, color: textColor.withOpacity(0.1)),
              _buildSummaryColumn("TOTAL LIABILITIES", totalDebt, Colors.redAccent, textColor),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: textColor.withOpacity(0.05)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "EQUITY RATIO",
                style: TextStyle(
                  color: textColor.withOpacity(0.4),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                "92%",
                style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSummaryColumn(String label, String amount, Color color, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: textColor.withOpacity(0.4),
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: TextStyle(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}