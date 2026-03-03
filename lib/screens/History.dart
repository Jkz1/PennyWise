import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:penny_wise/components/MultiChip.dart';
import 'package:penny_wise/components/backgroundBlob.dart';
import 'package:penny_wise/components/categoryChip.dart'; // Your custom chip
import 'package:penny_wise/components/transactionHistory.dart';
import 'package:penny_wise/model/expenseCategory.dart'; // Assuming categories are here
import 'package:penny_wise/provider/wallet.dart';
import 'package:penny_wise/theme.dart';
import 'package:penny_wise/utils/formatters.dart';
import 'package:intl/intl.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  // Filter States
  DateTimeRange? selectedDateRange;
  List<String> selectedCategories = [];
  bool? filterIsExpense; // null = All, true = Expense, false = Income

  // Dynamic Category Getter
  List<CategoryItem> get availableCategories {
    if (filterIsExpense == true) return categories_expenses;
    if (filterIsExpense == false) return categories_income;
    // If "All", combine both lists for the filter options
    return [...categories_expenses, ...categories_income];
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = FinTrackTheme.getTextColor(isDarkMode);
    final glassColor = FinTrackTheme.getGlassColor(isDarkMode);
    final glassBorder = FinTrackTheme.getGlassBorder(isDarkMode);

    final transactionsAsync = ref.watch(transactionHistory);

    return Scaffold(
      body: Stack(
        children: [
          Backgroundblob(
            top: -50,
            right: -50,
            color: FinTrackTheme.primaryColor,
            isDarkMode: isDarkMode,
          ),
          Backgroundblob(
            bottom: 100,
            left: -80,
            color: FinTrackTheme.deepIndigo,
            isDarkMode: isDarkMode,
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      _buildBackButton(context, isDarkMode, textColor),
                      const SizedBox(width: 16),
                      Text(
                        "History",
                        style: TextStyle(
                          color: textColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. Filter Bar (Chips)
                _buildFilterChips(isDarkMode, textColor),

                const SizedBox(height: 10),

                // 3. Transactions List
                Expanded(
                  child: transactionsAsync.when(
                    data: (transactions) {
                      final filtered = _applyFilters(transactions);
                      if (filtered.isEmpty) return _buildEmptyState(textColor);

                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) => HistoryItem(
                          item: filtered[index],
                          textColor: textColor,
                          glassColor: glassColor,
                          glassBorder: glassBorder,
                        ),
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, _) => Center(child: Text("Error: $err")),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- MODAL TRIGGERS ---

  void _showCategoryPicker(bool isDarkMode, Color textColor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _FilterModalWrapper(
        // The main modal title adjusts based on selection
        title: filterIsExpense == null
            ? "All Categories"
            : (filterIsExpense! ? "Expense Categories" : "Income Categories"),
        isDarkMode: isDarkMode,
        textColor: textColor,
        child: StatefulBuilder(
          builder: (context, setModalState) {
            return Column(
              children: [
                SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. SHOW EXPENSE SECTION
                        // (Visible if Type is 'All' or 'Expense')
                        if (filterIsExpense == null || filterIsExpense == true) ...[
                          _buildSectionHeader("EXPENSES", textColor),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 10,
                            children: categories_expenses.map((cat) {
                              return MultiChip(
                                selectedCategories: selectedCategories,
                                val: cat,
                                isDarkMode: isDarkMode,
                                onTap: (clickedCat) {
                                  setModalState(() {
                                    _toggleCategory(clickedCat.name);
                                  });
                                  setState(() {});
                                },
                              );
                            }).toList(),
                          ),
                          if (filterIsExpense == null) const SizedBox(height: 24),
                        ],
                
                        // 2. SHOW INCOME SECTION
                        // (Visible if Type is 'All' or 'Income')
                        if (filterIsExpense == null ||
                            filterIsExpense == false) ...[
                          _buildSectionHeader("INCOME", textColor),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 10,
                            children: categories_income.map((cat) {
                              return MultiChip(
                                selectedCategories: selectedCategories,
                                val: cat,
                                isDarkMode: isDarkMode,
                                onTap: (clickedCat) {
                                  setModalState(() {
                                    _toggleCategory(clickedCat.name);
                                  });
                                  setState(() {});
                                },
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    )
                ),
                SizedBox(height: 40,)
              ],
            );
          },
        ),
      ),
    );
  }

  // Helper to handle the toggle logic cleanly
  void _toggleCategory(String name) {
    if (selectedCategories.contains(name)) {
      selectedCategories.remove(name);
    } else {
      selectedCategories.add(name);
    }
  }

  // Helper for the small overline headers inside the modal
  Widget _buildSectionHeader(String title, Color textColor) {
    return Text(
      title,
      style: TextStyle(
        color: textColor.withOpacity(0.4),
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.1,
      ),
    );
  }
  
void _showTypePicker(bool isDarkMode, Color textColor) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    // This allows us to position it more freely
    builder: (context) => Center(
      child: _FilterModalWrapper(
        title: "Transaction Type",
        isDarkMode: isDarkMode,
        textColor: textColor,
        // Shrink the modal so it doesn't span the whole width
        margin: const EdgeInsets.symmetric(horizontal: 40), 
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTypeOption("All Transactions", null, isDarkMode),
              const SizedBox(height: 4),
              _buildTypeOption("Expenses", true, isDarkMode),
              const SizedBox(height: 4),
              _buildTypeOption("Income", false, isDarkMode),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _buildTypeOption(String label, bool? type, bool isDarkMode) {
  bool isSelected = filterIsExpense == type;
  return GestureDetector(
    onTap: () {
      setState(() {
        filterIsExpense = type;
        selectedCategories.clear();
      });
      Navigator.pop(context);
    },
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: isSelected ? FinTrackTheme.primaryColor : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : (isDarkMode ? Colors.white70 : Colors.black87),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    ),
  );
}
  // --- LOGIC ---

  List<Map<String, dynamic>> _applyFilters(List<Map<String, dynamic>> list) {
    return list.where((item) {
      if (filterIsExpense != null && item['isExpense'] != filterIsExpense)
        return false;
      if (selectedCategories.isNotEmpty &&
          !selectedCategories.contains(item['category']))
        return false;
      if (selectedDateRange != null) {
        final dynamic timestamp = item['timestamp'];
    // Default to now
    DateTime txDate = DateFormat('HH:mm dd/MM/yyyy').parse(timestamp);
        if (txDate.isBefore(selectedDateRange!.start) ||
            txDate.isAfter(selectedDateRange!.end.add(const Duration(days: 1))))
          return false;
      }
      return true;
    }).toList();
  }

  // --- UI HELPER COMPONENTS ---

  Widget _buildFilterChips(bool isDarkMode, Color textColor) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          _buildFilterTrigger(
            label: filterIsExpense == null
                ? "Type"
                : (filterIsExpense! ? "Expenses" : "Income"),
            icon: Icons.sort_rounded,
            active: filterIsExpense != null,
            onTap: () => _showTypePicker(isDarkMode, textColor),
          ),
          _buildFilterTrigger(
            label: selectedCategories.isEmpty
                ? "Category"
                : "${selectedCategories.length} Selected",
            icon: Icons.category_outlined,
            active: selectedCategories.isNotEmpty,
            onTap: () => _showCategoryPicker(isDarkMode, textColor),
          ),
          _buildFilterTrigger(
            label: selectedDateRange == null ? "Dates" : "Custom Range",
            icon: Icons.calendar_today_rounded,
            active: selectedDateRange != null,
            onTap: () async {
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2023),
                lastDate: DateTime.now(),
              );
              if (picked != null) setState(() => selectedDateRange = picked);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTrigger({
    required String label,
    required IconData icon,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: active
              ? FinTrackTheme.primaryColor
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: active ? Colors.transparent : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: active ? Colors.white : FinTrackTheme.primaryColor,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: active ? Colors.white : Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Reusing your slimmed item design
  Widget _buildHistoryItem({
    required Map<String, dynamic> item,
    required Color textColor,
    required Color glassColor,
    required Color glassBorder,
  }) {
    final bool isExpense = item['isExpense'] ?? true;
    final Color statusColor = isExpense
        ? Colors.redAccent
        : FinTrackTheme.primaryColor;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: glassColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: glassBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isExpense
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_downward_rounded,
              color: statusColor,
              size: 16,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'] ?? "Untitled",
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  "${item['category']} • ${item['walletName']}",
                  style: TextStyle(
                    color: textColor.withOpacity(0.4),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            "${isExpense ? '-' : '+'} ${CurrencyFormatter.format(item['amount'])}",
            style: TextStyle(
              color: isExpense ? textColor : statusColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton(
    BuildContext context,
    bool isDarkMode,
    Color textColor,
  ) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDarkMode
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: textColor,
          size: 18,
        ),
      ),
    );
  }

  Widget _buildEmptyState(Color textColor) => Center(
    child: Text(
      "No transactions found",
      style: TextStyle(color: textColor.withOpacity(0.3)),
    ),
  );
}
class _FilterModalWrapper extends StatelessWidget {
  final String title;
  final Widget child;
  final bool isDarkMode;
  final Color textColor;
  final EdgeInsets? margin; // Added margin property

  const _FilterModalWrapper({
    required this.title,
    required this.child,
    required this.isDarkMode,
    required this.textColor,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
      child: Container(
        margin: margin ?? EdgeInsets.zero, // Use margin to make it "float"
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: BoxDecoration(
          color: isDarkMode 
              ? Colors.black.withOpacity(0.7) 
              : Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(28), // Rounded all around for floating look
          border: Border.all(
            color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Very important to keep it slim
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 30,
                height: 4,
                decoration: BoxDecoration(
                  color: textColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}