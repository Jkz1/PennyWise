import 'package:flutter/material.dart';
import 'package:penny_wise/modalComponent/deleteWalletConfirmation.dart';
import '../theme.dart';

class WalletActionBar extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onTransfer;
  final VoidCallback onAdd;
  final VoidCallback onDelete;
  bool isDeleteMode;

  WalletActionBar({
    super.key,
    required this.isDarkMode,
    required this.onTransfer,
    required this.onAdd,
    required this.onDelete,
    required this.isDeleteMode,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = FinTrackTheme.getTextColor(isDarkMode);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
          context,
          Icons.swap_horiz_rounded,
          "Transfer",
          onTransfer,
          textColor,
        ),
        _buildActionButton(
          context,
          Icons.add_box_rounded,
          "Add Wallet",
          onAdd,
          textColor,
        ),
        _buildActionButton(
          context,
          isDeleteMode ? Icons.check : Icons.delete_sweep_rounded,
          "Delete",
          onDelete,
          isDeleteMode ? Colors.lightGreen : Colors.redAccent,
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
    Color color,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
