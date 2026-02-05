import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme.dart';
import '../components/backgroundBlob.dart';

class PlannedPage extends StatefulWidget {
  const PlannedPage({super.key});

  @override
  State<PlannedPage> createState() => _PlannedPageState();
}

class _PlannedPageState extends State<PlannedPage> {
  // Mock data for upcoming bills
  final List<Map<String, dynamic>> _upcomingPlans = [
    {
      "title": "Apartment Rent",
      "amount": "1,200.00",
      "date": "Due in 3 days",
      "icon": Icons.home_rounded,
    },
    {
      "title": "Netflix Sub",
      "amount": "15.99",
      "date": "Due tomorrow",
      "icon": Icons.subscriptions_rounded,
    },
  ];

  // Mock data for history
  final List<Map<String, dynamic>> _paidHistory = [
    {"title": "Internet Bill", "amount": "60.00", "date": "Paid Jan 12"},
    {"title": "Gym Membership", "amount": "45.00", "date": "Paid Jan 05"},
  ];

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = FinTrackTheme.getTextColor(isDarkMode);
    final glassColor = FinTrackTheme.getGlassColor(isDarkMode);
    final glassBorder = FinTrackTheme.getGlassBorder(isDarkMode);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Planned Payments",
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreatePlanSheet(context, isDarkMode, textColor),
        backgroundColor: FinTrackTheme.primaryColor,
        icon: const Icon(Icons.add_task_rounded, color: Colors.white),
        label: const Text(
          "ADD NEW PLAN",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
      body: Stack(
        children: [
          // 1. Background Blobs stay fixed in the Stack
          Backgroundblob(
            top: -50,
            left: -50,
            color: FinTrackTheme.deepIndigo,
            isDarkMode: isDarkMode,
          ),
          Backgroundblob(
            bottom: -50,
            right: -50,
            color: FinTrackTheme.primaryColor,
            isDarkMode: isDarkMode,
          ),

          SafeArea(
            child: LayoutBuilder(
              // Allows us to get the screen height
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics:
                      const AlwaysScrollableScrollPhysics(), // Ensures you can always "pull" the glass effect
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints
                          .maxHeight, // FORCES the content to be at least full screen
                    ),
                    child: IntrinsicHeight(
                      // Helps children expand to fill that space if needed
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- UPCOMING SECTION ---
                          _buildSectionHeader(
                            "Upcoming Obligations",
                            textColor,
                          ),
                          const SizedBox(height: 16),
                          ..._upcomingPlans.map(
                            (item) => _buildPlannedCard(
                              item,
                              glassColor,
                              glassBorder,
                              textColor,
                            ),
                          ),

                          const SizedBox(height: 40),

                          // --- HISTORY SECTION ---
                          _buildSectionHeader("Recently Settled", textColor),
                          const SizedBox(height: 16),
                          ..._paidHistory.map(
                            (item) => _buildHistoryItem(
                              item,
                              glassColor,
                              glassBorder,
                              textColor,
                            ),
                          ),

                          // The Spacer will now push everything to fill the screen
                          const Spacer(),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color textColor) {
    return Text(
      title,
      style: TextStyle(
        color: textColor.withOpacity(0.5),
        fontSize: 14,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildPlannedCard(
    Map<String, dynamic> item,
    Color glassColor,
    Color glassBorder,
    Color textColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: glassColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: glassBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: FinTrackTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(item['icon'], color: FinTrackTheme.primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'],
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item['date'],
                  style: const TextStyle(
                    color: Colors.orangeAccent,
                    fontSize: 12,
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
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  // Logic to log this expense to home page
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: FinTrackTheme.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    "LOG NOW",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(
    Map<String, dynamic> item,
    Color glassColor,
    Color glassBorder,
    Color textColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: glassColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: glassBorder),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_rounded,
            color: FinTrackTheme.primaryColor.withOpacity(0.5),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'],
                  style: TextStyle(
                    color: textColor.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  item['date'],
                  style: TextStyle(
                    color: textColor.withOpacity(0.4),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            "\$${item['amount']}",
            style: TextStyle(
              color: textColor.withOpacity(0.6),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // --- ADD NEW PLAN BOTTOM SHEET ---
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
                    _buildNaturalChip(
                      Icons.home_rounded,
                      "Rent",
                      true,
                      isDarkMode,
                    ),
                    _buildNaturalChip(
                      Icons.bolt_rounded,
                      "Utility",
                      false,
                      isDarkMode,
                    ),
                    _buildNaturalChip(
                      Icons.subscriptions_rounded,
                      "Sub",
                      false,
                      isDarkMode,
                    ),
                    _buildNaturalChip(
                      Icons.shield_rounded,
                      "Insur.",
                      false,
                      isDarkMode,
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

  // --- HELPER WIDGETS FOR THE NATURAL UI ---
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

  Widget _buildSmallToggle(
    String label,
    bool isSelected,
    VoidCallback onTap,
    bool isDarkMode,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? FinTrackTheme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildNaturalChip(
    IconData icon,
    String label,
    bool isSelected,
    bool isDarkMode,
  ) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected
            ? FinTrackTheme.primaryColor
            : (isDarkMode
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.05)),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected
              ? FinTrackTheme.primaryColor
              : Colors.white.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.white : FinTrackTheme.primaryColor,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : (isDarkMode ? Colors.white70 : Colors.black87),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: Colors.grey,
        fontSize: 10,
        fontWeight: FontWeight.bold,
        letterSpacing: 1,
      ),
    );
  }
}
