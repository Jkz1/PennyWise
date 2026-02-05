import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // You'll need to add fl_chart to pubspec.yaml
import '../theme.dart';
// ... imports (make sure to include your theme and fl_chart)

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = FinTrackTheme.getTextColor(isDarkMode);

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
                _buildSmallIndexCard(
                  "Savings Rate",
                  "24%",
                  Icons.bolt_rounded,
                  Colors.tealAccent,
                  isDarkMode,
                ),
                const SizedBox(width: 16),
                _buildSmallIndexCard(
                  "Avg. Daily",
                  "\$42.50",
                  Icons.calendar_today_rounded,
                  Colors.orangeAccent,
                  isDarkMode,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // 2. THE MAIN CHART (Index of Trends)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              "Spending Trend",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildMainChartCard(isDarkMode),

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
          _buildDayActivityIndex(isDarkMode),

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
          _buildCategoryList(isDarkMode),

          const SizedBox(height: 120),
        ],
      ),
    );
  }

  // INDEX 1: Small Metric Cards
  Widget _buildSmallIndexCard(
    String label,
    String value,
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
              value,
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
  Widget _buildDayActivityIndex(bool isDarkMode) {
    final List<double> dayValues = [0.4, 0.7, 0.5, 0.9, 0.3, 0.8, 0.6];
    final List<String> days = ["M", "T", "W", "T", "F", "S", "S"];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (index) {
          return Column(
            children: [
              Container(
                width: 12,
                height: 80 * dayValues[index],
                decoration: BoxDecoration(
                  color: dayValues[index] > 0.8
                      ? FinTrackTheme.primaryColor
                      : FinTrackTheme.primaryColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                days[index],
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildCategoryList(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildCategoryProgressItem(
            "Food & Dining",
            "\$850",
            0.7,
            Colors.orangeAccent,
            isDarkMode,
          ),
          _buildCategoryProgressItem(
            "Shopping",
            "\$420",
            0.4,
            Colors.purpleAccent,
            isDarkMode,
          ),
          _buildCategoryProgressItem(
            "Transport",
            "\$150",
            0.2,
            Colors.blueAccent,
            isDarkMode,
          ),
          _buildCategoryProgressItem(
            "Health",
            "\$90",
            0.1,
            Colors.pinkAccent,
            isDarkMode,
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

  Widget _buildMainChartCard(bool isDarkMode) {
    final textColor = FinTrackTheme.getTextColor(isDarkMode);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
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
                    "\$2,450.00",
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
                    _buildChartToggle("Week", true, isDarkMode),
                    _buildChartToggle("Month", false, isDarkMode),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      const FlSpot(0, 2),
                      const FlSpot(1, 1.9),
                      const FlSpot(2, 3.5),
                      const FlSpot(3, 2.5),
                      const FlSpot(4, 4),
                      const FlSpot(5, 3),
                      const FlSpot(6, 5)
                    ],
                    isCurved: true,
                    color: FinTrackTheme.primaryColor,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          FinTrackTheme.primaryColor.withOpacity(0.2),
                          Colors.transparent,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartToggle(String label, bool isSelected, bool isDarkMode) {
    return Container(
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
    );
  }

  // ... (Other helper widgets for MainChart and CategoryList)
}
