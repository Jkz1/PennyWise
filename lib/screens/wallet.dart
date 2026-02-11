import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:penny_wise/components/netWorthSummary.dart';
import 'package:penny_wise/modalComponent/addWalletModal.dart';
import 'package:penny_wise/modalComponent/transferModal.dart';
import 'package:penny_wise/provider/deleteModeProvider.dart';
import 'package:penny_wise/provider/wallet.dart'; // Assumes walletListProvider & deleteModeProvider are here
import 'package:penny_wise/services/wallet.dart';
import 'package:penny_wise/utils/formatters.dart';
import '../theme.dart';
import '../components/bankCard.dart';
import '../components/walletActionBar.dart';

class WalletPage extends ConsumerWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. WATCH PROVIDERS
    final walletsAsync = ref.watch(walletListProvider);
    final isDeleteMode = ref.watch(deleteModeProvider);
    final totalBalance = ref.watch(totalBalanceProvider);
    // 2. THEME & SERVICE
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = FinTrackTheme.getTextColor(isDarkMode);
    final walletService = WalletService(); // Or ref.read(walletServiceProvider)

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 24, 24, 8),
            child: Text(
              "Total Balance",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ),

          // 1. TOTAL SUMMARY (Now Real-time!)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: NetWorthSummary(
              isDarkMode: isDarkMode,
              totalBalance: CurrencyFormatter.format(totalBalance)
            ),
          ),

          const SizedBox(height: 32),

          // 2. ACTION BAR
          WalletActionBar(
            isDarkMode: isDarkMode,
            onTransfer: () {
              walletsAsync.whenData((wallets) => 
                showTransferModal(context, isDarkMode, wallets)
              );
            },
            onAdd: () => showAddWalletModal(context, isDarkMode),
            onDelete: () {
              // Toggle global state instead of setState
              ref.read(deleteModeProvider.notifier).update((state) => !state);
            },
            isDeleteMode: isDeleteMode,
          ),

          const SizedBox(height: 40),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              "Your Wallets",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),

          // 3. HORIZONTAL WALLET LIST
          SizedBox(
            height: 180,
            child: walletsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => _buildErrorState(err.toString()),
              data: (wallets) {
                if (wallets.isEmpty) {
                  return _buildEmptyState(isDarkMode, textColor);
                }

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 24, right: 8),
                  physics: const BouncingScrollPhysics(),
                  itemCount: wallets.length,
                  itemBuilder: (context, index) {
                    final data = wallets[index];
                    
                    return BankCard(
                      name: data['name'] ?? 'Untitled',
                      balance: data['balance'],
                      color: Color(data['colorValue'] ?? 0xFF424242),
                      isDeleteMode: isDeleteMode,
                      onDelete: () {
                        // Turn off delete mode and call service
                        ref.read(deleteModeProvider.notifier).state = false;
                        walletService.deleteWallet(data['id']); // Assuming 'id' is in your map
                      },
                    );
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 40),

          // 4. RECENT TRANSFERS HEADER
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Recent Transfers",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  "See All",
                  style: TextStyle(
                    color: FinTrackTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 5. TRANSFER HISTORY
          _buildTransferHistorySection(isDarkMode, textColor),
          
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  // --- UI HELPER METHODS ---

  Widget _buildEmptyState(bool isDarkMode, Color textColor) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_balance_wallet_outlined, size: 40, color: textColor.withOpacity(0.2)),
          const SizedBox(height: 12),
          Text("No wallets found", style: TextStyle(color: textColor.withOpacity(0.5), fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(child: Text("Error: $message", style: const TextStyle(color: Colors.red)));
  }

  Widget _buildTransferHistorySection(bool isDarkMode, Color textColor) {
    // For now, using empty state. Later, you can wrap this in another StreamProvider!
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          Icon(Icons.history, size: 40, color: textColor.withOpacity(0.1)),
          const SizedBox(height: 8),
          Text("No recent transfers", style: TextStyle(color: textColor.withOpacity(0.3))),
        ],
      ),
    );
  }
}