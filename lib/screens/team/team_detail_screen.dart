import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../providers/team_provider.dart';
import '../../core/constants/colors.dart';
import '../../models/team_model.dart';

class TeamDetailScreen extends StatefulWidget {
  final String teamId;
  const TeamDetailScreen({super.key, required this.teamId});

  @override
  State<TeamDetailScreen> createState() => _TeamDetailScreenState();
}

class _TeamDetailScreenState extends State<TeamDetailScreen>
    with SingleTickerProviderStateMixin {
  List<dynamic> _squad = [];
  bool _loadingSquad = true;
  late AnimationController _shimmerCtrl;

  @override
  void initState() {
    super.initState();
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();
    _fetchData();
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    final provider = context.read<TeamProvider>();
    final squad = await provider.fetchTeamPlayers(widget.teamId);
    if (mounted) {
      setState(() {
        _squad = squad;
        _loadingSquad = false;
      });
    }
  }

  Color _teamAccent(String name) {
    final n = name.toLowerCase();
    if (n.contains('india'))     return const Color(0xFF003580);
    if (n.contains('australia')) return const Color(0xFF00843D);
    if (n.contains('england'))   return const Color(0xFF002868);
    if (n.contains('pakistan'))  return const Color(0xFF01411C);
    if (n.contains('south'))     return const Color(0xFF007A4D);
    if (n.contains('west'))      return const Color(0xFF7B0C2A);
    if (n.contains('zealand'))   return const Color(0xFF000000);
    if (n.contains('sri'))       return const Color(0xFF00247D);
    if (n.contains('bangla'))    return const Color(0xFF006A4E);
    if (n.contains('afghani'))   return const Color(0xFF000088);
    return AppColors.primary;
  }

  Color _roleColor(String role) {
    final r = role.toLowerCase();
    if (r.contains('bat'))  return const Color(0xFF1565C0);
    if (r.contains('bowl')) return const Color(0xFFE53935);
    if (r.contains('all') || r.contains('round')) return const Color(0xFF2E7D32);
    if (r.contains('keep') || r.contains('wk'))   return const Color(0xFF6A1B9A);
    return AppColors.textMuted;
  }

  @override
  Widget build(BuildContext context) {
    final team = context.watch<TeamProvider>().teams.firstWhere(
          (t) => t.id == widget.teamId,
      orElse: () => TeamModel(
        id: widget.teamId,
        name: 'Loading…',
        code: '...',
        logo: '',
        description: '',
        squad: [],
        isSectionHeader: false,
      ),
    );

    final accent = _teamAccent(team.name);
    final playerCount = _squad
        .where((p) {
      final m = p as Map<String, dynamic>;
      final id = m['id']?.toString() ?? m['playerId']?.toString() ?? '';
      return id.isNotEmpty;
    })
        .length;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Hero SliverAppBar ──────────────────────────────────────────
            SliverAppBar(
              expandedHeight: 250,
              pinned: true,
              backgroundColor: AppColors.background,
              elevation: 0,
              leading: GestureDetector(
                onTap: () => Navigator.maybePop(context),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.38),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.white.withOpacity(0.18)),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 14),
                ),
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.only(
                      right: 12, top: 8, bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.38),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.white.withOpacity(0.18)),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.favorite_border_rounded,
                        color: Colors.white, size: 18),
                    onPressed: () {},
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
                titlePadding:
                const EdgeInsets.fromLTRB(60, 0, 16, 14),
                title: Text(
                  team.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
                background: _HeroBg(team: team, accent: accent),
              ),
            ),

            // ── Stats strip ────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: FadeInDown(
                duration: const Duration(milliseconds: 350),
                child: _StatsStrip(
                    playerCount: playerCount, accent: accent),
              ),
            ),

            // ── Description ────────────────────────────────────────────────
            if (team.description.isNotEmpty)
              SliverToBoxAdapter(
                child: FadeInUp(
                  delay: const Duration(milliseconds: 80),
                  child: Container(
                    margin:
                    const EdgeInsets.fromLTRB(16, 14, 16, 0),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.06)),
                    ),
                    child: Text(
                      team.description,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.6,
                      ),
                    ),
                  ),
                ),
              ),

            // ── Squad header ───────────────────────────────────────────────
            SliverToBoxAdapter(
              child: FadeInLeft(
                delay: const Duration(milliseconds: 120),
                child: Padding(
                  padding:
                  const EdgeInsets.fromLTRB(16, 22, 16, 12),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 16,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              accent,
                              accent.withOpacity(0.3)
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'SQUAD',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                      if (playerCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: accent.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: accent.withOpacity(0.22)),
                          ),
                          child: Text(
                            '$playerCount players',
                            style: TextStyle(
                              color: accent,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // ── Squad list ─────────────────────────────────────────────────
            if (_loadingSquad)
              SliverPadding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (_, __) => _PlayerShimmer(ctrl: _shimmerCtrl),
                    childCount: 8,
                  ),
                ),
              )
            else if (_squad.isEmpty)
              SliverToBoxAdapter(
                child: _EmptySquad(),
              )
            else
              SliverPadding(
                padding:
                const EdgeInsets.fromLTRB(16, 0, 16, 40),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, i) {
                      final p =
                      _squad[i] as Map<String, dynamic>;
                      final name =
                          p['name']?.toString() ?? '';
                      final pid = p['id']?.toString() ??
                          p['playerId']?.toString();
                      final imageId =
                          p['imageId'] ?? p['faceImageId'];
                      final isHeader =
                          pid == null || pid.isEmpty;

                      if (isHeader) {
                        return _SquadSectionLabel(
                            name: name, accent: accent);
                      }

                      final role = p['role']?.toString() ??
                          [
                            if (p['battingStyle'] != null)
                              p['battingStyle'].toString(),
                            if (p['bowlingStyle'] != null)
                              p['bowlingStyle'].toString(),
                          ]
                              .where((s) => s.isNotEmpty)
                              .join(' · ');

                      return FadeInUp(
                        duration: Duration(
                            milliseconds:
                            200 + (i % 8) * 30),
                        child: _PlayerTile(
                          name: name,
                          role: role,
                          imageId: imageId?.toString(),
                          playerId: pid!,
                          accent: accent,
                          roleColor: _roleColor(role),
                          onTap: () =>
                              context.push('/player/$pid'),
                        ),
                      );
                    },
                    childCount: _squad.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── HERO BACKGROUND ──────────────────────────────────────────────────────────

class _HeroBg extends StatelessWidget {
  final TeamModel team;
  final Color accent;
  const _HeroBg({required this.team, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Gradient field
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                accent.withOpacity(0.60),
                accent.withOpacity(0.22),
                AppColors.background,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.50, 1.0],
            ),
          ),
        ),

        // Watermark logo (right side, faded)
        if (team.logo.isNotEmpty)
          Positioned(
            right: -20,
            top: 8,
            child: Opacity(
              opacity: 0.10,
              child: CachedNetworkImage(
                imageUrl: team.logo,
                width: 210,
                height: 210,
                fit: BoxFit.contain,
                errorWidget: (_, __, ___) => const SizedBox(),
              ),
            ),
          ),

        // Front logo + code badge
        Positioned(
          left: 20,
          bottom: 52,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (team.logo.isNotEmpty)
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.10),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.22),
                        width: 2),
                  ),
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: team.logo,
                      fit: BoxFit.contain,
                      errorWidget: (_, __, ___) => const Icon(
                          Icons.sports_cricket_rounded,
                          color: Colors.white54,
                          size: 30),
                    ),
                  ),
                ),
              const SizedBox(width: 12),
              if (team.code.isNotEmpty && team.code != '...')
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.24)),
                  ),
                  child: Text(
                    team.code.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.4,
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Bottom fade to background
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.background.withOpacity(0.55),
                  AppColors.background,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.45, 0.75, 1.0],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── STATS STRIP ──────────────────────────────────────────────────────────────

class _StatsStrip extends StatelessWidget {
  final int playerCount;
  final Color accent;
  const _StatsStrip(
      {required this.playerCount, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withOpacity(0.18)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatCell(
              label: 'Squad',
              value: '$playerCount',
              icon: Icons.people_rounded,
              color: accent),
          Container(width: 1, height: 36, color: Colors.white10),
          _StatCell(
              label: 'Format',
              value: 'Intl.',
              icon: Icons.flag_rounded,
              color: const Color(0xFF1565C0)),
          Container(width: 1, height: 36, color: Colors.white10),
          _StatCell(
              label: 'Ranking',
              value: 'Top 10',
              icon: Icons.leaderboard_rounded,
              color: const Color(0xFF2E7D32)),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatCell(
      {required this.label,
        required this.value,
        required this.icon,
        required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withOpacity(0.10),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, color: color, size: 15),
        ),
        const SizedBox(height: 5),
        Text(value,
            style: TextStyle(
                color: color,
                fontSize: 15,
                fontWeight: FontWeight.w800)),
        Text(label,
            style: TextStyle(
                color: AppColors.textMuted, fontSize: 10)),
      ],
    );
  }
}

// ─── SQUAD SECTION LABEL ──────────────────────────────────────────────────────

class _SquadSectionLabel extends StatelessWidget {
  final String name;
  final Color accent;
  const _SquadSectionLabel(
      {required this.name, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 10),
      child: Row(
        children: [
          Container(
            width: 3.5,
            height: 13,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            name.toUpperCase(),
            style: TextStyle(
              color: accent,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    accent.withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── PLAYER TILE ──────────────────────────────────────────────────────────────

class _PlayerTile extends StatelessWidget {
  final String name;
  final String role;
  final String? imageId;
  final String playerId;
  final Color accent;
  final Color roleColor;
  final VoidCallback onTap;

  const _PlayerTile({
    required this.name,
    required this.role,
    required this.imageId,
    required this.playerId,
    required this.accent,
    required this.roleColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = (imageId != null && imageId!.isNotEmpty)
        ? 'https://static.cricbuzz.com/a/img/v1/i1/c$imageId/i.jpg'
        : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: Colors.white.withOpacity(0.06)),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accent.withOpacity(0.10),
                border: Border.all(
                    color: accent.withOpacity(0.22)),
              ),
              child: ClipOval(
                child: imageUrl != null
                    ? CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) =>
                      _Initial(name: name, color: accent),
                )
                    : _Initial(name: name, color: accent),
              ),
            ),

            const SizedBox(width: 12),

            // Name + role pill
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.isNotEmpty ? name : 'Unknown Player',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (role.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: roleColor.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                            color: roleColor.withOpacity(0.22)),
                      ),
                      child: Text(
                        role,
                        style: TextStyle(
                          color: roleColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Arrow tile
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.arrow_forward_ios_rounded,
                  color: accent, size: 12),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── SHIMMER ──────────────────────────────────────────────────────────────────

class _PlayerShimmer extends StatelessWidget {
  final AnimationController ctrl;
  const _PlayerShimmer({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ctrl,
      builder: (_, __) => Container(
        height: 72,
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              AppColors.surface,
              AppColors.cardGrey
                  .withOpacity(0.65 + ctrl.value * 0.35),
              AppColors.surface,
            ],
            stops: [
              (ctrl.value - 0.3).clamp(0.0, 1.0),
              ctrl.value.clamp(0.0, 1.0),
              (ctrl.value + 0.3).clamp(0.0, 1.0),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
      ),
    );
  }
}

// ─── EMPTY SQUAD ──────────────────────────────────────────────────────────────

class _EmptySquad extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(
                    color: Colors.white.withOpacity(0.07)),
              ),
              child: const Icon(Icons.people_outline_rounded,
                  size: 32, color: AppColors.textMuted),
            ),
            const SizedBox(height: 14),
            const Text('No squad data available',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text('Try again later',
                style: TextStyle(
                    color: AppColors.textMuted, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

// ─── INITIALS AVATAR ──────────────────────────────────────────────────────────

class _Initial extends StatelessWidget {
  final String name;
  final Color color;
  const _Initial({required this.name, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color.withOpacity(0.10),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'P',
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}