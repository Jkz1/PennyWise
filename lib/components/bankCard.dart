import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:penny_wise/modalComponent/deleteWalletConfirmation.dart';
import '../theme.dart';
// ... imports unchanged

class BankCard extends StatelessWidget {
  final String name;
  final String balance;
  final String accountNumber;
  final bool isDeleteMode;
  final VoidCallback onDelete; // Use VoidCallback for cleaner types
  final Color color;

  const BankCard({
    // Added const and proper types
    super.key,
    required this.name,
    required this.balance,
    required this.accountNumber,
    required this.color,
    required this.isDeleteMode,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = FinTrackTheme.getTextColor(isDarkMode);

    return AnimatedContainer(
      // Added animation for the color shift
      duration: const Duration(milliseconds: 300),
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: AnimatedContainer(
                // Animates the gradient/border
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      isDeleteMode
                          ? Colors.redAccent.withOpacity(0.2)
                          : color.withOpacity(isDarkMode ? 0.15 : 0.1),
                      isDarkMode
                          ? Colors.black.withOpacity(0.3)
                          : Colors.white.withOpacity(0.4),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: isDeleteMode
                        ? Colors.redAccent
                        : color.withOpacity(0.3),
                    width: isDeleteMode
                        ? 2.0
                        : 1.5, // Slightly thicker border in delete mode
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        // Only show card icon when NOT deleting
                        if (!isDeleteMode)
                          Icon(
                            Icons.credit_card_rounded,
                            color: color.withOpacity(0.8),
                          ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          balance,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          accountNumber,
                          style: TextStyle(
                            color: textColor.withOpacity(0.4),
                            fontSize: 12,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Floating Delete Button for better touch target
          if (isDeleteMode)
            Positioned(
              top: -5,
              right: -5,
              child: GestureDetector(
                onTap: () {
                  showDeleteConfirmation(context, name, onDelete, isDarkMode);
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 4),
                    ],
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 18),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
