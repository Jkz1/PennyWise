import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:penny_wise/provider/wallet.dart';

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

          return {
            'totalIncome': totalIncome,
            'totalExpense': totalExpense,
            'balance': totalIncome - totalExpense,
            'incomeCategories': incomeByCategory,
            'expenseCategories': expenseByCategory,
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

// Default to the current month
final activeMonthProvider = StateProvider<DateTime>((ref) => DateTime.now());
