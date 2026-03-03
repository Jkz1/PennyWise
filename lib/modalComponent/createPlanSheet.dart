import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:penny_wise/components/categoryChip.dart';
import 'package:penny_wise/components/sheetLabel.dart';
import 'package:penny_wise/components/smallToggle.dart';
import 'package:penny_wise/model/expenseCategory.dart';
import 'package:penny_wise/services/planned.dart';
import 'package:penny_wise/theme.dart';
import 'package:penny_wise/utils/formatters.dart';

void showCreatePlanSheet(
  BuildContext context,
  bool isDarkMode,
  Color textColor,
) {
  bool isRecurring = true;
  DateTime? _selectedDate;
  CategoryItem selectedCategory = categories_expenses[0];
  TextEditingController _amountController = TextEditingController();
  TextEditingController _titleController = TextEditingController();
  dynamic cleanAmount = 0.0;
  bool realTimeValidation = false;

  handlePlanCreation()async{
    if(_titleController.text.trim().isEmpty || cleanAmount <= 0 || _selectedDate == null) {
      realTimeValidation = true;
      return;
    }
    realTimeValidation = true;
    final ps = PlannedService();
    try{
      await ps.addPlannedItem(title: _titleController.text, category: selectedCategory.name, amount: cleanAmount, dueDate: _selectedDate!, isMonthly: isRecurring);
      Navigator.pop(context);
    }
    catch(e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to create plan: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
      Navigator.pop(context);
      Navigator.pop(context);
    }
  }

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
            ),
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
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
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SheetLabel(
                          isDarkMode: isDarkMode,
                          text: "WHAT ARE WE PLANNING?",
                        ),
                        TextField(
                          onChanged: (v) {
                            setSheetState(() {});
                          },
                          controller: _titleController,
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
                        if (_titleController.text.isEmpty && realTimeValidation)
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
                                          "Title is Required",
                                          style: TextStyle(
                                            color: Colors.redAccent,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        const SizedBox(height: 32),
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
                                    controller: _amountController,
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(
                                      color: FinTrackTheme.primaryColor,
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      CurrencyInputFormatter(),
                                    ],
                                    onChanged: (v) {
                                      cleanAmount =
                                          CurrencyFormatter.getCleanAmount(v);
                                      setSheetState(
                                        () {},
                                      ); // Trigger UI update for formatted value
                                    },
                                    decoration: InputDecoration(
                                      prefixStyle: TextStyle(
                                        color: FinTrackTheme.primaryColor
                                            .withOpacity(0.5),
                                        fontSize: 20,
                                      ),
                                      border: InputBorder.none,
                                      hintText: "0.00",
                                      hintStyle: TextStyle(
                                        color: Colors.white.withOpacity(0.2),
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),
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
                                    onTap: () async {
                                      // 1. Show the date picker
                                      final DateTime? picked =
                                          await showDatePicker(
                                            context: context,
                                            initialDate:
                                                _selectedDate ?? DateTime.now(),
                                            firstDate: DateTime(
                                              2000,
                                            ), // Earliest date allowed
                                            lastDate: DateTime(
                                              2100,
                                            ), // Latest date allowed
                                          );

                                      // 2. If the user didn't cancel, update the state
                                      if (picked != null &&
                                          picked != _selectedDate) {
                                        setSheetState(() {
                                          _selectedDate = picked;
                                        });
                                      }
                                    },
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
                                            // 3. Display the date formatted, or "Select Date" if null
                                            _selectedDate == null
                                                ? "Select Date"
                                                : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
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
                        if ((_selectedDate == null || cleanAmount <= 0) && realTimeValidation)
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
                              child: Column(
                                children: [
                                  if(cleanAmount <= 0)
                                  Row(
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
                                              "Invalid Amount",
                                              style: TextStyle(
                                                color: Colors.redAccent,
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  if(_selectedDate == null && cleanAmount <= 0)
                                  Divider(color: Colors.grey,),
                                  if(_selectedDate == null)
                                  Row(
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
                                              "Invalid Date",
                                              style: TextStyle(
                                                color: Colors.redAccent,
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        const SizedBox(height: 32),
                        SheetLabel(isDarkMode: isDarkMode, text: "CATEGORY"),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: categories_expenses.map((cat) {
                            return Categorychip(
                              selectedCategory: selectedCategory,
                              val: cat,
                              isDarkMode: isDarkMode,
                              onTap: onTapCategory,
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: (_selectedDate == null || cleanAmount <= 0 || _titleController.text.isEmpty) && realTimeValidation
                      ? null
                      : () {
                          handlePlanCreation();
                          setSheetState(() {}); // Refresh to show validation errors if any
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FinTrackTheme.primaryColor,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
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
