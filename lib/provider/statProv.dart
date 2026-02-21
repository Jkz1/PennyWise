import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:penny_wise/provider/wallet.dart';

// Default to the current month
final activeMonthProvider = StateProvider<DateTime>((ref) => DateTime.now());
final chartViewProvider = StateProvider<String>((ref) => "Week");
final monthlyIncomeExpensesProvider =
    Provider.family<Map<String, dynamic>, DateTime>((ref, selectedDate) {
      final transactionsAsync = ref.watch(transactionHistory);

      return transactionsAsync.maybeWhen(
        data: (list) {
          final filteredItems = list.where((t) {
            final rawTimestamp = t['timestamp'];
            final date = DateFormat("HH:mm dd/MM/yyyy").parse(rawTimestamp);

            return date.month == selectedDate.month &&
                date.year == selectedDate.year;
          });

          double totalIncome = 0;
          double totalExpense = 0;

          // These maps will store category names as keys and their sums as values
          Map<String, double> incomeByCategory = {};
          Map<String, double> expenseByCategory = {};

          for (var item in filteredItems) {
            final amt = (item['amount'] as num).toDouble();
            final category = item['category'] ?? 'Other';

            if (item['isExpense'] == false) {
              totalIncome += amt;
              incomeByCategory[category] =
                  (incomeByCategory[category] ?? 0) + amt;
            } else {
              totalExpense += amt;
              expenseByCategory[category] =
                  (expenseByCategory[category] ?? 0) + amt;
            }
          }
          final sortedExpenses = Map.fromEntries(
            expenseByCategory.entries.toList()
              ..sort((e1, e2) => e2.value.compareTo(e1.value)),
          );
          final sortedIncome = Map.fromEntries(
            incomeByCategory.entries.toList()
              ..sort((e1, e2) => e2.value.compareTo(e1.value)),
          );
          return {
            'totalIncome': totalIncome,
            'totalExpense': totalExpense,
            'balance': totalIncome - totalExpense,
            'incomeCategories': sortedIncome,
            'expenseCategories': sortedExpenses,
          };
        },
        orElse: () => {
          'totalIncome': 0.0,
          'totalExpense': 0.0,
          'balance': 0.0,
          'incomeCategories': <String, double>{},
          'expenseCategories': <String, double>{},
        },
      );
    });

final weeklyIncomeExpensesProvider =
    Provider.family<Map<String, dynamic>, DateTime>((ref, selectedDate) {
      final transactionsAsync = ref.watch(transactionHistory);

      return transactionsAsync.maybeWhen(
        data: (list) {
          // 1. Define your date range
          // This gets the start of the day 7 days ago
          final startOfRange = selectedDate.subtract(const Duration(days: 7));
          // To ensure we include everything on the 'selectedDate' (today),
          // we set the end boundary to the very end of that day.
          final endOfRange = DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            23,
            59,
            59,
          );
          final filteredItems = list.where((t) {
            final rawTimestamp = t['timestamp'];
            final date = DateFormat("HH:mm dd/MM/yyyy").parse(rawTimestamp);
            // 2. Check if the date is within the last 7 days
            return date.isAfter(startOfRange) && date.isBefore(endOfRange);
          });

          double totalIncome = 0;
          double totalExpense = 0;
          Map<String, double> incomeByCategory = {};
          Map<String, double> expenseByCategory = {};

          for (var item in filteredItems) {
            final amt = (item['amount'] as num).toDouble();
            final category = item['category'] ?? 'Other';

            if (item['isExpense'] == false) {
              totalIncome += amt;
              incomeByCategory[category] =
                  (incomeByCategory[category] ?? 0) + amt;
            } else {
              totalExpense += amt;
              expenseByCategory[category] =
                  (expenseByCategory[category] ?? 0) + amt;
            }
          }
          final sortedExpenses = Map.fromEntries(
            expenseByCategory.entries.toList()
              ..sort((e1, e2) => e2.value.compareTo(e1.value)),
          );
          final sortedIncome = Map.fromEntries(
            incomeByCategory.entries.toList()
              ..sort((e1, e2) => e2.value.compareTo(e1.value)),
          );
          return {
            'totalIncome': totalIncome,
            'totalExpense': totalExpense,
            'balance': totalIncome - totalExpense,
            'incomeCategories': sortedIncome,
            'expenseCategories': sortedExpenses,
          };
        },

        orElse: () => {
          'totalIncome': 0.0,
          'totalExpense': 0.0,
          'balance': 0.0,
          'incomeCategories': <String, double>{},
          'expenseCategories': <String, double>{},
        },
      );
    });
final analyticsDataProvider = Provider((ref) {
  final transactionsAsync = ref.watch(transactionHistory);
  final view = ref.watch(chartViewProvider); // "Week" or "Month"
  final now = DateTime.now();

  return transactionsAsync.maybeWhen(
    data: (list) {
      if (list.isEmpty) return null;

      double totalSpendingYear = 0;
      Map<String, double> categoryMap = {};

      // Initialize the activity map based on the view
      // Week: 1-7 (Mon-Sun) | Month: 1-12 (Jan-Dec)
      Map<int, double> activitySpending = {};
      if (view == "Week") {
        for (int i = 1; i <= 7; i++) activitySpending[i] = 0;
      } else {
        for (int i = 1; i <= 12; i++) activitySpending[i] = 0;
      }

      for (var tx in list) {
        try {
          final DateTime date = DateFormat(
            'HH:mm dd/MM/yyyy',
          ).parse(tx['timestamp']);
          final double amount = (tx['amount'] ?? 0).toDouble();
          final bool isExpense = tx['isExpense'] ?? true;

          // 1. Only process if it's an expense AND within the current year
          if (isExpense && date.year == now.year) {
            totalSpendingYear += amount;

            // Category Aggregation (Yearly)
            final String category = tx['category'] ?? 'Other';
            categoryMap[category] = (categoryMap[category] ?? 0) + amount;

            // 2. Dynamic Activity Spending
            if (view == "Week") {
              // Only add to weekly chart if the transaction happened this week
              // (Optional: remove the 'isThisWeek' check if you want 'all-time' weekday averages)
              activitySpending[date.weekday] =
                  (activitySpending[date.weekday] ?? 0) + amount;
            } else {
              // Monthly view: Group by month (1 = Jan, 12 = Dec)
              activitySpending[date.month] =
                  (activitySpending[date.month] ?? 0) + amount;
            }
          }
        } catch (e) {
          continue; // Skip malformed dates
        }
      }
      // Calculate how many days have passed in the current year
      // .difference returns a Duration; we add 1 so we don't divide by zero on Jan 1st.
      final int daysPassed =
          now.difference(DateTime(now.year, 1, 1)).inDays + 1;
      return {
        'total': totalSpendingYear, // Total for the current year
        'avgDaily': totalSpendingYear / daysPassed,
        'categories': categoryMap.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value)),
        'activity': activitySpending, // Renamed from 'daily' for clarity
      };
    },
    orElse: () => null,
  );
});
