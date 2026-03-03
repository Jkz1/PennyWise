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
            isSelected.name,
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

    void showWalletPicker(BuildContext context, StateSetter setSheetState) {
      walletsAsync.when(
        data: (data) {
          final wallets = [
            for (var w in data)
              if (w['isDeleted'] != true) w,
          ];
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            builder: (context) {
              return ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
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

    Widget _buildSheetLabel(String text, Color textColor) {
      return Text(
        text,
        style: TextStyle(
          color: textColor.withOpacity(0.4),
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      );
    }

    Widget _buildInlineWalletPicker(
      Color textColor,
      StateSetter setSheetState,
    ) {
      return InkWell(
        onTap: () => showWalletPicker(context, setSheetState),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: widget.isDarkMode
                ? Colors.white.withOpacity(0.04)
                : Colors.black.withOpacity(0.03),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.account_balance_wallet_rounded,
                color: selectedColorValue == 0
                    ? textColor.withOpacity(0.3)
                    : Color(selectedColorValue),
                size: 18,
              ),
              const SizedBox(width: 12),
              Text(
                selectedWalletName == "" ? "Select Wallet" : selectedWalletName,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: textColor.withOpacity(0.3),
              ),
            ],
          ),
        ),
      );
    }

    Widget _buildInlineTextField(
      TextEditingController controller,
      String hint,
      Color textColor,
    ) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: widget.isDarkMode
              ? Colors.white.withOpacity(0.04)
              : Colors.black.withOpacity(0.03),
          borderRadius: BorderRadius.circular(14),
        ),
        child: TextField(
          controller: controller,
          style: TextStyle(color: textColor, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: textColor.withOpacity(0.2)),
            border: InputBorder.none,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      );
    }

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setSheetState) =>
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: SafeArea(
              bottom: true,
              child: Container(
                decoration: BoxDecoration(
                  color: widget.isDarkMode
                      ? Colors.black.withOpacity(0.8)
                      : Colors.white.withOpacity(0.9),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(35),
                  ),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                padding: EdgeInsets.fromLTRB(
                  24,
                  12,
                  24,
                  MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 32,
                          height: 4,
                          decoration: BoxDecoration(
                            color: textColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "New Transaction",
                            style: TextStyle(
                              color: textColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(3),
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
                                  () => setSheetState(
                                    () => onTapChangeSheet(true),
                                  ),
                                ),
                                _buildCompactToggle(
                                  "Income",
                                  !isExpense,
                                  () => setSheetState(
                                    () => onTapChangeSheet(false),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      Center(
                        child: TextField(
                          autofocus: true,
                          controller: amountController,
                          keyboardType: TextInputType.number,
                          onChanged: (v) =>
                              setSheetState(() => onAmountChanged(v)),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: FinTrackTheme.primaryColor,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            prefixText: isExpense ? "-" : "+",
                            prefixStyle: TextStyle(
                              color: textColor.withOpacity(0.3),
                              fontSize: 24,
                            ),
                            border: InputBorder.none,
                            hintText: "0.00",
                            hintStyle: TextStyle(
                              color: textColor.withOpacity(0.1),
                            ),
                            isDense: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            CurrencyInputFormatter(),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.4,
                        ),
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSheetLabel("CATEGORY", textColor),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children:
                                    (isExpense
                                            ? categories_expenses
                                            : categories_income)
                                        .map(
                                          (c) => Categorychip(
                                            selectedCategory: isSelected,
                                            val: c,
                                            isDarkMode: widget.isDarkMode,
                                            onTap: (cat) => setSheetState(
                                              () => onTapCategory(cat),
                                            ),
                                          ),
                                        )
                                        .toList(),
                              ),
                              const SizedBox(height: 24),

                              _buildSheetLabel("FROM WALLET", textColor),
                              const SizedBox(height: 10),
                              _buildInlineWalletPicker(
                                textColor,
                                setSheetState,
                              ),

                              const SizedBox(height: 24),

                              _buildSheetLabel("DESCRIPTION", textColor),
                              const SizedBox(height: 10),
                              _buildInlineTextField(
                                titleController,
                                "What was this for?",
                                textColor,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      ElevatedButton(
                        onPressed: isLoading || wrongWallet || wrongAmount
                            ? null
                            : onSaveTransaction,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: FinTrackTheme.primaryColor,
                          minimumSize: const Size(double.infinity, 54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                "SAVE TRANSACTION",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
}
