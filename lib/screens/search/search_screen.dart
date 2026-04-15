import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/constants/colors.dart';
import '../../providers/player_provider.dart';
import '../../widgets/player_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _ctrl = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounce;
  late AnimationController _shimmerCtrl;

  bool _isSearching = false;
  String _query = '';
  String _selectedCategory = 'all';

  final List<String> _recentSearches = [
    'Virat Kohli',
    'Jasprit Bumrah',
    'Steve Smith',
    'Ben Stokes',
  ];

  static const _categories = [
    _Cat('all',     'All',       Icons.grid_view_rounded,                AppColors.primary),
    _Cat('batter',  'Batters',   Icons.sports_cricket_rounded,           Color(0xFF1565C0)),
    _Cat('bowler',  'Bowlers',   Icons.sports_baseball_rounded,          Color(0xFFE53935)),
    _Cat('allroun', 'All-Round', Icons.swap_horizontal_circle_rounded,   Color(0xFF2E7D32)),
    _Cat('keeper',  'Keepers',   Icons.back_hand_rounded,                Color(0xFF6A1B9A)),
  ];

  static const _trending = [
    'Rohit Sharma', 'Pat Cummins', 'Babar Azam', 'Jos Buttler',
    'Rashid Khan', 'Shubman Gill', 'Travis Head', 'Rishabh Pant',
  ];

  @override
  void initState() {
    super.initState();
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();

    WidgetsBinding.instance
        .addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    _focusNode.dispose();
    _shimmerCtrl.dispose();
    super.dispose();
  }

  void _onChanged(String q) {
    setState(() => _query = q);
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    if (q.trim().isEmpty) return;
    _debounce =
        Timer(const Duration(milliseconds: 450), () => _search(q));
  }

  Future<void> _search(String q) async {
    if (q.trim().isEmpty) return;
    setState(() => _isSearching = true);
    if (!_recentSearches.contains(q.trim())) {
      setState(() {
        _recentSearches.insert(0, q.trim());
        if (_recentSearches.length > 8) _recentSearches.removeLast();
      });
    }
    await context.read<PlayerProvider>().searchPlayers(q.trim());
    if (mounted) setState(() => _isSearching = false);
  }

  void _applyRecent(String term) {
    _ctrl.text = term;
    _ctrl.selection =
        TextSelection.fromPosition(TextPosition(offset: term.length));
    setState(() => _query = term);
    _search(term);
  }

  void _clearSearch() {
    _ctrl.clear();
    setState(() {
      _query = '';
      _isSearching = false;
    });
    context.read<PlayerProvider>().clearSearch();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            _buildTopBar(context),
            _buildCategoryChips(),
            Expanded(
              child: Consumer<PlayerProvider>(
                builder: (_, provider, __) {
                  if (_isSearching) return _buildShimmer();
                  if (_query.trim().isEmpty) return _buildIdleState();
                  if (provider.searchResults.isEmpty) {
                    return _buildNoResults();
                  }
                  return _buildResults(provider.searchResults);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Top bar ───────────────────────────────────────────────────────────────

  Widget _buildTopBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          12, MediaQuery.of(context).padding.top + 10, 12, 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A0D00), AppColors.background],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          // Back
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
          const SizedBox(width: 10),

          // Search field
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                    color: _query.isNotEmpty
                        ? AppColors.primary.withOpacity(0.28)
                        : Colors.white.withOpacity(0.07)),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _isSearching
                        ? const SizedBox(
                      key: ValueKey('loading'),
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 2),
                    )
                        : Icon(
                      key: const ValueKey('icon'),
                      Icons.search_rounded,
                      color: _query.isNotEmpty
                          ? AppColors.primary
                          : AppColors.textMuted,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      focusNode: _focusNode,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Search players, teams, series…',
                        hintStyle: TextStyle(
                            color: AppColors.textMuted, fontSize: 13),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: _onChanged,
                      onSubmitted: _search,
                    ),
                  ),
                  if (_query.isNotEmpty)
                    GestureDetector(
                      onTap: _clearSearch,
                      child: Padding(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 10),
                        child: Icon(Icons.close_rounded,
                            color: AppColors.textMuted, size: 16),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Category chips ────────────────────────────────────────────────────────

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: _categories.map((c) {
          final sel = _selectedCategory == c.key;
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedCategory = c.key);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 13),
              decoration: BoxDecoration(
                color: sel
                    ? c.color.withOpacity(0.14)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: sel
                      ? c.color.withOpacity(0.48)
                      : Colors.white.withOpacity(0.07),
                ),
                boxShadow: sel
                    ? [
                  BoxShadow(
                    color: c.color.withOpacity(0.18),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(c.icon,
                      size: 12,
                      color: sel ? c.color : AppColors.textMuted),
                  const SizedBox(width: 5),
                  Text(c.label,
                      style: TextStyle(
                        color: sel ? c.color : AppColors.textMuted,
                        fontSize: 11,
                        fontWeight: sel
                            ? FontWeight.w700
                            : FontWeight.w500,
                      )),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Idle state ────────────────────────────────────────────────────────────

  Widget _buildIdleState() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        // Recent searches
        if (_recentSearches.isNotEmpty) ...[
          FadeInDown(
            child: Row(
              children: [
                const Icon(Icons.history_rounded,
                    size: 14, color: AppColors.textMuted),
                const SizedBox(width: 6),
                Text(
                  'RECENT SEARCHES',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () =>
                      setState(() => _recentSearches.clear()),
                  child: const Text(
                    'Clear all',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          ..._recentSearches.asMap().entries.map((e) {
            return FadeInLeft(
              delay: Duration(milliseconds: 40 * e.key),
              child: _RecentTile(
                term: e.value,
                onTap: () => _applyRecent(e.value),
                onRemove: () =>
                    setState(() => _recentSearches.remove(e.value)),
              ),
            );
          }),
          const SizedBox(height: 24),
        ],

        // Trending
        FadeInDown(
          delay: const Duration(milliseconds: 80),
          child: Row(
            children: [
              const Icon(Icons.trending_up_rounded,
                  size: 14, color: AppColors.textMuted),
              const SizedBox(width: 6),
              Text(
                'TRENDING',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        FadeInUp(
          delay: const Duration(milliseconds: 130),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _trending
                .map((name) => GestureDetector(
              onTap: () => _applyRecent(name),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.07)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                        Icons.sports_cricket_rounded,
                        size: 12,
                        color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(name,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        )),
                  ],
                ),
              ),
            ))
                .toList(),
          ),
        ),

        const SizedBox(height: 32),

        // Big prompt
        FadeInUp(
          delay: const Duration(milliseconds: 200),
          child: Center(
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.14),
                        AppColors.primary.withOpacity(0.04),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color:
                        AppColors.primary.withOpacity(0.18)),
                  ),
                  child: const Icon(Icons.manage_search_rounded,
                      color: AppColors.primary, size: 36),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Find cricket stars',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Search by player name, team or series',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── No results ────────────────────────────────────────────────────────────

  Widget _buildNoResults() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FadeInDown(
              child: Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: Colors.white.withOpacity(0.07)),
                ),
                child: const Icon(Icons.search_off_rounded,
                    size: 38, color: AppColors.textMuted),
              ),
            ),
            const SizedBox(height: 18),
            FadeInUp(
              child: Text('No results for',
                  style: TextStyle(
                      color: AppColors.textMuted, fontSize: 13)),
            ),
            FadeInUp(
              delay: const Duration(milliseconds: 60),
              child: Text(
                '"$_query"',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 10),
            FadeInUp(
              delay: const Duration(milliseconds: 120),
              child: Text(
                'Check the spelling or try a different name.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    height: 1.5),
              ),
            ),
            const SizedBox(height: 22),
            FadeInUp(
              delay: const Duration(milliseconds: 180),
              child: GestureDetector(
                onTap: _clearSearch,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 11),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.09)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.close_rounded,
                          color: AppColors.textMuted, size: 14),
                      SizedBox(width: 7),
                      Text('Clear search',
                          style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Shimmer ───────────────────────────────────────────────────────────────

  Widget _buildShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: 6,
      itemBuilder: (_, __) => AnimatedBuilder(
        animation: _shimmerCtrl,
        builder: (_, __) => Container(
          height: 80,
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                AppColors.surface,
                AppColors.cardGrey.withOpacity(
                    0.6 + _shimmerCtrl.value * 0.4),
                AppColors.surface,
              ],
              stops: [
                (_shimmerCtrl.value - 0.3).clamp(0.0, 1.0),
                _shimmerCtrl.value.clamp(0.0, 1.0),
                (_shimmerCtrl.value + 0.3).clamp(0.0, 1.0),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ),
    );
  }

  // ── Results ───────────────────────────────────────────────────────────────

  Widget _buildResults(List results) {
    return Column(
      children: [
        FadeInDown(
          duration: const Duration(milliseconds: 280),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${results.length}',
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(width: 8),
                Text('result${results.length == 1 ? '' : 's'} for',
                    style: TextStyle(
                        color: AppColors.textMuted, fontSize: 12)),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    '"$_query"',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            itemCount: results.length,
            itemBuilder: (_, i) => FadeInUp(
              duration: Duration(milliseconds: 230 + i * 30),
              child: PlayerCard(player: results[i], index: i),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── RECENT TILE ──────────────────────────────────────────────────────────────

class _RecentTile extends StatelessWidget {
  final String term;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _RecentTile({
    required this.term,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border:
          Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.history_rounded,
                  color: AppColors.primary, size: 14),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(term,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  )),
            ),
            GestureDetector(
              onTap: onRemove,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Icon(Icons.close_rounded,
                    size: 15, color: AppColors.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── META ─────────────────────────────────────────────────────────────────────

class _Cat {
  final String key;
  final String label;
  final IconData icon;
  final Color color;
  const _Cat(this.key, this.label, this.icon, this.color);
}