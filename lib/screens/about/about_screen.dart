import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/constants/colors.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen>
    with TickerProviderStateMixin {
  late AnimationController _orbitCtrl;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _orbitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _pulseAnim =
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _orbitCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              _buildHero(context),
              _buildStats(),
              _buildAboutText(),
              _buildFeatures(),
              _buildContactSection(),
              _buildSocialRow(),
              _buildFooter(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ── Hero ──────────────────────────────────────────────────────────────────

  Widget _buildHero(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
          24, MediaQuery.of(context).padding.top + 12, 24, 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1C1000), Color(0xFF0E0800), AppColors.background],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.6, 1.0],
        ),
      ),
      child: Column(
        children: [
          // Back button row
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
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
                      color: AppColors.textMuted, size: 15),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: AppColors.primary.withOpacity(0.22)),
                ),
                child: const Text(
                  'v1.0.0',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 36),

          // Animated orb logo
          AnimatedBuilder(
            animation: Listenable.merge([_orbitCtrl, _pulseAnim]),
            builder: (_, __) {
              return SizedBox(
                width: 160,
                height: 160,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Glow bloom
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(
                                0.12 + _pulseAnim.value * 0.12),
                            blurRadius: 60,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                    ),

                    // Orbit ring
                    Transform.rotate(
                      angle: _orbitCtrl.value * 6.28,
                      child: CustomPaint(
                        size: const Size(150, 150),
                        painter: _OrbitPainter(
                          color:
                          AppColors.primary.withOpacity(0.22),
                        ),
                      ),
                    ),

                    // Core circle
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFFFB300),
                            AppColors.primary,
                            const Color(0xFFE65100),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(
                                0.40 + _pulseAnim.value * 0.20),
                            blurRadius: 30,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.sports_cricket_rounded,
                        size: 52,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 28),

          // App name
          FadeInDown(
            duration: const Duration(milliseconds: 600),
            child: const Text(
              'SCORE ZONE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
              ),
            ),
          ),

          const SizedBox(height: 8),

          FadeInDown(
            delay: const Duration(milliseconds: 150),
            duration: const Duration(milliseconds: 500),
            child: Text(
              'Your Ultimate Cricket Companion',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 13,
                letterSpacing: 0.5,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Tag pills
          FadeInUp(
            delay: const Duration(milliseconds: 300),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: const [
                _TagPill('🏏 Live Scores'),
                _TagPill('📊 Statistics'),
                _TagPill('⚡ Ball-by-Ball'),
                _TagPill('🏆 Rankings'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Stats strip ───────────────────────────────────────────────────────────

  Widget _buildStats() {
    return FadeInUp(
      delay: const Duration(milliseconds: 200),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withOpacity(0.12),
              AppColors.surface.withOpacity(0.6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: AppColors.primary.withOpacity(0.18)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: const [
            _StatItem('50K+', 'Users'),
            _StatDivider(),
            _StatItem('100+', 'Countries'),
            _StatDivider(),
            _StatItem('Live', 'Updates'),
            _StatDivider(),
            _StatItem('4.8★', 'Rating'),
          ],
        ),
      ),
    );
  }

  // ── About text ────────────────────────────────────────────────────────────

  Widget _buildAboutText() {
    return FadeInUp(
      delay: const Duration(milliseconds: 300),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
                color: Colors.white.withOpacity(0.06)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 18,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.primary,
                          Color(0xFFE65100),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'About Score Zone',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'Score Zone is your ultimate companion for live cricket updates. We provide real-time scores, detailed ball-by-ball commentary, player statistics, and the latest news from the world of cricket.\n\nBuilt with passion for cricket fans worldwide, Score Zone delivers the fastest and most accurate cricket data straight to your pocket.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13.5,
                  height: 1.7,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Feature tiles ─────────────────────────────────────────────────────────

  Widget _buildFeatures() {
    const features = [
      _Feature('⚡', 'Live Scores',
          'Real-time ball-by-ball updates from every match worldwide.',
          Color(0xFFFFA000)),
      _Feature('📊', 'Deep Stats',
          'Comprehensive player and team statistics across all formats.',
          Color(0xFF1565C0)),
      _Feature('🏆', 'ICC Rankings',
          'Official ICC rankings for teams, batters and bowlers.',
          Color(0xFF6A1B9A)),
      _Feature('🔔', 'Smart Alerts',
          'Get notified for wickets, milestones and match results.',
          Color(0xFF2E7D32)),
    ];

    return FadeInUp(
      delay: const Duration(milliseconds: 350),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 14),
              child: Text(
                'FEATURES',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ),
            ),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.35,
              children: features
                  .map((f) => _FeatureTile(feature: f))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  // ── Contact section ───────────────────────────────────────────────────────

  Widget _buildContactSection() {
    return FadeInUp(
      delay: const Duration(milliseconds: 400),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 14),
              child: Text(
                'GET IN TOUCH',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ),
            ),
            _ContactTile(
              icon: Icons.email_outlined,
              title: 'Contact Support',
              subtitle: 'support@scorezone.com',
              color: const Color(0xFFFFA000),
              onTap: () {},
            ),
            const SizedBox(height: 10),
            _ContactTile(
              icon: Icons.language_outlined,
              title: 'Official Website',
              subtitle: 'www.scorezone.com',
              color: const Color(0xFF1565C0),
              onTap: () {},
            ),
            const SizedBox(height: 10),
            _ContactTile(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              subtitle: 'Read our terms & conditions',
              color: const Color(0xFF6A1B9A),
              onTap: () {},
            ),
            const SizedBox(height: 10),
            _ContactTile(
              icon: Icons.star_rate_rounded,
              title: 'Rate the App',
              subtitle: 'Love Score Zone? Leave a review!',
              color: const Color(0xFF2E7D32),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  // ── Social row ────────────────────────────────────────────────────────────

  Widget _buildSocialRow() {
    const socials = [
      _Social('𝕏', 'Twitter',   Color(0xFF1DA1F2)),
      _Social('f', 'Facebook',  Color(0xFF1877F2)),
      _Social('in', 'Instagram', Color(0xFFE1306C)),
      _Social('▶', 'YouTube',   Color(0xFFFF0000)),
    ];

    return FadeInUp(
      delay: const Duration(milliseconds: 450),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 14),
              child: Text(
                'FOLLOW US',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ),
            ),
            Row(
              children: socials.map((s) {
                return Expanded(
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      margin: EdgeInsets.only(
                        right: s == socials.last ? 0 : 8,
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 14),
                      decoration: BoxDecoration(
                        color: s.color.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: s.color.withOpacity(0.22)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            s.emoji,
                            style: TextStyle(
                              color: s.color,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            s.label,
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // ── Footer ────────────────────────────────────────────────────────────────

  Widget _buildFooter() {
    return FadeInUp(
      delay: const Duration(milliseconds: 500),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const Divider(color: Colors.white10),
            const SizedBox(height: 16),
            const Text(
              '🏏 SCORE ZONE',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '© 2024 Score Zone. All rights reserved.\nMade with ❤️ for cricket fans.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── ORBIT PAINTER ────────────────────────────────────────────────────────────

class _OrbitPainter extends CustomPainter {
  final Color color;
  const _OrbitPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    // Orbit ring
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Radial tick dashes
    const count = 24;
    final dashPaint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < count; i++) {
      final angle = (i / count) * math.pi * 2;
      final inner = radius - 5;
      final outer = radius + 5;
      canvas.drawLine(
        Offset(center.dx + inner * math.cos(angle),
            center.dy + inner * math.sin(angle)),
        Offset(center.dx + outer * math.cos(angle),
            center.dy + outer * math.sin(angle)),
        dashPaint,
      );
    }

    // Moving dot
    const dotAngle = math.pi * 0.25;
    canvas.drawCircle(
      Offset(center.dx + radius * math.cos(dotAngle),
          center.dy + radius * math.sin(dotAngle)),
      5,
      Paint()..color = color.withOpacity(0.9),
    );
  }

  @override
  bool shouldRepaint(_OrbitPainter old) => old.color != color;
}

// ─── SUPPORTING WIDGETS ───────────────────────────────────────────────────────

class _TagPill extends StatelessWidget {
  final String label;
  const _TagPill(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AppColors.primary.withOpacity(0.22)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  const _StatItem(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 28, color: Colors.white10);
}

class _Feature {
  final String emoji;
  final String title;
  final String desc;
  final Color color;
  const _Feature(this.emoji, this.title, this.desc, this.color);
}

class _FeatureTile extends StatelessWidget {
  final _Feature feature;
  const _FeatureTile({required this.feature});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: feature.color.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: feature.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(feature.emoji,
                  style: const TextStyle(fontSize: 18)),
            ),
          ),
          const Spacer(),
          Text(
            feature.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            feature.desc,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 10,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ContactTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: Colors.white.withOpacity(0.06)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.10),
                borderRadius: BorderRadius.circular(11),
                border: Border.all(
                    color: color.withOpacity(0.22)),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.textMuted,
              size: 13,
            ),
          ],
        ),
      ),
    );
  }
}

class _Social {
  final String emoji;
  final String label;
  final Color color;
  const _Social(this.emoji, this.label, this.color);
}