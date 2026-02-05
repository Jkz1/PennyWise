import 'package:flutter/material.dart';
import '../theme.dart';

class NetWorthCard extends StatelessWidget {
  final String totalBalance;
  final String monthlyIn;
  final String monthlyOut;
  final bool isDarkMode;

  const NetWorthCard({
    super.key,
    required this.totalBalance,
    required this.monthlyIn,
    required this.monthlyOut,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        // A subtle premium gradient
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode 
              ? [FinTrackTheme.deepIndigo, Colors.black]
              : [FinTrackTheme.primaryColor, FinTrackTheme.deepIndigo],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: FinTrackTheme.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "NET WORTH",
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            totalBalance,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // Monthly Flow Row
          Row(
            children: [
              _buildFlowItem(Icons.arrow_downward_rounded, "Income", monthlyIn, Colors.lightGreen),
              Container(height: 30, width: 1, color: Colors.white.withOpacity(0.1), margin: const EdgeInsets.symmetric(horizontal: 24)),
              _buildFlowItem(Icons.arrow_upward_rounded, "Expense", monthlyOut, Colors.orangeAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFlowItem(IconData icon, String label, String amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
          ],
        ),
        const SizedBox(height: 4),
        Text(amount, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }
}