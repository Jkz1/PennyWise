// ignore_for_file: unused_element

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:penny_wise/components/categoryChip.dart';
import 'package:penny_wise/components/sheetLabel.dart';
import 'package:penny_wise/model/expenseCategory.dart';
import 'package:penny_wise/provider/wallet.dart';
import 'package:penny_wise/services/transaction.dart';
import 'package:penny_wise/theme.dart';
import 'package:penny_wise/utils/formatters.dart';

class ExpenseModal extends ConsumerStatefulWidget {
  final bool isDarkMode;
  const ExpenseModal({super.key, required this.isDarkMode});

  @override
  ConsumerState<ExpenseModal> createState() => _ExpenseModalState();
}

class _ExpenseModalState extends ConsumerState<ExpenseModal> {
  CategoryItem isSelected = categories_expenses[0];
  bool isExpense = true;

  TextEditingController amountController = TextEditingController();
  TextEditingController titleController = TextEditingController();

  final TransactionService transactionService = TransactionService();

  String selectedWalletId = "";
  int selectedColorValue = 0;
  double maximumWalletBalance = 0.0;
  String selectedWalletName = "";
  double cleanAmount = 0.0;
  bool isLoading = false;

  bool wrongAmount = false;
  bool wrongWallet = false;

  bool realTimeCheck = false;

  @override
  Widget build(BuildContext context) {
    final walletsAsync = ref.watch(walletListProvider);
    final textColor = FinTrackTheme.getTextColor(widget.isDarkMode);

    onAmountChanged(String v) {
      cleanAmount = CurrencyFormatter.getCleanAmount(v);
      if (cleanAmount > 0 &&
          realTimeCheck == true &&
          !(cleanAmount > maximumWalletBalance &&
              isExpense &&
              selectedWalletId != "")) {
        wrongAmount = false;
      } else if (realTimeCheck == true && cleanAmount <= 0) {
        wrongAmount = true;
      }
    }

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

    onSaveTransaction() async {
      setState(() {
        realTimeCheck = true;
        wrongAmount = cleanAmount <= 0;
        wrongWallet = selectedWalletId == "";
      });
      if (wrongWallet || wrongAmount) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please select a wallet.',
              style: TextStyle(color: textColor),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        try {
          setState(() {
            isLoading = true;
          });
          await transactionService.addTransaction(
            selectedWalletId,
            isExpense,
            cleanAmount,
            titleController.text.trim() == ""
                ? isSelected.name
                : titleController.text.trim(),
            isSelected.name
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Transaction saved successfully!',
                style: TextStyle(color: textColor),
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving transaction: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } finally {
          setState(() {
            isLoading = false;
          });
          Navigator.pop(context);
        }
      }
    }

    void _showWalletPicker(BuildContext context, StateSetter setSheetState) {
      walletsAsync.when(
        data: (data) {
          final wallets = [
            for (var w in data)
              if (w['isDeleted'] != true) w,
          ];
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent, // Crucial for glass effect
            builder: (context) {
              return ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 15,
                    sigmaY: 15,
                  ), // The "Glass" blur
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      // Use FinTrackTheme glass colors or semi-transparent colors here
                      color: widget.isDarkMode
                          ? Colors.black.withOpacity(0.7)
                          : Colors.white.withOpacity(0.8),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(32),
                      ),
                      border: Border.all(
                        color: widget.isDarkMode
                            ? Colors.white10
                            : Colors.black12,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Handle bar for better UX
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: textColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Select Source Wallet",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // List of Wallets
                        Flexible(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: wallets.length,
                            itemBuilder: (context, index) {
                              final wallet = wallets[index];
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Color(
                                      wallet['colorValue'],
                                    ).withOpacity(0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.account_balance_wallet,
                                    color: Color(wallet['colorValue']),
                                    size: 20,
                                  ),
                                ),
                                title: Text(
                                  wallet['name'],
                                  style: TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  CurrencyFormatter.format(wallet['balance']),
                                  style: TextStyle(
                                    color: textColor.withOpacity(0.5),
                                  ),
                                ),
                                onTap: () {
                                  // Handle selection logic
                                  setSheetState(() {
                                    wrongWallet = false;
                                    selectedWalletId = wallet['id'];
                                    selectedWalletName = wallet['name'];
                                    maximumWalletBalance = wallet['balance'];
                                    selectedColorValue = wallet['colorValue'];
                                  });
                                  Navigator.pop(context);
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        error: (error, stackTrace) {
          return Center(
            child: Text(
              "Error loading wallets",
              style: TextStyle(color: textColor),
            ),
          );
        },
        loading: () {
          return const Center(child: CircularProgressIndicator());
        },
      );
    }

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setSheetState) => BackdropFilter(
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
            borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
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
                          () => setSheetState(() => onTapChangeSheet(false)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 4. AMOUNT INPUT (Smaller & Cleaner)
              Expanded(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      Center(
                        child: TextField(
                          autofocus: true,
                          controller: amountController,
                          keyboardType: TextInputType.number,
                          onChanged: (v) {
                            setSheetState(() {
                              onAmountChanged(v);
                            });
                          },
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: FinTrackTheme.primaryColor,
                            fontSize: 40, // Reduced from 48
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            prefixText: isExpense ? "-" : "+",
                            prefixStyle: TextStyle(
                              color: textColor.withOpacity(0.5),
                              fontSize: 28, // Reduced from 32
                            ),
                            border: InputBorder.none,
                            hintText: "0.00",
                            hintStyle: TextStyle(
                              color: textColor.withOpacity(0.1),
                            ),
                            isDense: true, // Removes extra vertical padding
                            contentPadding: EdgeInsets.zero,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            CurrencyInputFormatter(),
                          ],
                        ),
                      ),
                      if (wrongAmount &&
                          !(cleanAmount > maximumWalletBalance &&
                              isExpense &&
                              selectedWalletId != ""))
                        Padding(
                          padding: const EdgeInsets.only(top: 12.0, bottom: 12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.redAccent.withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.redAccent,
                                  size: 18,
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  "Invalid amount",
                                  style: TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (cleanAmount > maximumWalletBalance &&
                          isExpense &&
                          selectedWalletId != "")
                        Padding(
                          padding: const EdgeInsets.only(top: 12.0, bottom: 12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.redAccent.withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.redAccent,
                                  size: 18,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Insufficient funds",
                                        style: TextStyle(
                                          color: Colors.redAccent,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        // Showing the Wallet Name and the current balance limit
                                        "Limit for $selectedWalletName: ${CurrencyFormatter.format(maximumWalletBalance)}",
                                        style: TextStyle(
                                          color: Colors.redAccent.withOpacity(
                                            0.8,
                                          ),
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      Column(
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
                            text: "DESCRIPTION",
                          ),
                          const SizedBox(height: 12),

                          Container(
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
                            child: TextField(
                              controller: titleController,
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                hintText: "What was this for?",
                                hintStyle: TextStyle(
                                  color: textColor.withOpacity(0.3),
                                  fontSize: 14,
                                ),
                                prefixIcon: Icon(
                                  Icons.edit_note_rounded,
                                  color: textColor.withOpacity(0.5),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          SheetLabel(
                            isDarkMode: widget.isDarkMode,
                            text: "FROM WALLET",
                          ),
                          const SizedBox(height: 12),
                          // Simplified Account Selection (Visual only for now)
                          InkWell(
                            onTap: () {
                              _showWalletPicker(context, setSheetState);
                            },
                            child: Container(
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
                                    color: selectedColorValue == 0
                                        ? textColor.withOpacity(0.5)
                                        : Color(selectedColorValue),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    selectedWalletName == ""
                                        ? "Select Wallet"
                                        : selectedWalletName,
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
                          ),
                          if (wrongWallet)
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 12.0,
                                bottom: 12,
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.redAccent.withOpacity(0.2),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.warning_amber_rounded,
                                      color: Colors.redAccent,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 10),
                                    const Text(
                                      "Please select a wallet",
                                      style: TextStyle(
                                        color: Colors.redAccent,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // 5. SAVE BUTTON (Consistent size)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: ElevatedButton(
                  onPressed: isLoading || wrongWallet || wrongAmount
                      ? null
                      : onSaveTransaction,
                  style: ElevatedButton.styleFrom(
                    disabledBackgroundColor: FinTrackTheme.primaryColor
                        .withOpacity(0.3),
                    backgroundColor: FinTrackTheme.primaryColor.withOpacity(
                      isLoading || wrongWallet || wrongAmount ? 0.3 : 1,
                    ),
                    minimumSize: const Size(
                      double.infinity,
                      56,
                    ), // Standardized height
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 0,
                  ),
                  child: isLoading
                      ? CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        )
                      : const Text(
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
