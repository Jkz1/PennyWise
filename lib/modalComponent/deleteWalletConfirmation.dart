import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme.dart';

void showDeleteConfirmation(BuildContext context, String walletName, VoidCallback onConfirm, bool isDarkMode) {
  showDialog(
    context: context,
    builder: (context) => BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: AlertDialog(
        backgroundColor: isDarkMode ? Colors.black.withOpacity(0.8) : Colors.white.withOpacity(0.9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28), side: BorderSide(color: Colors.white.withOpacity(0.1))),
        title: Text(
          "Delete $walletName?",
          style: TextStyle(color: FinTrackTheme.getTextColor(isDarkMode), fontWeight: FontWeight.bold),
        ),
        content: Text(
          "All transaction data linked to this wallet will be permanently removed. This action cannot be undone.",
          style: TextStyle(color: FinTrackTheme.getTextColor(isDarkMode).withOpacity(0.7), fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("CANCEL", style: TextStyle(color: isDarkMode ? Colors.white38 : Colors.black38, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            onPressed: () {
              onConfirm();
              Navigator.pop(context);
            },
            child: const Text("DELETE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    ),
  );
}