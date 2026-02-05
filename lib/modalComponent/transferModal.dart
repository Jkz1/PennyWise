import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme.dart';

void showTransferModal(BuildContext context, bool isDarkMode) {
  // Mock data for available wallets
  final List<Map<String, dynamic>> wallets = [
    {"name": "Bank", "icon": Icons.account_balance_rounded, "color": Colors.blueAccent},
    {"name": "Cash", "icon": Icons.payments_rounded, "color": Colors.amberAccent},
    {"name": "Savings", "icon": Icons.savings_rounded, "color": Colors.orangeAccent},
    {"name": "Crypto", "icon": Icons.currency_bitcoin_rounded, "color": Colors.purpleAccent},
  ];

  int selectedFromIndex = 0;
  int selectedToIndex = 1;

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
            height: MediaQuery.of(context).size.height * 0.75, // Taller to fit selection lists
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.black.withOpacity(0.8) : Colors.white.withOpacity(0.9),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. HANDLE & HEADER
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(10)))),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text("Transfer Funds", style: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.bold)),
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
                Center(child: Icon(Icons.arrow_downward_rounded, color: FinTrackTheme.primaryColor.withOpacity(0.5))),
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
                      disabled: index == selectedFromIndex, // Prevent sending to same wallet
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
                        textAlign: TextAlign.center,
                        autofocus: true,
                        style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: FinTrackTheme.primaryColor),
                        decoration: InputDecoration(
                          hintText: "\$ 0.00",
                          hintStyle: TextStyle(color: textColor.withOpacity(0.1)),
                          border: InputBorder.none,
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: FinTrackTheme.primaryColor,
                          minimumSize: const Size(double.infinity, 60),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          elevation: 0,
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text("CONFIRM TRANSFER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
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
    child: Text(text, style: TextStyle(color: FinTrackTheme.getTextColor(isDarkMode).withOpacity(0.4), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
  );
}

// Helper: Individual Wallet Picker Item
Widget _buildWalletOption(Map<String, dynamic> wallet, bool isSelected, VoidCallback onTap, bool isDarkMode, {bool disabled = false}) {
  final accentColor = wallet['color'] as Color;
  
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
            color: isSelected ? accentColor : (isDarkMode ? Colors.white10 : Colors.black12),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(wallet['icon'], color: isSelected ? accentColor : (isDarkMode ? Colors.white30 : Colors.black38), size: 28),
            const SizedBox(height: 8),
            Text(
              wallet['name'],
              style: TextStyle(
                color: isSelected ? FinTrackTheme.getTextColor(isDarkMode) : (isDarkMode ? Colors.white30 : Colors.black38),
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