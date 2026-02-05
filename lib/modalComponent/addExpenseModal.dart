// ignore_for_file: unused_element

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:penny_wise/components/categoryChip.dart';
import 'package:penny_wise/components/sheetLabel.dart';
import 'package:penny_wise/model/expenseCategory.dart';
import 'package:penny_wise/theme.dart';

class ExpenseModal extends StatefulWidget {
  final bool isDarkMode;
  const ExpenseModal({super.key, required this.isDarkMode});

  @override
  State<ExpenseModal> createState() => _ExpenseModalState();
}

class _ExpenseModalState extends State<ExpenseModal> {
  CategoryItem isSelected = categories_expenses[0];
  bool isExpense = true;
  @override
  Widget build(BuildContext context) {
    final textColor = FinTrackTheme.getTextColor(widget.isDarkMode);
    onTapCategory(CategoryItem category) {
      setState(() {
        isSelected = category;
      });
    }

    onTapChangeSheet(bool val) {
      setState(() {
        isExpense = val;
        if (categories_expenses.contains(isSelected) && !isExpense) {
          isSelected = categories_income[0];
        } else if (categories_income.contains(isSelected) && isExpense) {
          isSelected = categories_expenses[0];
        }
      });
    }

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setSheetState) =>
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              // 1. REDUCED HEIGHT: Matches QuickStat (0.65)
              height: MediaQuery.of(context).size.height * 0.65,
              decoration: BoxDecoration(
                color: widget.isDarkMode
                    ? Colors.black.withOpacity(
                        0.7,
                      ) // Darker background for contrast
                    : Colors.white.withOpacity(0.8),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(40),
                ),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 24,
              ), // Tighter padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. HANDLE BAR
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: textColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 3. COMPACT TOGGLE (Matches PlannedModal style)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "New Transaction",
                        style: TextStyle(
                          color: textColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
                            _buildCompactToggle(
                              "Expense",
                              isExpense,
                              () => setSheetState(() => onTapChangeSheet(true)),
                            ),
                            _buildCompactToggle(
                              "Income",
                              !isExpense,
                              () =>
                                  setSheetState(() => onTapChangeSheet(false)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // 4. AMOUNT INPUT (Smaller & Cleaner)
                  Center(
                    child: TextField(
                      autofocus: true,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: FinTrackTheme.primaryColor,
                        fontSize: 40, // Reduced from 48
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        prefixText: isExpense ? "- \$ " : "+ \$ ",
                        prefixStyle: TextStyle(
                          color: textColor.withOpacity(0.5),
                          fontSize: 28, // Reduced from 32
                        ),
                        border: InputBorder.none,
                        hintText: "0.00",
                        hintStyle: TextStyle(color: textColor.withOpacity(0.1)),
                        isDense: true, // Removes extra vertical padding
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24), // Reduced from 40

                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SheetLabel(
                            isDarkMode: widget.isDarkMode,
                            text: "CATEGORY",
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: isExpense
                                ? categories_expenses
                                      .map(
                                        (c) => Categorychip(
                                          selectedCategory: isSelected,
                                          val: c,
                                          isDarkMode: widget.isDarkMode,
                                          onTap: onTapCategory,
                                        ),
                                      )
                                      .toList()
                                : categories_income
                                      .map(
                                        (c) => Categorychip(
                                          selectedCategory: isSelected,
                                          val: c,
                                          isDarkMode: widget.isDarkMode,
                                          onTap: onTapCategory,
                                        ),
                                      )
                                      .toList(),
                          ),

                          const SizedBox(height: 24),

                          SheetLabel(
                            isDarkMode: widget.isDarkMode,
                            text: "FROM ACCOUNT",
                          ),
                          const SizedBox(height: 12),
                          // Simplified Account Selection (Visual only for now)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: widget.isDarkMode
                                  ? Colors.white.withOpacity(0.05)
                                  : Colors.black.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: widget.isDarkMode
                                    ? Colors.white10
                                    : Colors.black12,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.account_balance_wallet_rounded,
                                  color: FinTrackTheme.primaryColor,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  "Cash in Hand",
                                  style: TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                Icon(
                                  Icons.arrow_drop_down_rounded,
                                  color: textColor.withOpacity(0.5),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 5. SAVE BUTTON (Consistent size)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: FinTrackTheme.primaryColor,
                        minimumSize: const Size(
                          double.infinity,
                          56,
                        ), // Standardized height
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "SAVE TRANSACTION",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildAccountTile(
    String name,
    String balance,
    IconData icon,
    bool isDarkMode,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.white.withOpacity(0.03)
            : Colors.black.withOpacity(0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: FinTrackTheme.primaryColor.withOpacity(0.3),
        ), // Highlighted selected source
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor.withOpacity(0.6)),
          const SizedBox(width: 12),
          Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
          const Spacer(),
          Text(
            balance,
            style: TextStyle(color: textColor.withOpacity(0.5), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactToggle(
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? FinTrackTheme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : (widget.isDarkMode ? Colors.white54 : Colors.black54),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(
    bool isDarkMode,
    CategoryItem selectedItem,
    CategoryItem val,
    Function(CategoryItem) onTap,
  ) {
    final bool isSelected = selectedItem == val;
    return GestureDetector(
      onTap: () {
        onTap(val);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        // 1. Ukuran membesar saat terpilih
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 18 : 16,
          vertical: isSelected ? 12 : 10,
        ),
        decoration: BoxDecoration(
          // 2. Background Fill jika terpilih, sangat tipis jika tidak (efek disable)
          color: isSelected
              ? FinTrackTheme.primaryColor
              : (isDarkMode
                    ? Colors.white.withOpacity(0.03)
                    : Colors.black.withOpacity(0.03)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            // Border lebih redup jika tidak terpilih
            color: isSelected
                ? FinTrackTheme.primaryColor
                : Colors.white.withOpacity(0.05),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          // 3. Efek Disable Tipis: Opacity 0.5 jika tidak terpilih
          opacity: isSelected ? 1.0 : 0.5,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                val.icon,
                size: isSelected ? 20 : 18,
                color: isSelected ? Colors.white : FinTrackTheme.primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                val.name,
                style: TextStyle(
                  fontSize: isSelected ? 15 : 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : (isDarkMode ? Colors.white70 : Colors.black54),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper for the Toggle Tabs
  Widget _buildTypeTab({
    required String label,
    required bool isSelected,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
