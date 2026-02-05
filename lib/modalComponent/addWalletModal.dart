import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme.dart';

void showAddWalletModal(BuildContext context, bool isDarkMode) {
  final List<Color> selectorColors = [
    Colors.blueAccent, Colors.amberAccent, Colors.orangeAccent, 
    Colors.purpleAccent, Colors.pinkAccent, Colors.tealAccent
  ];
  Color selectedColor = selectorColors[0];

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => StatefulBuilder(
      builder: (context, setModalState) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, top: 24, left: 32, right: 32),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.black.withOpacity(0.8) : Colors.white.withOpacity(0.9),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 24),
              Text("Create New Wallet", style: TextStyle(color: FinTrackTheme.getTextColor(isDarkMode), fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 32),
              
              // Wallet Name Input
              TextField(
                autofocus: true,
                style: TextStyle(color: FinTrackTheme.getTextColor(isDarkMode), fontSize: 18),
                decoration: InputDecoration(
                  labelText: "Wallet Name",
                  labelStyle: TextStyle(color: FinTrackTheme.primaryColor),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: FinTrackTheme.primaryColor.withOpacity(0.2))),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: FinTrackTheme.primaryColor)),
                ),
              ),
              
              const SizedBox(height: 32),
              Text("SELECT COLOR", style: TextStyle(color: FinTrackTheme.getTextColor(isDarkMode).withOpacity(0.4), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              const SizedBox(height: 16),
              
              // Color Selector
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: selectorColors.length,
                  itemBuilder: (context, index) => GestureDetector(
                    onTap: () => setModalState(() => selectedColor = selectorColors[index]),
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      width: 50,
                      decoration: BoxDecoration(
                        color: selectorColors[index].withOpacity(0.3),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selectedColor == selectorColors[index] ? selectorColors[index] : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: selectedColor == selectorColors[index] 
                          ? Icon(Icons.check, color: selectorColors[index], size: 20) 
                          : null,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: FinTrackTheme.primaryColor,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text("ADD WALLET", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    ),
  );
}