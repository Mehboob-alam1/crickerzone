import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          _buildSection('App Settings'),
          _buildSettingTile(Icons.dark_mode, 'Dark Mode', 'Enabled', true),
          _buildSettingTile(Icons.notifications, 'Notifications', 'On', true),
          _buildSection('About'),
          _buildSettingTile(Icons.info_outline, 'Version', '1.0.0', false),
          _buildSettingTile(Icons.policy, 'Privacy Policy', '', false),
          _buildSettingTile(Icons.star_rate, 'Rate Us', '', false),
        ],
      ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildSettingTile(IconData icon, String title, String trailing, bool isSwitch) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(title),
      trailing: isSwitch 
        ? Switch(value: true, onChanged: (v) {}, activeColor: AppColors.primary)
        : Text(trailing, style: const TextStyle(color: AppColors.textMuted)),
      onTap: () {},
    );
  }
}
