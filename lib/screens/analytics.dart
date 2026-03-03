import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:penny_wise/model/expenseCategory.dart';
import 'package:penny_wise/provider/statProv.dart';
import 'package:penny_wise/utils/formatters.dart';
import '../theme.dart';

class AnalyticsPage extends ConsumerStatefulWidget {
  const AnalyticsPage({super.key});

  @override
  ConsumerState<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends ConsumerState<AnalyticsPage> {
  int? _selectedBarIndex; // null means no bar is clicked
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = FinTrackTheme.getTextColor(isDarkMode);
    final analytics = ref.watch(analyticsDataProvider);
    if (analytics == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 60),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? Colors.white.withOpacity(0.05)
                        : Colors.black.withOpacity(0.03),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.receipt_long_rounded,
                    size: 64,
                    color: textColor.withOpacity(0.2),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "No Transactions Yet",
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Start adding expenses to see your analytics here.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor.withOpacity(0.4),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    final categories =
        analytics['categories'] as List<MapEntry<String, double>>;
    final daily = analytics['activity'] as Map<int, double>;
    final double total = analytics['total'] as double;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
            child: Text(
              "Analytics",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),

          // 1. QUICK INDEX ROW (New Section)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                const SizedBox(width: 16),
                _buildSmallIndexCard(
                  "Avg. Daily",
                  analytics['avgDaily'],
                  Icons.calendar_today_rounded,
                  Colors.orangeAccent,
                  isDarkMode,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // 2. THE MAIN CHART (Index of Trends)
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 24),
          //   child: Text(
          //     "Spending Trend",
          //     style: TextStyle(
          //       fontSize: 18,
          //       fontWeight: FontWeight.bold,
          //       color: textColor,
          //     ),
          //   ),
          // ),
          // const SizedBox(height: 16),
          // _buildMainChartCard(isDarkMode, total, analytics['spots'] as List<FlSpot>, view),
          const SizedBox(height: 32),

          // 3. SPENDING BY DAY INDEX (New Section)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              "Activity by Day",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildDayActivityIndex(
            isDarkMode,
            daily,
            total,
            ref.watch(chartViewProvider),
          ),

          const SizedBox(height: 32),

          // 4. CATEGORY BREAKDOWN
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              "Top Categories",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: categories.map((cat) {
                return _buildCategoryProgressItem(
                  cat.key,
                  CurrencyFormatter.format(cat.value),
                  cat.value / total, // Progress ratio
                  categories_expenses
                      .firstWhere((e) => e.name == cat.key)
                      .color, // Use your existing model here
                  isDarkMode,
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 120),
        ],
      ),
    );
  }

  // INDEX 1: Small Metric Cards
  Widget _buildSmallIndexCard(
    String label,
    dynamic value,
    IconData icon,
    Color color,
    bool isDarkMode,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDarkMode
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.03),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 12),
            Text(
              CurrencyFormatter.format(value),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: FinTrackTheme.getTextColor(isDarkMode),
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: FinTrackTheme.getTextColor(isDarkMode).withOpacity(0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // INDEX 2: Activity Bars (Mon-Sun)
  Widget _buildDayActivityIndex(
    bool isDarkMode,
    Map<int, double> dailyData,
    dynamic total,
    String currentView,
  ) {
    final textColor = FinTrackTheme.getTextColor(isDarkMode);
    final numberOfDays = currentView == "Week" ? 7 : 12;
    double maxVal = dailyData.values.fold(0, (p, c) => c > p ? c : p);
    if (maxVal == 0) maxVal = 1;

    final List<String> days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    final List<String> monthDays = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    print(dailyData);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Total Spending",
                    style: TextStyle(
                      color: textColor.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    CurrencyFormatter.format(total),
                    style: TextStyle(
                      color: textColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              // View Toggle
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.white10 : Colors.black12,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    _buildChartToggle(
                      "Week",
                      currentView == "Week",
                      isDarkMode,
                    ),
                    _buildChartToggle(
                      "Month",
                      currentView == "Month",
                      isDarkMode,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: MediaQuery.of(context).size.width - 100,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(numberOfDays, (index) {
                  final value = dailyData[index + 1] ?? 0;
                  final ratio = value / maxVal;
                  return Container(
                    width: 45,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        setState(() {
                          setState(() {
                            if (_selectedBarIndex == index) {
                              _selectedBarIndex = null; // Toggle off
                            } else {
                              _selectedBarIndex = index; // Select new
                            }
                          });
                        });
                      },
                      child: Column(
                        children: [
                          SizedBox(
                            height: 80 * (1 - ratio),
                          ), // Extra space for tooltip
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: _selectedBarIndex == index ? 1.0 : 0.0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              margin: const EdgeInsets.only(bottom: 4),
                              decoration: BoxDecoration(
                                color: FinTrackTheme.primaryColor,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                "\$${value.toStringAsFixed(0)}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 12,
                            height: 80 * ratio,
                            decoration: BoxDecoration(
                              color: dailyData[index + 1]! > 0.8
                                  ? FinTrackTheme.primaryColor
                                  : FinTrackTheme.primaryColor.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            currentView == "Week"
                                ? days[index]
                                : monthDays[index],
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryProgressItem(
    String title,
    String amount,
    double progress,
    Color color,
    bool isDarkMode,
  ) {
    final textColor = FinTrackTheme.getTextColor(isDarkMode);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.white.withOpacity(0.04)
            : Colors.black.withOpacity(0.02),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.02)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.circle, color: color, size: 8),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const Spacer(),
              Text(
                amount,
                style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Stack(
            children: [
              // Background track
              Container(
                height: 8,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.white10 : Colors.black12,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              // Progress fill
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withOpacity(0.5)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildChartToggle(String label, bool isSelected, bool isDarkMode) {
    return GestureDetector(
      onTap: () => ref.read(chartViewProvider.notifier).state = label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDarkMode ? Colors.white12 : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? FinTrackTheme.primaryColor : Colors.grey,
          ),
        ),
      ),
    );
  }
}
