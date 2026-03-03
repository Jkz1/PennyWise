import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:penny_wise/provider/wallet.dart';

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
          final startOfRange = selectedDate.subtract(const Duration(days: 7));

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
  final view = ref.watch(chartViewProvider);
  final now = DateTime.now();

  return transactionsAsync.maybeWhen(
    data: (list) {
      if (list.isEmpty) return null;

      double totalSpendingYear = 0;
      Map<String, double> categoryMap = {};

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

          if (isExpense && date.year == now.year) {
            totalSpendingYear += amount;

            final String category = tx['category'] ?? 'Other';
            categoryMap[category] = (categoryMap[category] ?? 0) + amount;

            if (view == "Week") {
              activitySpending[date.weekday] =
                  (activitySpending[date.weekday] ?? 0) + amount;
            } else {
              activitySpending[date.month] =
                  (activitySpending[date.month] ?? 0) + amount;
            }
          }
        } catch (e) {
          continue;
        }
      }

      final int daysPassed =
          now.difference(DateTime(now.year, 1, 1)).inDays + 1;
      return {
        'total': totalSpendingYear,
        'avgDaily': totalSpendingYear / daysPassed,
        'categories': categoryMap.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value)),
        'activity': activitySpending,
      };
    },
    orElse: () => null,
  );
});
