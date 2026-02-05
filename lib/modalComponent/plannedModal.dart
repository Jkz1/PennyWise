// ignore_for_file: unused_element

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:penny_wise/components/categoryChip.dart';
import 'package:penny_wise/components/sheetLabel.dart';
import 'package:penny_wise/components/smallToggle.dart';
import 'package:penny_wise/model/expenseCategory.dart';
import 'package:penny_wise/theme.dart';

class PlannedModal extends StatefulWidget {
  const PlannedModal({super.key});

  @override
  State<PlannedModal> createState() => _PlannedModalState();
}

class _PlannedModalState extends State<PlannedModal> {
  CategoryItem selectedCategory = categories_expenses[0];

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final textColor = FinTrackTheme.getTextColor(isDarkMode);
    final glassColor = FinTrackTheme.getGlassColor(isDarkMode);
    final glassBorder = FinTrackTheme.getGlassBorder(isDarkMode);

    // Mock data local to the sheet
    final List<Map<String, dynamic>> upcoming = [
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

    final List<Map<String, dynamic>> history = [
      {"title": "Internet Bill", "amount": "60.00", "date": "Paid Jan 12"},
    ];
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
          builder: (context, setSheetState) {
            onTapCategory(CategoryItem category) {
              setSheetState(() {
                selectedCategory = category;
              });
            }

            return BackdropFilter(
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
                              SmallToggle(
                                label: "Monthly",
                                isSelected: isRecurring,
                                isDarkMode: isDarkMode,
                                onTap: () =>
                                    setSheetState(() => isRecurring = true),
                              ),
                              SmallToggle(
                                label: "Once",
                                isSelected: !isRecurring,
                                isDarkMode: isDarkMode,
                                onTap: () =>
                                    setSheetState(() => isRecurring = false),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // 2. INTEGRATED TITLE INPUT
                    SheetLabel(
                      isDarkMode: isDarkMode,
                      text: "WHAT ARE WE PLANNING?",
                    ),
                    TextField(
                      style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: "e.g. Health Insurance",
                        hintStyle: TextStyle(
                          color: textColor.withOpacity(0.15),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: textColor.withOpacity(0.1),
                          ),
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
                              SheetLabel(
                                isDarkMode: isDarkMode,
                                text: "AMOUNT",
                              ),
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
                                    color: FinTrackTheme.primaryColor
                                        .withOpacity(0.5),
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
                              SheetLabel(
                                isDarkMode: isDarkMode,
                                text: "DUE DATE",
                              ),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () {}, // Trigger Date Picker
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
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
                    SheetLabel(isDarkMode: isDarkMode, text: "CATEGORY"),
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
            );
          },
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
                  onPressed: () =>
                      _showCreatePlanSheet(context, isDarkMode, textColor),
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
                    ...upcoming.map(
                      (item) => _buildModalPlannedCard(
                        item,
                        glassColor,
                        glassBorder,
                        textColor,
                      ),
                    ),

                    const SizedBox(height: 32),
                    SheetLabel(
                      isDarkMode: isDarkMode,
                      text: "RECENTLY SETTLED",
                    ),
                    const SizedBox(height: 16),
                    ...history.map(
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
