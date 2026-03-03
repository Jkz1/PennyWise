import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:penny_wise/components/smallToggle.dart';
import 'package:penny_wise/model/expenseCategory.dart';
import 'package:penny_wise/provider/statProv.dart';
import 'package:penny_wise/theme.dart';
import 'package:penny_wise/utils/formatters.dart';

class QuickStat extends ConsumerStatefulWidget {
  final bool isDarkMode;
  const QuickStat({super.key, required this.isDarkMode});

  @override
  ConsumerState<QuickStat> createState() => _QuickStatState();
}

class _QuickStatState extends ConsumerState<QuickStat> {
  bool isWeekly = false;
  Color _getCategoryColor(String categoryName) {
    final category = categories_expenses.firstWhere(
      (c) => c.name == categoryName,
      orElse: () => categories_income.firstWhere(
        (c) => c.name == categoryName,
        orElse: () => CategoryItem("Other", Icons.more_horiz, Colors.grey),
      ),
    );
    return category.color;
  }

  @override
  Widget build(BuildContext context) {
    final textColor = FinTrackTheme.getTextColor(widget.isDarkMode);
    // 1. Watch the stats for the current month
    final now = DateTime.now();
    final monthlyStats = ref.watch(monthlyIncomeExpensesProvider(now));
    final weeklyStats = ref.watch(weeklyIncomeExpensesProvider(now));
    double income = isWeekly
        ? weeklyStats['totalIncome'] ?? 0.0
        : monthlyStats['totalIncome'] ?? 0.0;
    double expense = isWeekly
        ? weeklyStats['totalExpense'] ?? 0.0
        : monthlyStats['totalExpense'] ?? 0.0;
    Map<String, double> categories = isWeekly
        ? weeklyStats['expenseCategories'] ?? {}
        : monthlyStats['expenseCategories'] ?? {};
    // 2. Calculate Burn Rate (Expense as a % of Income)
    // If income is 0, we set to 1.0 to show a "full" warning bar if there are expenses
    double burnRate = income > 0
        ? (expense / income).clamp(0.0, 1.0)
        : (expense > 0 ? 1.0 : 0.0);
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
                        isWeekly ? "Current Week" : "Current Month",
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
                          onTap: () => setSheetState(() {
                            final tes = ref.watch(
                              weeklyIncomeExpensesProvider(now),
                            );
                            
                            print("Toggle");
                            print(tes);
                            
                            
                            isWeekly = true;
                            income = isWeekly
                                ? weeklyStats['totalIncome'] ?? 0.0
                                : monthlyStats['totalIncome'] ?? 0.0;
                            expense = isWeekly
                                ? weeklyStats['totalExpense'] ?? 0.0
                                : monthlyStats['totalExpense'] ?? 0.0;
                            categories = isWeekly
                                ? weeklyStats['expenseCategories'] ?? {}
                                : monthlyStats['expenseCategories'] ?? {};
                          }),
                        ),
                        SmallToggle(
                          label: "Month",
                          isSelected: !isWeekly,
                          isDarkMode: widget.isDarkMode,
                          onTap: () => setSheetState(() {
                            final tes = ref.watch(
                              monthlyIncomeExpensesProvider(now),
                            );
                            print("Toggle");
                            print(tes);
                            
                            isWeekly = false;
                            income = isWeekly
                                ? weeklyStats['totalIncome'] ?? 0.0
                                : monthlyStats['totalIncome'] ?? 0.0;
                            expense = isWeekly
                                ? weeklyStats['totalExpense'] ?? 0.0
                                : monthlyStats['totalExpense'] ?? 0.0;
                            categories = isWeekly
                                ? weeklyStats['expenseCategories'] ?? {}
                                : monthlyStats['expenseCategories'] ?? {};
                          }),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // 2. DYNAMIC PROGRESS BAR
              _buildStatLabel(
                isWeekly ? "WEEKLY CASHFLOW" : "MONTHLY CASHFLOW",
                FinTrackTheme.getTextColor(widget.isDarkMode),
              ),
              const SizedBox(height: 12),
              _buildProgressBar(
                context,
                // isWeekly ? 0.65 : 0.42, // Mock percentages for Week vs Month
                burnRate,
                CurrencyFormatter.format(expense),
                CurrencyFormatter.format(income),
                // isWeekly ? "\$650.00" : "\$2,100.00",
                // isWeekly ? "\$1,000.00" : "\$5,000.00",
                widget.isDarkMode,
              ),

              const SizedBox(height: 40),

              // 3. DYNAMIC CATEGORIES
              // _buildStatLabel(
              //   "TOP SPENDING",
              //   FinTrackTheme.getTextColor(widget.isDarkMode),
              // ),
              _buildStatLabel("TOP SPENDING", textColor),
              const SizedBox(height: 16),

              if (categories.isEmpty)
                Text(
                  "No transactions yet",
                  style: TextStyle(color: textColor.withOpacity(0.3)),
                )
              else
                ...categories.entries.take(3).map((entry) {
                  return _buildQuickCategoryRow(
                    entry.key,
                    CurrencyFormatter.format(entry.value),
                    _getCategoryColor(entry.key), // Helper to pick a color
                    textColor,
                  );
                }),
              const SizedBox(height: 16),

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
    String spent,
    String income,
    bool isDark,
  ) {
    final textColor = FinTrackTheme.getTextColor(isDark);
    return Column(
      children: [
        Stack(
          children: [
            Container(
              height: 12,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 800),
              height: 12,
              width: (MediaQuery.of(context).size.width - 64) * percentage,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    percentage > 0.8
                        ? Colors.redAccent
                        : FinTrackTheme.primaryColor,
                    FinTrackTheme.primaryColor.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "$spent spent",
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            Text(
              "Income: $income",
              style: TextStyle(color: textColor.withOpacity(0.4), fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }
}
