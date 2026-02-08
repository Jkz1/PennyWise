import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:penny_wise/components/netWorthSummary.dart';
import 'package:penny_wise/modalComponent/addWalletModal.dart';
import 'package:penny_wise/modalComponent/transferModal.dart';
import 'package:penny_wise/services/wallet.dart';
import '../theme.dart';
import '../components/bankCard.dart';
import '../components/walletActionBar.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {

  final WalletService _walletService = WalletService();

  bool isDeleteMode = false;
  final List<Map<String, dynamic>> _transferHistory = [
    {
      "from": "Bank",
      "to": "Savings",
      "amount": "500.00",
      "date": "Today, 10:24 AM",
      "color": Colors.blueAccent,
    },
    {
      "from": "Cash",
      "to": "Investment",
      "amount": "50.00",
      "date": "Yesterday",
      "color": Colors.orangeAccent,
    },
    {
      "from": "Cash",
      "to": "Investment",
      "amount": "50.00",
      "date": "Yesterday",
      "color": Colors.orangeAccent,
    },
    {
      "from": "Cash",
      "to": "Investment",
      "amount": "50.00",
      "date": "Yesterday",
      "color": Colors.orangeAccent,
    },
  ];
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    // inside WalletPage build method
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

          // 1. TOTAL SUMMARY (TOP)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: NetWorthSummary(
              isDarkMode: isDarkMode,
              totalAssets: "\$12,450.00",
              totalDebt: "\$800.00",
            ),
          ),

          const SizedBox(height: 32),

          // 2. ACTION BAR (CENTER)
          WalletActionBar(
            isDarkMode: isDarkMode,
            onTransfer: () => showTransferModal(context, isDarkMode),
            onAdd: () => showAddWalletModal(context, isDarkMode),
            onDelete: () {
              setState(() {
                isDeleteMode = !isDeleteMode;
              });
              print("Hai");
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

          // 3. HORIZONTAL TINTED GLASS CARDS (BOTTOM SECTION)
          SizedBox(
  height: 180,
  child: StreamBuilder<QuerySnapshot>(
    stream: _walletService.getWallets(),
    builder: (context, snapshot) {
      // Handle Loading State
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      // Handle Errors
      if (snapshot.hasError) {
        return Center(child: Text("Error: ${snapshot.error}"));
      }

      // Handle Empty Data
      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return Text("hai"); // The helper we made earlier
      }

      // 3. ACCESS THE DATA
      final walletDocs = snapshot.data!.docs;

      return ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 24, right: 8),
        physics: const BouncingScrollPhysics(),
        itemCount: walletDocs.length,
        itemBuilder: (context, index) {
          // Convert Firestore Document to local variables
          var data = walletDocs[index].data() as Map<String, dynamic>;
          
          return BankCard(
            name: data['name'] ?? 'Untitled',
            balance: "\$${data['balance']}",
            color: Color(data['colorValue']), // Convert int back to Color
            isDeleteMode: isDeleteMode,
            onDelete: () => _walletService.deleteWallet(walletDocs[index].id),
          );
        },
      );
    },
  ),
),
          const SizedBox(height: 40),

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
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 4. TRANSFER HISTORY LIST
          // ListView.builder(
          //   shrinkWrap: true, // Crucial inside a SingleChildScrollView
          //   padding: const EdgeInsets.symmetric(horizontal: 24),
          //   itemCount: _transferHistory.length,
          //   itemBuilder: (context, index) {
          //     final item = _transferHistory[index];
          //     return _buildTransferHistoryItem(item, isDarkMode);
          //   },
          // ),
          ..._transferHistory.map((item) => _buildTransferHistoryItem(item, isDarkMode)),
          SizedBox(height: 120,)
        ],
      ),
    );
  }

  Widget _buildTransferHistoryItem(Map<String, dynamic> item, bool isDarkMode) {
    final textColor = FinTrackTheme.getTextColor(isDarkMode);

    return Container(
      margin: const EdgeInsets.only(bottom: 12, left: 24, right: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          // Visual indicator of the destination wallet color
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: item['color'].withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.swap_horiz_rounded,
              color: item['color'],
              size: 20,
            ),
          ),
          const SizedBox(width: 16),

          // Transfer Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${item['from']} → ${item['to']}",
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item['date'],
                  style: TextStyle(
                    color: textColor.withOpacity(0.4),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Amount
          Text(
            "\$${item['amount']}",
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
