import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:penny_wise/components/smallToggle.dart';
import 'package:penny_wise/theme.dart';

class QuickStat extends StatefulWidget {
  final bool isDarkMode;
  const QuickStat({super.key, required this.isDarkMode});

  @override
  State<QuickStat> createState() => _QuickStatState();
}

class _QuickStatState extends State<QuickStat> {
  bool isWeekly = true;
  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setSheetState) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.65,
          decoration: BoxDecoration(
            color: widget.isDarkMode
                ? Colors.black.withOpacity(0.7)
                : Colors.white.withOpacity(0.8),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. HEADER & TOGGLE
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isWeekly ? "Weekly Snap" : "Monthly Snap",
                        style: TextStyle(
                          color: FinTrackTheme.getTextColor(widget.isDarkMode),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        isWeekly ? "Jan 12 - Jan 18" : "January 2024",
                        style: TextStyle(
                          color: FinTrackTheme.getTextColor(
                            widget.isDarkMode,
                          ).withOpacity(0.5),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  // The Timeframe Switcher
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: widget.isDarkMode
                          ? Colors.white.withOpacity(0.05)
                          : Colors.black.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        SmallToggle(
                          label: "Week",
                          isSelected: isWeekly,
                          isDarkMode: widget.isDarkMode,
                          onTap: () => setSheetState(() => isWeekly = true),
                        ),
                        SmallToggle(
                          label: "Month",
                          isSelected: !isWeekly,
                          isDarkMode: widget.isDarkMode,
                          onTap: () => setSheetState(() => isWeekly = false),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // 2. DYNAMIC PROGRESS BAR
              _buildStatLabel(
                isWeekly ? "WEEKLY BUDGET" : "MONTHLY BUDGET",
                FinTrackTheme.getTextColor(widget.isDarkMode),
              ),
              const SizedBox(height: 12),
              _buildProgressBar(
                context,
                isWeekly ? 0.65 : 0.42, // Mock percentages for Week vs Month
                isWeekly ? "\$650.00" : "\$2,100.00",
                isWeekly ? "\$1,000.00" : "\$5,000.00",
                widget.isDarkMode,
              ),

              const SizedBox(height: 40),

              // 3. DYNAMIC CATEGORIES
              _buildStatLabel(
                "TOP SPENDING",
                FinTrackTheme.getTextColor(widget.isDarkMode),
              ),
              const SizedBox(height: 16),
              if (isWeekly) ...[
                _buildQuickCategoryRow(
                  "Food",
                  "\$240.00",
                  Colors.orangeAccent,
                  FinTrackTheme.getTextColor(widget.isDarkMode),
                ),
                _buildQuickCategoryRow(
                  "Transport",
                  "\$120.00",
                  Colors.blueAccent,
                  FinTrackTheme.getTextColor(widget.isDarkMode),
                ),
              ] else ...[
                _buildQuickCategoryRow(
                  "Rent",
                  "\$1,200.00",
                  Colors.purpleAccent,
                  FinTrackTheme.getTextColor(widget.isDarkMode),
                ),
                _buildQuickCategoryRow(
                  "Groceries",
                  "\$450.00",
                  Colors.orangeAccent,
                  FinTrackTheme.getTextColor(widget.isDarkMode),
                ),
              ],

              const Spacer(),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: FinTrackTheme.primaryColor.withOpacity(0.1),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  "CLOSE",
                  style: TextStyle(
                    color: FinTrackTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // ... rest of the modal
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatLabel(String text, Color textColor) {
    return Text(
      text,
      style: TextStyle(
        color: textColor.withOpacity(0.4),
        fontSize: 10,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildQuickCategoryRow(
    String name,
    String amount,
    Color color,
    Color textColor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Text(
            name,
            style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          Text(
            amount,
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(
    BuildContext context,
    double percentage,
    String spentAmount,
    String limitAmount,
    bool isDarkMode,
  ) {
    final textColor = FinTrackTheme.getTextColor(isDarkMode);

    return Column(
      children: [
        Stack(
          children: [
            // 1. The Background Track
            Container(
              height: 12,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            // 2. The Active Progress Bar
            AnimatedContainer(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              height: 12,
              // Calculate width based on screen width and percentage
              width: (MediaQuery.of(context).size.width - 64) * percentage,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    FinTrackTheme.primaryColor,
                    FinTrackTheme.primaryColor.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: FinTrackTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // 3. Amount Labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "$spentAmount spent",
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Text(
              "Limit: $limitAmount",
              style: TextStyle(
                color: textColor.withOpacity(0.4),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
