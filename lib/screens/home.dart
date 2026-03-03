// ignore_for_file: unused_element, unused_import, unused_local_variable

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:penny_wise/components/floatingNav.dart';
import 'package:penny_wise/components/transactionHistory.dart';
import 'package:penny_wise/modalComponent/addExpenseModal.dart';
import 'package:penny_wise/components/backgroundBlob.dart';
import 'package:penny_wise/components/categoryChip.dart';
import 'package:penny_wise/modalComponent/plannedModal.dart';
import 'package:penny_wise/components/quickActions.dart';
import 'package:penny_wise/components/sectionHeader.dart';
import 'package:penny_wise/modalComponent/quickStatModal.dart';
import 'package:penny_wise/model/expenseCategory.dart';
import 'package:penny_wise/provider/darkModeProv.dart';
import 'package:penny_wise/provider/statProv.dart';
import 'package:penny_wise/provider/userProv.dart';
import 'package:penny_wise/provider/wallet.dart';
import 'package:penny_wise/screens/analytics.dart';
import 'package:penny_wise/screens/profile.dart';
import 'package:penny_wise/screens/History.dart';
import 'package:penny_wise/screens/wallet.dart';
import 'package:penny_wise/services/test.dart';
import 'package:penny_wise/theme.dart';
import 'package:penny_wise/utils/formatters.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});
  // const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  CategoryItem selectedCategory = categories_expenses[0];
  int _selectedIndex = 0;
  bool _isBalanceVisible = true;



  void toggleTheme() {
    ref.read(darkmode.notifier).toggle();
  }

  _showAddExpenseSheet() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = FinTrackTheme.getTextColor(isDarkMode);
    final walletsAsync = ref.watch(walletListProvider);
    walletsAsync.whenData((wallets) {
      if (wallets.isEmpty || wallets.every((w) => w['isDeleted'])) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please add a wallet before transferring.'),
            backgroundColor: Colors.amber,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => ExpenseModal(isDarkMode: isDarkMode),
      );
    });
  }

  _showQuickStatsSheet() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    bool isWeekly = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuickStat(isDarkMode: isDarkMode),
    );
  }

  void _showPlannedSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PlannedModal(),
    );
  }

  void _showCreatePlanSheet(
    BuildContext context,
    bool isDarkMode,
    Color textColor,
  ) {
    // Local state for the plan creator
    bool isRecurring = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.black.withOpacity(0.7)
                  : Colors.white.withOpacity(0.8),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(40),
              ),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. PREMIUM HEADER & TOGGLE
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
                      "New Plan",
                      style: TextStyle(
                        color: textColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Natural Toggle for Monthly vs One-time
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? Colors.white.withOpacity(0.05)
                            : Colors.black.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          _buildSmallToggle(
                            "Monthly",
                            isRecurring,
                            () => setSheetState(() => isRecurring = true),
                            isDarkMode,
                          ),
                          _buildSmallToggle(
                            "Once",
                            !isRecurring,
                            () => setSheetState(() => isRecurring = false),
                            isDarkMode,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // 2. INTEGRATED TITLE INPUT
                _buildSheetLabel("WHAT ARE WE PLANNING?", textColor),
                TextField(
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: "e.g. Health Insurance",
                    hintStyle: TextStyle(color: textColor.withOpacity(0.15)),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: textColor.withOpacity(0.1)),
                    ),
                    focusedBorder: InputBorder.none,
                  ),
                ),

                const SizedBox(height: 32),

                // 3. AMOUNT & DATE (Side by Side)
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSheetLabel("AMOUNT", textColor),
                          TextField(
                            keyboardType: TextInputType.number,
                            style: TextStyle(
                              color: FinTrackTheme.primaryColor,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              prefixText: "\$ ",
                              prefixStyle: TextStyle(
                                color: FinTrackTheme.primaryColor.withOpacity(
                                  0.5,
                                ),
                                fontSize: 20,
                              ),
                              border: InputBorder.none,
                              hintText: "0.00",
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSheetLabel("DUE DATE", textColor),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () {}, // Trigger Date Picker
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: textColor.withOpacity(0.1),
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_month_rounded,
                                    size: 18,
                                    color: textColor.withOpacity(0.5),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Select Date",
                                    style: TextStyle(
                                      color: textColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // 4. CATEGORY SELECTOR (Using your new Animated Chip style)
                _buildSheetLabel("CATEGORY", textColor),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    Categorychip(
                      selectedCategory: selectedCategory,
                      val: categories_expenses[0],
                      isDarkMode: isDarkMode,
                      onTap: onTapCategory,
                    ),
                    Categorychip(
                      selectedCategory: selectedCategory,
                      val: categories_expenses[1],
                      isDarkMode: isDarkMode,
                      onTap: onTapCategory,
                    ),
                    Categorychip(
                      selectedCategory: selectedCategory,
                      val: categories_expenses[2],
                      isDarkMode: isDarkMode,
                      onTap: onTapCategory,
                    ),
                    Categorychip(
                      selectedCategory: selectedCategory,
                      val: categories_expenses[3],
                      isDarkMode: isDarkMode,
                      onTap: onTapCategory,
                    ),
                  ],
                ),

                const Spacer(),

                // 5. ACTION BUTTON
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FinTrackTheme.primaryColor,
                    minimumSize: const Size(double.infinity, 64),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "CREATE PLAN",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSheetLabel(String text, Color textColor) {
    return Text(
      text,
      style: TextStyle(
        color: textColor.withOpacity(0.4), // Faded look for headers
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5, // Essential for that "premium" label feel
      ),
    );
  }

  Widget _buildModalPlannedCard(
    Map<String, dynamic> item,
    Color glassColor,
    Color glassBorder,
    Color textColor,
  ) {
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
                Text(
                  item['date'],
                  style: const TextStyle(
                    color: Colors.orangeAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "\$${item['amount']}",
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "LOG NOW",
                style: TextStyle(
                  color: FinTrackTheme.primaryColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModalHistoryItem(
    Map<String, dynamic> item,
    Color glassColor,
    Color glassBorder,
    Color textColor,
  ) {
    return Opacity(
      opacity: 0.6,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12, left: 4),
        child: Row(
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: FinTrackTheme.primaryColor,
              size: 16,
            ),
            const SizedBox(width: 12),
            Text(
              item['title'],
              style: TextStyle(color: textColor, fontSize: 13),
            ),
            const Spacer(),
            Text(
              "\$${item['amount']}",
              style: TextStyle(
                color: textColor,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(
    BuildContext context,
    double percentage,
    String spentAmount,
    String limitAmount,
    bool isDarkMode,
  ) {
    final textColor = FinTrackTheme.getTextColor(isDarkMode);

    return Column(
      children: [
        Stack(
          children: [
            // 1. The Background Track
            Container(
              height: 12,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            // 2. The Active Progress Bar
            AnimatedContainer(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              height: 12,
              // Calculate width based on screen width and percentage
              width: (MediaQuery.of(context).size.width - 64) * percentage,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    FinTrackTheme.primaryColor,
                    FinTrackTheme.primaryColor.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: FinTrackTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // 3. Amount Labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "$spentAmount spent",
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Text(
              "Limit: $limitAmount",
              style: TextStyle(
                color: textColor.withOpacity(0.4),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
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

  Widget _buildStatLabel(String text, Color textColor) {
    return Text(
      text,
      style: TextStyle(
        color: textColor.withOpacity(0.4),
        fontSize: 10,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildQuickCategoryRow(
    String name,
    String amount,
    Color color,
    Color textColor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Text(
            name,
            style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          Text(
            amount,
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  List<Map<String, Object>> get actions => [
    {'icon': Icons.add, 'label': 'Add', 'onTap': _showAddExpenseSheet},
    {
      'icon': Icons.calendar_today_rounded,
      'label': 'Planned',
      'onTap': _showPlannedSheet,
    },
    {
      'icon': Icons.bar_chart_rounded,
      'label': 'Stats',
      'onTap': _showQuickStatsSheet,
    },
  ];
  onTapCategory(CategoryItem category) {
    setState(() {
      selectedCategory = category;
    });
  }

  @override
  Widget build(BuildContext context) {
    final monthlyStats = ref.watch(
      monthlyIncomeExpensesProvider(ref.watch(activeMonthProvider)),
    );
    final transactionHistoryProv = ref.watch(transactionHistory);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = FinTrackTheme.getTextColor(isDarkMode);
    final glassColor = FinTrackTheme.getGlassColor(isDarkMode);
    final glassBorder = FinTrackTheme.getGlassBorder(isDarkMode);

    return Scaffold(
      // backgroundColor: Color(0xFFFFFFFF),
      extendBody: true, // Allows bottom nav to be transparent/blur
      body: SizedBox(
        height: double.infinity,
        child: Stack(
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

            _selectedIndex == 0
                ? SafeArea(
                    bottom: false,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- HEADER ---
                          
                          _buildHeader(textColor, isDarkMode),
                          const SizedBox(height: 24),

                          // --- TOTAL BALANCE CARD ---
                          _buildBalanceCard(
                            glassColor,
                            glassBorder,
                            textColor,
                            isDarkMode,
                          ),
                          const SizedBox(height: 24),

                          // --- QUICK ACTIONS ---
                          SectionHeader(
                            title: "Quick Actions",
                            textColor: textColor,
                          ),
                          const SizedBox(height: 16),
                          QuickActions(
                            isDarkMode: isDarkMode,
                            textColor: textColor,
                            actionsList: actions,
                          ),
                          const SizedBox(height: 32),

                          // --- RECENT TRANSACTIONS ---
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SectionHeader(
                                title: "Recent Activity",
                                textColor: textColor,
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const HistoryPage(),
                                    ),
                                  );
                                },
                                child: Text(
                                  "See All",
                                  style: TextStyle(
                                    color: FinTrackTheme.primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          _buildTransactionList(
                            glassColor,
                            glassBorder,
                            textColor,
                            isDarkMode,
                          ),

                          const SizedBox(
                            height: 120,
                          ), // Space for floating bottom nav
                        ],
                      ),
                    ),
                  )
                : _selectedIndex == 1
                ? SafeArea(bottom: false, child: WalletPage())
                : _selectedIndex == 2
                ? SafeArea(bottom: false, child: AnalyticsPage())
                : SafeArea(
                    bottom: false,
                    child: ProfilePage(toggleTheme: toggleTheme),
                  ),
            // --- FLOATING GLASS BOTTOM NAV ---
            FloatingNav(
              selectedIndex: _selectedIndex,
              isDarkMode: isDarkMode,
              onItemSelected: (index) => setState(() => _selectedIndex = index),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Color textColor, bool isDarkMode) {
    final userData = ref.watch(userDataProvider);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8),
            Text(
              "Good Morning,",
              style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 16),
            ),
            userData.when(
              data: (data) {
                final userName = data != null ? data['displayName'] ?? 'User' : 'User';
                return Text(
                  userName,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => const Text("Error loading user"),
            ),
            
          ],
        ),
      ],
    );
  }

  Widget _buildBalanceCard(
    Color glassColor,
    Color glassBorder,
    Color textColor,
    bool isDarkMode,
  ) {
    final totalBalance = ref.watch(totalBalanceProvider);
    final stats =  ref.watch(monthlyIncomeExpensesProvider(ref.watch(activeMonthProvider)));
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: FinTrackTheme.primaryColor.withOpacity(
              isDarkMode ? 0.15 : 0.8,
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                FinTrackTheme.primaryColor,
                const Color(0xFF00897B).withOpacity(0.9),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Total Balance",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  IconButton(
                    icon: Icon(
                      _isBalanceVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.white70,
                    ),
                    onPressed: () =>
                        setState(() => _isBalanceVisible = !_isBalanceVisible),
                  ),
                ],
              ),
              Text(
                _isBalanceVisible
                    ? CurrencyFormatter.format(totalBalance)
                    : "*******",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _buildStatItem(Icons.arrow_upward, "Income", CurrencyFormatter.format(stats['totalIncome'])),
                  const SizedBox(width: 24),
                  _buildStatItem(Icons.arrow_downward, "Expenses", CurrencyFormatter.format(stats['totalExpense'])),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String amount) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.2),
          ),
          child: Icon(icon, color: Colors.white, size: 14),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            Text(
              amount,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTransactionList(
    Color glassColor,
    Color glassBorder,
    Color textColor,
    bool isDarkMode,
  ) {
    final transactionHistoryProv = ref.watch(transactionHistory);
    // Empty data for testing
    final List<Map<String, dynamic>> transactions = [
      {
        "title": "Monthly Salary",
        "category": "Income",
        "amount": "5,000.00",
        "isIncome": true,
      },
      {
        "title": "Grocery Store",
        "category": "Food",
        "amount": "45.00",
        "isIncome": false,
      },
      {
        "title": "Freelance Gig",
        "category": "Work",
        "amount": "250.00",
        "isIncome": true,
      },
      {
        "title": "Shell Gas",
        "category": "Transport",
        "amount": "60.00",
        "isIncome": false,
      },
    ];

    // 1. Check if the list is empty
    if (transactions.isEmpty) {
      return _buildEmptyState(textColor, isDarkMode);
    }

    // 2. Return the list if data exists
    return transactionHistoryProv.when(
      data: (transactions) {
        if (transactions.isEmpty) {
          return _buildEmptyState(textColor, isDarkMode);
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final item = transactions[index];
            return HistoryItem(
              item: item,
              textColor: textColor,
              glassColor: glassColor,
              glassBorder: glassBorder,
            );
          },
        );
      },
      loading: () => Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }

  // 3. The Empty State Widget
  Widget _buildEmptyState(Color textColor, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // A soft glassmorphic icon container
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.03),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_rounded,
                size: 64,
                color: textColor.withOpacity(0.2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "No Transactions Yet",
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Your spending history will appear here.\nTap the '+' button to get started.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor.withOpacity(0.4),
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem({
    required String walletName,
    required String title,
    required String category,
    required double amount,
    required bool isExpense,
    required Color textColor,
    required bool isDarkMode,
    required Color glassColor,
    required Color glassBorder,
  }) {
    // Use Emerald for income, and either Red or Standard Text for expense
    final Color statusColor = isExpense
        ? Colors.redAccent
        : FinTrackTheme.primaryColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: glassColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: glassBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isExpense
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_downward_rounded,
              color: statusColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  category,
                  style: TextStyle(
                    color: textColor.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${isExpense ? '-' : '+'} ${CurrencyFormatter.format(amount)}",
                style: TextStyle(
                  color: isExpense ? textColor : statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                walletName,
                style: TextStyle(
                  color: textColor.withOpacity(0.3),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingBottomNav(
    Color glassColor,
    Color glassBorder,
    bool isDarkMode,
  ) {
    return Positioned(
      bottom: 30,
      left: 20,
      right: 20,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.black.withOpacity(0.4)
                  : Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: glassBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home_rounded, 0),
                _buildNavItem(Icons.account_balance_wallet_rounded, 1),
                _buildNavItem(Icons.analytics_rounded, 2),
                _buildNavItem(Icons.person_rounded, 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Icon(
        icon,
        color: isSelected
            ? FinTrackTheme.primaryColor
            : Colors.grey.withOpacity(0.5),
        size: 28,
      ),
    );
  }
}
