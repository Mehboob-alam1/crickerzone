import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../providers/team_provider.dart';
import '../../models/team_model.dart';
import '../../core/constants/colors.dart';
import '../../widgets/team_card.dart';
import 'team_detail_screen.dart';

class TeamsScreen extends StatefulWidget {
  const TeamsScreen({super.key});

  @override
  State<TeamsScreen> createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<TeamsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerCtrl;
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';
  String _selectedFilter = 'all';

  static const _filters = [
    _Filter('all',        'All Teams',    Icons.grid_view_rounded,       AppColors.primary),
    _Filter('men',        'Men',          Icons.person_rounded,          AppColors.formatOdi),
    _Filter('women',      'Women',        Icons.star_rounded,            AppColors.categoryWomen),
    _Filter('associate',  'Associate',    Icons.language_rounded,        AppColors.categoryDomestic),
    _Filter('u19',        'U-19',         Icons.school_rounded,          AppColors.formatT20),
  ];

  @override
  void initState() {
    super.initState();
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _searchCtrl.addListener(
            () => setState(() => _query = _searchCtrl.text.trim().toLowerCase()));

    Future.delayed(Duration.zero, () {
      if (mounted) context.read<TeamProvider>().fetchTeams();
    });
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  List<TeamModel> _applyFilters(List<TeamModel> all) {
    return all.where((t) {
      if (t.isSectionHeader) return true;
      final name = t.name.toLowerCase();
      final cat = (t.category ?? '').toLowerCase();

      final matchesSearch =
          _query.isEmpty || name.contains(_query);
      final matchesFilter = _selectedFilter == 'all' ||
          name.contains(_selectedFilter) ||
          cat.contains(_selectedFilter);

      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Consumer<TeamProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading && provider.teams.isEmpty) {
              return Column(
                children: [
                  _buildHeader(context, provider),
                  _buildSearchBar(),
                  _buildFilterChips(),
                  Expanded(child: _buildShimmer()),
                ],
              );
            }

            if (!provider.isLoading && provider.teams.isEmpty) {
              return Column(
                children: [
                  _buildHeader(context, provider),
                  Expanded(
                    child: RefreshIndicator(
                      color: AppColors.primary,
                      backgroundColor: AppColors.surface,
                      onRefresh: () => provider.fetchTeams(forceRefresh: true),
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.55,
                            child: _buildEmptyState(
                              'No teams available',
                              'Pull to refresh or try again later.',
                              Icons.groups_outlined,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }

            final filtered = _applyFilters(provider.teams);

            return Column(
              children: [
                _buildHeader(context, provider),
                _buildSearchBar(),
                _buildFilterChips(),
                Expanded(
                  child: RefreshIndicator(
                    color: AppColors.primary,
                    backgroundColor: AppColors.surface,
                    onRefresh: () =>
                        provider.fetchTeams(forceRefresh: true),
                    child: _TeamListWithSections(
                      teams: filtered,
                      query: _query,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, TeamProvider provider) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 14, 20, 14),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.screenNavyHeader, AppColors.background],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          // Back button
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

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CRICKET TEAMS',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.4,
                  ),
                ),
                Text(
                  'International & Associate',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Team count
          if (!provider.isLoading && provider.teams.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.10),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppColors.primary.withOpacity(0.22)),
              ),
              child: Text(
                '${provider.teams.where((t) => !t.isSectionHeader && t.id.isNotEmpty).length}',
                style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w800),
              ),
            ),
        ],
      ),
    );
  }

  // ── Search bar ────────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
              color: Colors.white.withOpacity(0.07)),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            Icon(Icons.search_rounded,
                color: AppColors.textMuted, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _searchCtrl,
                style: const TextStyle(
                    color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Search teams…',
                  hintStyle: TextStyle(
                      color: AppColors.textMuted, fontSize: 13),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            if (_query.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _searchCtrl.clear();
                  setState(() => _query = '');
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(Icons.close_rounded,
                      color: AppColors.textMuted, size: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Filter chips ──────────────────────────────────────────────────────────

  Widget _buildFilterChips() {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: _filters.map((f) {
          final selected = _selectedFilter == f.key;
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedFilter = f.key);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: selected
                    ? f.color.withOpacity(0.14)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected
                      ? f.color.withOpacity(0.48)
                      : Colors.white.withOpacity(0.07),
                ),
                boxShadow: selected
                    ? [
                  BoxShadow(
                    color: f.color.withOpacity(0.18),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(f.icon,
                      size: 12,
                      color: selected ? f.color : AppColors.textMuted),
                  const SizedBox(width: 6),
                  Text(
                    f.label,
                    style: TextStyle(
                      color: selected ? f.color : AppColors.textMuted,
                      fontSize: 11,
                      fontWeight: selected
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Shimmer ───────────────────────────────────────────────────────────────

  Widget _buildShimmer() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: [
        // Section header shimmer
        _shimmerBox(height: 14, width: 120, bottomPad: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 0.8,
          children: List.generate(
            6,
                (_) => AnimatedBuilder(
              animation: _shimmerCtrl,
              builder: (_, __) => Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: _shimmerGradient(_shimmerCtrl.value),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        _shimmerBox(height: 14, width: 100, bottomPad: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 0.8,
          children: List.generate(
            4,
                (_) => AnimatedBuilder(
              animation: _shimmerCtrl,
              builder: (_, __) => Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: _shimmerGradient(_shimmerCtrl.value),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _shimmerBox(
      {required double height, double? width, double bottomPad = 0}) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottomPad),
      child: AnimatedBuilder(
        animation: _shimmerCtrl,
        builder: (_, __) => Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            gradient: _shimmerGradient(_shimmerCtrl.value),
          ),
        ),
      ),
    );
  }

  LinearGradient _shimmerGradient(double v) => LinearGradient(
    colors: [
      AppColors.surface,
      AppColors.cardGrey.withOpacity(0.7 + v * 0.3),
      AppColors.surface,
    ],
    stops: [
      (v - 0.3).clamp(0.0, 1.0),
      v.clamp(0.0, 1.0),
      (v + 0.3).clamp(0.0, 1.0),
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // ── Empty state ───────────────────────────────────────────────────────────

  Widget _buildEmptyState(String title, String sub, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(
                    color: Colors.white.withOpacity(0.07)),
              ),
              child: Icon(icon, size: 38, color: AppColors.textMuted),
            ),
            const SizedBox(height: 18),
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(sub,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                    height: 1.5)),
            const SizedBox(height: 22),
            GestureDetector(
              onTap: () => context
                  .read<TeamProvider>()
                  .fetchTeams(forceRefresh: true),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 13),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryLight, AppColors.primary],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.28),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh_rounded,
                        color: Colors.black, size: 15),
                    SizedBox(width: 8),
                    Text('Retry',
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w800,
                            fontSize: 13)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── TEAM LIST WITH SECTIONS ──────────────────────────────────────────────────

class _TeamListWithSections extends StatelessWidget {
  final List<TeamModel> teams;
  final String query;

  const _TeamListWithSections({
    required this.teams,
    required this.query,
  });

  @override
  Widget build(BuildContext context) {
    // If search returns zero real items
    final hasAny = teams.any((t) => !t.isSectionHeader && t.id.isNotEmpty);
    if (teams.isEmpty || !hasAny) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 80),
          Center(
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
                  child: const Icon(Icons.search_off_rounded,
                      size: 30, color: AppColors.textMuted),
                ),
                const SizedBox(height: 14),
                const Text('No teams found',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text('Try adjusting your search or filter',
                    style: TextStyle(
                        color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
          ),
        ],
      );
    }

    // Build widgets from sections
    final widgets = <Widget>[];
    var chunk = <TeamModel>[];
    var gridIndex = 0;
    String? currentSection;

    void flushChunk() {
      if (chunk.isEmpty) return;
      final tiles = List<TeamModel>.from(chunk);
      final base = gridIndex;
      gridIndex += tiles.length;
      chunk = [];

      widgets.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.82,
            ),
            itemCount: tiles.length,
            itemBuilder: (context, i) {
              final team = tiles[i];
              final idx = base + i;
              return FadeInUp(
                duration:
                Duration(milliseconds: 260 + (idx % 6) * 40),
                child: TeamCard(
                  team: team,
                  index: idx,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          TeamDetailScreen(teamId: team.id),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    }

    for (final t in teams) {
      if (t.isSectionHeader) {
        flushChunk();
        currentSection = t.name;
        widgets.add(
          _SectionHeader(title: t.name.toUpperCase()),
        );
      } else if (t.id.isNotEmpty) {
        chunk.add(t);
      }
    }
    flushChunk();

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 32, top: 8),
      children: widgets,
    );
  }
}

// ─── SECTION HEADER ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  Color _sectionColor(String t) {
    final lower = t.toLowerCase();
    if (lower.contains('men') && !lower.contains('women')) {
      return AppColors.formatOdi;
    }
    if (lower.contains('women')) return AppColors.categoryWomen;
    if (lower.contains('associate') || lower.contains('affiliate')) {
      return AppColors.categoryDomestic;
    }
    if (lower.contains('u19') || lower.contains('under')) {
      return AppColors.formatT20;
    }
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final color = _sectionColor(title);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.3)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(0.3),
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

// ─── FILTER META ──────────────────────────────────────────────────────────────

class _Filter {
  final String key;
  final String label;
  final IconData icon;
  final Color color;
  const _Filter(this.key, this.label, this.icon, this.color);
}
