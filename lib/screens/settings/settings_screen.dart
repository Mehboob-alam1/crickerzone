import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/constants/colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Toggle states
  bool _darkMode        = true;
  bool _notifications   = true;
  bool _liveAlerts      = true;
  bool _scoreUpdates    = true;
  bool _wicketAlerts    = false;
  bool _matchReminders  = true;

  // Selected values
  String _language      = 'English';
  String _refreshRate   = '30s';
  String _commentaryLang= 'English';

  static const _languages = ['English', 'Hindi', 'Urdu', 'Tamil', 'Bengali'];
  static const _refreshRates = ['15s', '30s', '1m', '2m', '5m'];
  static const _commentaryLangs = ['English', 'Hindi', 'Urdu', 'Tamil'];

  void _showPicker(
      BuildContext context,
      String title,
      List<String> options,
      String current,
      ValueChanged<String> onSelect,
      ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _PickerSheet(
        title: title,
        options: options,
        current: current,
        onSelect: onSelect,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _sectionLabel('APP PREFERENCES', Icons.tune_rounded),
                  _SettingsGroup(children: [
                    _ToggleTile(
                      icon: Icons.dark_mode_rounded,
                      color: const Color(0xFF6A1B9A),
                      title: 'Dark Mode',
                      subtitle: 'Always use dark theme',
                      value: _darkMode,
                      onChanged: (v) => setState(() => _darkMode = v),
                    ),
                    _PickerTile(
                      icon: Icons.language_rounded,
                      color: const Color(0xFF1565C0),
                      title: 'Language',
                      value: _language,
                      onTap: () => _showPicker(
                        context, 'Select Language', _languages, _language,
                            (v) => setState(() => _language = v),
                      ),
                    ),
                    _PickerTile(
                      icon: Icons.speed_rounded,
                      color: const Color(0xFF2E7D32),
                      title: 'Score Refresh Rate',
                      value: _refreshRate,
                      onTap: () => _showPicker(
                        context, 'Refresh Rate', _refreshRates, _refreshRate,
                            (v) => setState(() => _refreshRate = v),
                      ),
                    ),
                    _PickerTile(
                      icon: Icons.record_voice_over_rounded,
                      color: const Color(0xFFAD1457),
                      title: 'Commentary Language',
                      value: _commentaryLang,
                      onTap: () => _showPicker(
                        context, 'Commentary Language', _commentaryLangs, _commentaryLang,
                            (v) => setState(() => _commentaryLang = v),
                      ),
                    ),
                  ]),

                  _sectionLabel('NOTIFICATIONS', Icons.notifications_rounded),
                  _SettingsGroup(children: [
                    _ToggleTile(
                      icon: Icons.notifications_active_rounded,
                      color: AppColors.primary,
                      title: 'Push Notifications',
                      subtitle: 'Receive all app notifications',
                      value: _notifications,
                      onChanged: (v) => setState(() {
                        _notifications = v;
                        if (!v) {
                          _liveAlerts = false;
                          _scoreUpdates = false;
                          _wicketAlerts = false;
                          _matchReminders = false;
                        }
                      }),
                    ),
                    _ToggleTile(
                      icon: Icons.sensors_rounded,
                      color: const Color(0xFFE53935),
                      title: 'Live Match Alerts',
                      subtitle: 'Get notified for live matches',
                      value: _liveAlerts && _notifications,
                      onChanged: _notifications
                          ? (v) => setState(() => _liveAlerts = v)
                          : null,
                    ),
                    _ToggleTile(
                      icon: Icons.scoreboard_rounded,
                      color: const Color(0xFF1565C0),
                      title: 'Score Updates',
                      subtitle: 'Ball-by-ball score updates',
                      value: _scoreUpdates && _notifications,
                      onChanged: _notifications
                          ? (v) => setState(() => _scoreUpdates = v)
                          : null,
                    ),
                    _ToggleTile(
                      icon: Icons.sports_cricket_rounded,
                      color: const Color(0xFFE53935),
                      title: 'Wicket Alerts',
                      subtitle: 'Alert when a wicket falls',
                      value: _wicketAlerts && _notifications,
                      onChanged: _notifications
                          ? (v) => setState(() => _wicketAlerts = v)
                          : null,
                    ),
                    _ToggleTile(
                      icon: Icons.event_rounded,
                      color: const Color(0xFF2E7D32),
                      title: 'Match Reminders',
                      subtitle: '30 min before match starts',
                      value: _matchReminders && _notifications,
                      onChanged: _notifications
                          ? (v) => setState(() => _matchReminders = v)
                          : null,
                    ),
                  ]),

                  _sectionLabel('ACCOUNT', Icons.person_rounded),
                  _SettingsGroup(children: [
                    _NavTile(
                      icon: Icons.favorite_rounded,
                      color: const Color(0xFFE53935),
                      title: 'Favourites',
                      subtitle: 'Manage saved teams & players',
                      onTap: () {},
                    ),
                    _NavTile(
                      icon: Icons.history_rounded,
                      color: const Color(0xFF1565C0),
                      title: 'Watch History',
                      subtitle: 'Recently viewed matches',
                      onTap: () {},
                    ),
                    _NavTile(
                      icon: Icons.cloud_sync_rounded,
                      color: const Color(0xFF2E7D32),
                      title: 'Sync Data',
                      subtitle: 'Sync preferences across devices',
                      onTap: () {},
                    ),
                  ]),

                  _sectionLabel('ABOUT', Icons.info_outline_rounded),
                  _SettingsGroup(children: [
                    _NavTile(
                      icon: Icons.privacy_tip_rounded,
                      color: const Color(0xFF6A1B9A),
                      title: 'Privacy Policy',
                      onTap: () {},
                    ),
                    _NavTile(
                      icon: Icons.description_rounded,
                      color: const Color(0xFF37474F),
                      title: 'Terms of Service',
                      onTap: () {},
                    ),
                    _NavTile(
                      icon: Icons.star_rate_rounded,
                      color: const Color(0xFFFFA000),
                      title: 'Rate the App',
                      subtitle: 'Love Score Zone? Leave a review!',
                      onTap: () {},
                    ),
                    _NavTile(
                      icon: Icons.help_outline_rounded,
                      color: const Color(0xFF1565C0),
                      title: 'Help & Support',
                      onTap: () {},
                    ),
                    _InfoTile(
                      icon: Icons.info_rounded,
                      color: AppColors.textMuted,
                      title: 'App Version',
                      value: '1.0.0 (build 42)',
                    ),
                  ]),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 14, 20, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A0D00), AppColors.background],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: Colors.white.withOpacity(0.07)),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: AppColors.primary, size: 14),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'SETTINGS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.4,
                ),
              ),
              Text(
                'Preferences & account',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Profile card ──────────────────────────────────────────────────────────

  Widget _sectionLabel(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 10),
      child: Row(
        children: [
          Icon(icon, size: 13, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            title,
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.6,
            ),
          ),
        ],
      ),
    );
  }

}

// ─── SETTINGS GROUP ───────────────────────────────────────────────────────────

class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;
  const _SettingsGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      duration: const Duration(milliseconds: 350),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Column(
          children: children.asMap().entries.map((e) {
            final isLast = e.key == children.length - 1;
            return Column(
              children: [
                e.value,
                if (!isLast)
                  const Divider(
                    color: Colors.white10,
                    height: 1,
                    indent: 56,
                  ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ─── TOGGLE TILE ──────────────────────────────────────────────────────────────

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const _ToggleTile({
    required this.icon,
    required this.color,
    required this.title,
    this.subtitle,
    required this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onChanged == null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          _IconBox(icon: icon, color: disabled ? AppColors.textMuted : color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: disabled ? AppColors.textMuted : Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: TextStyle(
                        color: AppColors.textMuted, fontSize: 11),
                  ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: color,
            inactiveThumbColor: AppColors.textMuted,
            inactiveTrackColor: AppColors.cardGrey,
            trackOutlineColor:
            WidgetStateProperty.all(Colors.transparent),
          ),
        ],
      ),
    );
  }
}

// ─── PICKER TILE ──────────────────────────────────────────────────────────────

class _PickerTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String value;
  final VoidCallback onTap;

  const _PickerTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            _IconBox(icon: icon, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              ),
            ),
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.10),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color.withOpacity(0.22)),
              ),
              child: Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.chevron_right_rounded,
                color: AppColors.textMuted, size: 18),
          ],
        ),
      ),
    );
  }
}

// ─── NAV TILE ─────────────────────────────────────────────────────────────────

class _NavTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _NavTile({
    required this.icon,
    required this.color,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            _IconBox(icon: icon, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: TextStyle(
                          color: AppColors.textMuted, fontSize: 11),
                    ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                color: AppColors.textMuted, size: 13),
          ],
        ),
      ),
    );
  }
}

// ─── INFO TILE ────────────────────────────────────────────────────────────────

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: Row(
        children: [
          _IconBox(icon: icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
          ),
          Text(value,
              style: TextStyle(
                  color: AppColors.textMuted, fontSize: 12)),
        ],
      ),
    );
  }
}

// ─── ICON BOX ─────────────────────────────────────────────────────────────────

class _IconBox extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _IconBox({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.20)),
      ),
      child: Icon(icon, color: color, size: 16),
    );
  }
}

// ─── PICKER SHEET ─────────────────────────────────────────────────────────────

class _PickerSheet extends StatelessWidget {
  final String title;
  final List<String> options;
  final String current;
  final ValueChanged<String> onSelect;

  const _PickerSheet({
    required this.title,
    required this.options,
    required this.current,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1714),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Row(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white10, height: 1),
            ...options.map((opt) {
              final selected = opt == current;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onSelect(opt);
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary.withOpacity(0.08)
                        : Colors.transparent,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          opt,
                          style: TextStyle(
                            color: selected
                                ? AppColors.primary
                                : Colors.white,
                            fontSize: 14,
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                      if (selected)
                        const Icon(Icons.check_rounded,
                            color: AppColors.primary, size: 18),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
