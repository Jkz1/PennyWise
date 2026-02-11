import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final _formatter = NumberFormat.currency(
    locale: "en_US",
    symbol: "\$",
    decimalDigits: 2,
  );

  static String format(dynamic amount) {
    return _formatter.format(amount ?? 0);
  }

  // Optional: A version for compact numbers (e.g., 1.2K instead of 1,200)
  // static String formatCompact(dynamic amount) {
  //   return NumberFormat.compactCurrency(
  //     symbol: "\$",
  //     locale: "en_US",
  //   ).format(amount ?? 0);
  // }
  static double getCleanAmount(String formattedValue) {
    // 1. Remove everything that isn't a digit (0-9)
    String digitsOnly = formattedValue.replaceAll(RegExp(r'[^0-9]'), '');

    if (digitsOnly.isEmpty) return 0.0;

    // 2. Convert to double and shift decimal (since our formatter treats 100 as 1.00)
    return double.parse(digitsOnly) / 100;
  }
}

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    // Clean the input (remove non-numeric characters)
    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // Parse to double (e.g., 100 becomes 1.00)
    double value = double.parse(newText) / 100;

    // Use the intl formatter
    String formattedText = CurrencyFormatter.format(value);

    return newValue.copyWith(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
