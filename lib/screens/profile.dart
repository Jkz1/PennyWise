import 'package:flutter/material.dart';
import '../theme.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = FinTrackTheme.getTextColor(isDarkMode);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 20),
          
          // 1. PROFILE HEADER (Identity)
          _buildProfileHeader(isDarkMode, textColor),

          const SizedBox(height: 32),

          // 2. SETTINGS GROUPS
          _buildSettingsGroup("Account Settings", [
            _buildSettingTile(Icons.person_outline_rounded, "Personal Information", isDarkMode),
            _buildSettingTile(Icons.account_balance_wallet_outlined, "My Wallets", isDarkMode),
            _buildSettingTile(Icons.notifications_none_rounded, "Notifications", isDarkMode),
          ], isDarkMode),

          _buildSettingsGroup("Security & Privacy", [
            _buildSettingTile(Icons.lock_outline_rounded, "Face ID / Passcode", isDarkMode, trailing: Switch(value: true, onChanged: (v){}, activeColor: FinTrackTheme.primaryColor)),
            _buildSettingTile(Icons.visibility_off_outlined, "Incognito Mode", isDarkMode, trailing: Switch(value: false, onChanged: (v){}, activeColor: FinTrackTheme.primaryColor)),
          ], isDarkMode),

          _buildSettingsGroup("App Settings", [
            _buildSettingTile(Icons.dark_mode_outlined, "Dark Mode", isDarkMode, trailing: const Icon(Icons.chevron_right_rounded)),
            _buildSettingTile(Icons.language_rounded, "Currency (USD)", isDarkMode),
          ], isDarkMode),

          // 3. LOGOUT BUTTON
          const SizedBox(height: 20),
          TextButton(
            onPressed: () {},
            child: const Text("Logout", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
          
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(bool isDarkMode, Color textColor) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 55,
              backgroundColor: FinTrackTheme.primaryColor.withOpacity(0.1),
              child: const Icon(Icons.person_rounded, size: 60, color: Colors.grey),
            ),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: FinTrackTheme.primaryColor, shape: BoxShape.circle),
              child: const Icon(Icons.edit_rounded, color: Colors.white, size: 18),
            )
          ],
        ),
        const SizedBox(height: 16),
        Text("Alex Thompson", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
        Text("alex.t@finmail.com", style: TextStyle(color: textColor.withOpacity(0.4), fontSize: 14)),
      ],
    );
  }

  Widget _buildSettingsGroup(String title, List<Widget> tiles, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 16, 24, 8),
          child: Text(title, style: TextStyle(color: FinTrackTheme.primaryColor, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.02),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(children: tiles),
        ),
      ],
    );
  }

  Widget _buildSettingTile(IconData icon, String title, bool isDarkMode, {Widget? trailing}) {
    return ListTile(
      leading: Icon(icon, color: FinTrackTheme.getTextColor(isDarkMode).withOpacity(0.6), size: 22),
      title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      trailing: trailing ?? Icon(Icons.chevron_right_rounded, color: Colors.grey.withOpacity(0.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
    );
  }
}