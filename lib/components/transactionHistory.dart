import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:penny_wise/theme.dart';
import 'package:penny_wise/utils/formatters.dart';
import 'package:penny_wise/utils/relativesDate.dart';

class HistoryItem extends StatelessWidget {
  Map<String, dynamic> item;
  Color textColor;
  Color glassColor;
  Color glassBorder;
  HistoryItem({super.key, required this.item, required this.textColor, required this.glassColor, required this.glassBorder});

  @override
  Widget build(BuildContext context) {
    // 1. Convert Timestamp to formatted String
    final dynamic timestamp = item['timestamp'];
    // Default to now
    DateTime formattedDate = DateFormat('HH:mm dd/MM/yyyy').parse(timestamp);
    final textDate = getRelativeDate(formattedDate);
    final bool isExpense = item['isExpense'] ?? true;
    final Color statusColor = isExpense ? Colors.redAccent : FinTrackTheme.primaryColor;
    return Container(
      margin: const EdgeInsets.only(bottom: 8), // SLIM: Reduced from 12 to 8
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ), // SLIM: Tighter internal padding
      decoration: BoxDecoration(
        color: glassColor,
        borderRadius: BorderRadius.circular(16), // SLIM: Reduced from 24 to 16
        border: Border.all(color: glassBorder),
      ),
      child: Row(
        children: [
          // SLIMMER Icon Container
          Container(
            width: 40, // SLIM: Reduced from 50
            height: 40, // SLIM: Reduced from 50
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12), // SLIM: Reduced from 16
            ),
            child: Icon(
              isExpense
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              color: statusColor,
              size: 20, // SLIM: Smaller icon
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'] ?? "Untitled",
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ), // SLIM: Font size 14
                ),
                const SizedBox(height: 2),
                Text(
                  "${item['category']} • ${item['walletName']}",
                  style: TextStyle(
                    color: textColor.withOpacity(0.4),
                    fontSize: 11,
                  ), // SLIM: Font size 11
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${isExpense ? '-' : '+'} ${CurrencyFormatter.format(item['amount'])}",
                style: TextStyle(
                  color: isExpense ? textColor : statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14, // SLIM: Font size 14
                ),
              ),
              const SizedBox(height: 2),
              Text(
                textDate, // Update with item['date'] when available
                style: TextStyle(
                  color: textColor.withOpacity(0.3),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}