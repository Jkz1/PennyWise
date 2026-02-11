import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:penny_wise/services/wallet.dart';
import 'package:penny_wise/utils/formatters.dart';
import '../theme.dart';

void showTransferModal(
  BuildContext context,
  bool isDarkMode,
  dynamic bankData,
) {
  // Mock data for available wallets
  final List<Map<String, dynamic>> wallets = List<Map<String, dynamic>>.from(
    bankData,
  );
  int selectedFromIndex = 0;
  int selectedToIndex = 1;
  dynamic cleanAmount = 0;
  final WalletService _ws = WalletService();
  final TextEditingController amountController = TextEditingController();
  void handleTransfer() {
    // print(bankData);
    try{
    final String toWalletId = wallets[selectedToIndex]['id'];
    final String fromWalletId = wallets[selectedFromIndex]['id'];
    _ws.transferBalanceWallets(fromWalletId, toWalletId, cleanAmount);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            "Successfully transferred ${CurrencyFormatter.format(cleanAmount)}"),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
    }
    catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Transfer failed: $e"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    finally {
      Navigator.of(context).pop();
    }
  }
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => StatefulBuilder(
      builder: (context, setModalState) {
        final textColor = FinTrackTheme.getTextColor(isDarkMode);

        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height:
                MediaQuery.of(context).size.height *
                0.75, // Taller to fit selection lists
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.black.withOpacity(0.8)
                  : Colors.white.withOpacity(0.9),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(40),
              ),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. HANDLE & HEADER
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    "Transfer Funds",
                    style: TextStyle(
                      color: textColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // 2. "FROM" SELECTION
                _buildSectionLabel("FROM WHICH WALLET?", isDarkMode),
                const SizedBox(height: 12),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(left: 32),
                    itemCount: wallets.length,
                    itemBuilder: (context, index) => _buildWalletOption(
                      wallets[index],
                      index == selectedFromIndex,
                      () => setModalState(() => selectedFromIndex = index),
                      isDarkMode,
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                Center(
                  child: Icon(
                    Icons.arrow_downward_rounded,
                    color: FinTrackTheme.primaryColor.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 24),

                // 3. "TO" SELECTION
                _buildSectionLabel("TO WHICH WALLET?", isDarkMode),
                const SizedBox(height: 12),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(left: 32),
                    itemCount: wallets.length,
                    itemBuilder: (context, index) => _buildWalletOption(
                      wallets[index],
                      index == selectedToIndex,
                      () => setModalState(() => selectedToIndex = index),
                      isDarkMode,
                      disabled:
                          index ==
                          selectedFromIndex, // Prevent sending to same wallet
                    ),
                  ),
                ),

                const Spacer(),

                // 4. AMOUNT & BUTTON
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      TextField(
                        controller: amountController,
                        textAlign: TextAlign.center,
                        autofocus: true,
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: FinTrackTheme.primaryColor,
                        ),
                        decoration: InputDecoration(
                          hintText: "\$ 0.00",
                          hintStyle: TextStyle(
                            color: textColor.withOpacity(0.1),
                          ),
                          border: InputBorder.none,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          CurrencyInputFormatter(),
                        ],
                        onChanged: (v) {
                          cleanAmount = CurrencyFormatter.getCleanAmount(v);
                          setModalState(() {});
                        },
                        keyboardType: TextInputType.number,
                      ),
                      if (cleanAmount > wallets[selectedFromIndex]['balance'])
                        Padding(
                          padding: const EdgeInsets.only(top: 12.0),
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
                                        "Limit for ${wallets[selectedFromIndex]['name']}: ${CurrencyFormatter.format(wallets[selectedFromIndex]['balance'])}",
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
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: FinTrackTheme.primaryColor,
                          minimumSize: const Size(double.infinity, 60),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 0,
                        ),
                        onPressed:
                            (cleanAmount == 0 ||
                                cleanAmount >
                                    wallets[selectedFromIndex]['balance'])
                            ? null
                            : () {
                                handleTransfer();
                              },
                        child: const Text(
                          "CONFIRM TRANSFER",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

// Helper: Small label for sections
Widget _buildSectionLabel(String text, bool isDarkMode) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 32),
    child: Text(
      text,
      style: TextStyle(
        color: FinTrackTheme.getTextColor(isDarkMode).withOpacity(0.4),
        fontSize: 10,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    ),
  );
}

Widget _buildWalletOption(
  Map<String, dynamic> wallet,
  bool isSelected,
  VoidCallback onTap,
  bool isDarkMode, {
  bool disabled = false,
}) {
  final accentColor = Color(wallet['colorValue']);

  String getInitials(String name) {
    if (name.isEmpty) return "";
    List<String> names = name.trim().split(" ");
    return names.length > 1
        ? (names[0][0] + names[1][0]).toUpperCase()
        : names[0][0].toUpperCase();
  }



  return GestureDetector(
    onTap: disabled ? null : onTap,
    child: Opacity(
      opacity: disabled ? 0.3 : 1.0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 16),
        width: 85,
        decoration: BoxDecoration(
          color: isSelected ? accentColor.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? accentColor
                : (isDarkMode ? Colors.white10 : Colors.black12),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // --- INITIALS CIRCLE ---
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? accentColor
                    : (isDarkMode ? Colors.white10 : Colors.black12),
                shape: BoxShape.circle,
              ),
              child: Text(
                getInitials(wallet['name']),
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : (isDarkMode ? Colors.white30 : Colors.black38),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // --- WALLET NAME ---
            Text(
              wallet['name'],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isSelected
                    ? (isDarkMode ? Colors.white : Colors.black87)
                    : (isDarkMode ? Colors.white30 : Colors.black38),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 8),
            // --- WALLET NAME ---
            Text(
              CurrencyFormatter.format(wallet['balance']).toString(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isSelected
                    ? (isDarkMode ? Colors.white : Colors.black87)
                    : (isDarkMode ? Colors.white30 : Colors.black38),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
