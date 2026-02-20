// ignore_for_file: unused_element

import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:penny_wise/components/categoryChip.dart';
import 'package:penny_wise/modalComponent/createPlanSheet.dart';
import 'package:penny_wise/components/sheetLabel.dart';
import 'package:penny_wise/components/smallToggle.dart';
import 'package:penny_wise/model/expenseCategory.dart';
import 'package:penny_wise/provider/plannedProv.dart';
import 'package:penny_wise/provider/wallet.dart';
import 'package:penny_wise/services/planned.dart';
import 'package:penny_wise/theme.dart';
import 'package:penny_wise/utils/formatters.dart';
import 'package:penny_wise/utils/relativesDate.dart';

class PlannedModal extends ConsumerStatefulWidget {
  const PlannedModal({super.key});

  @override
  ConsumerState<PlannedModal> createState() => _PlannedModalState();
}

class _PlannedModalState extends ConsumerState<PlannedModal> {
  CategoryItem selectedCategory = categories_expenses[0];
  void _showWalletPicker(BuildContext context, String plannedId) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = FinTrackTheme.getTextColor(isDarkMode);
    final walletsAsync = ref.watch(walletListProvider);

    String selectedWalletId = "";
    
    handlLog ()async{
      final ps = PlannedService();
      try{
        await ps.logPlanned(plannedId: plannedId, walletId: selectedWalletId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Logged successfully!"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      catch(e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to log: $e"),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      finally {
        Navigator.pop(context); // Close the wallet picker
        Navigator.pop(context); // Close the planned modal
      }
    }

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
            return StatefulBuilder(
              builder: (context, setState) {
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
                        color: isDarkMode
                            ? Colors.black.withOpacity(0.7)
                            : Colors.white.withOpacity(0.8),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(32),
                        ),
                        border: Border.all(
                          color: isDarkMode ? Colors.white10 : Colors.black12,
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
                                  trailing: selectedWalletId == wallet['id']
                                      ? const Icon(
                                          Icons.check_circle,
                                          color: Colors.blue,
                                        )
                                      : null,
                                  subtitle: Text(
                                    CurrencyFormatter.format(wallet['balance']),
                                    style: TextStyle(
                                      color: textColor.withOpacity(0.5),
                                    ),
                                  ),
                                  onTap: () {
                                    // Handle selection logic
                                    setState(() {
                                      if (selectedWalletId == wallet['id']) {
                                        selectedWalletId =
                                            ""; // Deselect if tapped again
                                      } else {
                                        selectedWalletId = wallet['id'];
                                      }
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                          ElevatedButton(
                            onPressed: selectedWalletId == ""
                                ? null
                                : handlLog,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: FinTrackTheme.primaryColor
                                  .withOpacity(0.9),
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              "Confirm Log",
                              style: TextStyle(
                                color: FinTrackTheme.getTextColor(isDarkMode),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
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

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final textColor = FinTrackTheme.getTextColor(isDarkMode);
    final glassColor = FinTrackTheme.getGlassColor(isDarkMode);
    final glassBorder = FinTrackTheme.getGlassBorder(isDarkMode);

    final plannedItemAsync = ref.watch(plannedItem);

    final plannedHistoryAsync = ref.watch(plannedHistoryProvider);

    Future<bool?> _showDeleteConfirmation(
      BuildContext context,
      String title,
      String id,
    ) {
      return showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text("Delete Plan?", style: TextStyle(color: Colors.white)),
          content: Text(
            "Are you sure you want to remove '$title'?",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("CANCEL", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                try {
                  final ps = PlannedService();
                  await ps.deletePlannedItem(id);
                  Navigator.pop(context, true);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Failed to delete plan: $e"),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                  Navigator.pop(context);
                  Navigator.pop(context);
                }
              },
              child: const Text(
                "DELETE",
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        ),
      );
    }

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Container(
        height:
            MediaQuery.of(context).size.height *
            0.8, // Slightly taller to fit lists
        decoration: BoxDecoration(
          color: isDarkMode
              ? Colors.black.withOpacity(0.7)
              : Colors.white.withOpacity(0.8),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. HEADER
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
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Planned Payments",
                  style: TextStyle(
                    color: textColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    showCreatePlanSheet(context, isDarkMode, textColor);
                  },
                  icon: Icon(
                    Icons.add_circle_outline_rounded,
                    color: FinTrackTheme.primaryColor,
                    size: 28,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 2. SCROLLABLE CONTENT
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SheetLabel(isDarkMode: isDarkMode, text: "UPCOMING"),
                    const SizedBox(height: 16),
                    plannedItemAsync.when(
                      data: (data) {
                        return Column(
                          children: data
                              .map(
                                (item) {
                                  if(item['isPay'] == true) return const SizedBox.shrink();
                                  return Slidable(
                                  key: ValueKey(item['title']),

                                  endActionPane: ActionPane(
                                    extentRatio: 0.15,
                                    motion: const DrawerMotion(),
                                    children: [
                                      SlidableAction(
                                        onPressed: (context) {
                                          _showDeleteConfirmation(
                                            context,
                                            item['title'],
                                            item['id'],
                                          );
                                        },
                                        backgroundColor: Colors.transparent,
                                        foregroundColor: Colors.redAccent
                                            .withOpacity(0.5),
                                        icon: Icons.delete_outline_rounded,
                                        label: 'Delete',
                                        borderRadius: BorderRadius.circular(
                                          20,
                                        ), // Matches your card shape
                                      ),
                                    ],
                                  ),

                                  child: _buildModalPlannedCard(
                                    item,
                                    glassColor,
                                    glassBorder,
                                    textColor,
                                  ),
                                );},
                              )
                              .toList(),
                        );
                      },
                      error: (error, stackTrace) {
                        return Center(
                          child: Text(
                            "Error loading planned items",
                            style: TextStyle(color: textColor),
                          ),
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                    ),

                    const SizedBox(height: 32),
                    SheetLabel(
                      isDarkMode: isDarkMode,
                      text: "RECENTLY SETTLED",
                    ),
                    const SizedBox(height: 16),
                    ...plannedHistoryAsync.map(
                      (item) => _buildModalHistoryItem(
                        item,
                        glassColor,
                        glassBorder,
                        textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 3. ACTION BUTTON (Optional: Link to full audit/calendar)
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: FinTrackTheme.primaryColor.withOpacity(0.1),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                "CLOSE",
                style: TextStyle(
                  color: FinTrackTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

Widget _buildModalHistoryItem(
  Map<String, dynamic> item,
  Color glassColor,
  Color glassBorder,
  Color textColor,
) {
  // 1. Convert Timestamp to formatted String
  final dynamic timestamp = item['timestamp'];
  // Default to now
  DateTime formattedDate = DateFormat('HH:mm dd/MM/yyyy').parse(timestamp);
  final textDate = getRelativeDate(formattedDate);


  return Opacity(
    opacity: 0.7, // Slightly increased for better readability
    child: Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_rounded,
            color: FinTrackTheme.primaryColor.withOpacity(0.8),
            size: 18,
          ),
          const SizedBox(width: 12),
          Expanded( // Added Expanded to handle long titles
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'],
                  style: TextStyle(
                    color: textColor, 
                    fontSize: 13, 
                    fontWeight: FontWeight.w600
                  ),
                ),
                Text(
                  textDate,
                  style: TextStyle(
                    color: textColor.withOpacity(0.5), 
                    fontSize: 10
                  ),
                ),
              ],
            ),
          ),
          Text(
            CurrencyFormatter.format(item['amount']), // Consistent with your other widget
            style: TextStyle(
              color: textColor,
              fontSize: 13,
              fontFamily: 'monospace', // Gives a nice financial look
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );
}
Widget _buildModalPlannedCard(
    Map<String, dynamic> item,
    Color glassColor,
    Color glassBorder,
    Color textColor,
  ) {
    // Determine the frequency label
    final bool isMonthly = item['isMonthly'] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: glassColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: glassBorder),
      ),
      child: Row(
        children: [
          Icon(item['icon'], color: FinTrackTheme.primaryColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'],
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2), // Small spacing
                Row(
                  children: [
                    Text(
                      "Due ${item['dueDate']}",
                      style: const TextStyle(
                        color: Colors.orangeAccent,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Frequency Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isMonthly 
                            ? Colors.blue.withOpacity(0.2) 
                            : Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isMonthly ? "MONTHLY" : "ONCE",
                        style: TextStyle(
                          color: isMonthly ? Colors.blue : Colors.grey[400],
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.format(item['amount']),
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () {
                  _showWalletPicker(context, item['id']);
                },
                child: Text(
                  "LOG NOW",
                  style: TextStyle(
                    color: FinTrackTheme.primaryColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallToggle(
    String label,
    bool isSelected,
    VoidCallback onTap,
    bool isDarkMode,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          // High-contrast color for the selected state, transparent for unselected
          color: isSelected ? FinTrackTheme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : (isDarkMode ? Colors.white54 : Colors.black54),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
