import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/colors.dart';
import '../../providers/news_provider.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerCtrl;

  @override
  void initState() {
    super.initState();
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    Future.microtask(() {
      if (!mounted) return;
      final p = context.read<NewsProvider>();
      p.fetchCategories();
      p.fetchNews();
    });
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    super.dispose();
  }

  // ── Category bottom sheet ─────────────────────────────────────────────────

  void _showCategorySheet(NewsProvider provider) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1A1714),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
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

                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.filter_list_rounded,
                            color: AppColors.primary, size: 16),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Browse Categories',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(color: Colors.white10, height: 1),
                const SizedBox(height: 8),

                // All news tile
                _CategorySheetTile(
                  icon: Icons.grid_view_rounded,
                  label: 'All News',
                  color: AppColors.primary,
                  onTap: () {
                    Navigator.pop(ctx);
                    provider.fetchNews(forceRefresh: true);
                  },
                ),

                // Category tiles
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(ctx).size.height * 0.45,
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: provider.categories.length,
                    itemBuilder: (_, i) {
                      final c = provider.categories[i];
                      final id = c['id'];
                      final name = c['name']?.toString() ?? '';
                      if (id == null || name.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      final cid =
                      id is int ? id : (id as num).toInt();
                      final colors = _catColors();
                      final color = colors[i % colors.length];
                      return _CategorySheetTile(
                        icon: _catIcon(name),
                        label: name,
                        color: color,
                        onTap: () {
                          Navigator.pop(ctx);
                          provider.fetchNewsByCategory(cid,
                              forceRefresh: true);
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Color> _catColors() => [
    const Color(0xFFFFA000),
    const Color(0xFF1565C0),
    const Color(0xFF6A1B9A),
    const Color(0xFF2E7D32),
    const Color(0xFFAD1457),
    const Color(0xFF00695C),
    const Color(0xFF37474F),
  ];

  IconData _catIcon(String name) {
    final n = name.toLowerCase();
    if (n.contains('test')) return Icons.sports_cricket_rounded;
    if (n.contains('odi')) return Icons.flag_rounded;
    if (n.contains('t20') || n.contains('twenty')) return Icons.bolt_rounded;
    if (n.contains('women')) return Icons.star_rounded;
    if (n.contains('ipl') || n.contains('league')) return Icons.emoji_events_rounded;
    if (n.contains('world')) return Icons.public_rounded;
    if (n.contains('interview')) return Icons.mic_rounded;
    return Icons.article_outlined;
  }

  // ── Main build ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Consumer<NewsProvider>(
          builder: (context, provider, _) {
            Future<void> onRefresh() async {
              await provider.fetchCategories(forceRefresh: true);
              final cid = provider.activeCategoryId;
              if (cid != null) {
                await provider.fetchNewsByCategory(cid, forceRefresh: true);
              } else {
                await provider.fetchNews(forceRefresh: true);
              }
            }

            return Column(
              children: [
                _buildHeader(context, provider),
                _buildCategoryChips(provider),
                Expanded(
                  child: _buildBody(provider, onRefresh),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, NewsProvider provider) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 14, 20, 14),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A0B00), AppColors.background],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          // Back or logo
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
                'CRICKET NEWS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.4,
                ),
              ),
              Text(
                'Latest from the cricket world',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),

          const Spacer(),

          // Article count badge
          if (provider.newsList.isNotEmpty)
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
                '${provider.newsList.length}',
                style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w800),
              ),
            ),

          const SizedBox(width: 8),

          // Filter
          GestureDetector(
            onTap: provider.categories.isEmpty
                ? null
                : () {
              HapticFeedback.selectionClick();
              _showCategorySheet(provider);
            },
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: Colors.white.withOpacity(0.07)),
              ),
              child: Icon(
                Icons.tune_rounded,
                color: provider.activeCategoryId != null
                    ? AppColors.primary
                    : AppColors.textMuted,
                size: 17,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Category chips row ────────────────────────────────────────────────────

  Widget _buildCategoryChips(NewsProvider provider) {
    if (provider.categories.isEmpty) return const SizedBox();
    final colors = _catColors();

    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // All chip
          _Chip(
            label: 'All',
            color: AppColors.primary,
            selected: provider.activeCategoryId == null,
            onTap: () {
              HapticFeedback.selectionClick();
              provider.fetchNews(forceRefresh: true);
            },
          ),
          ...provider.categories.asMap().entries.map((entry) {
            final i = entry.key;
            final c = entry.value;
            final id = c['id'];
            final name = c['name']?.toString() ?? '';
            if (id == null || name.isEmpty) {
              return const SizedBox.shrink();
            }
            final cid = id is int ? id : (id as num).toInt();
            final color = colors[i % colors.length];
            return _Chip(
              label: name,
              color: color,
              selected: provider.activeCategoryId == cid,
              onTap: () {
                HapticFeedback.selectionClick();
                provider.fetchNewsByCategory(cid, forceRefresh: true);
              },
            );
          }),
        ],
      ),
    );
  }

  // ── Body ──────────────────────────────────────────────────────────────────

  Widget _buildBody(
      NewsProvider provider, Future<void> Function() onRefresh) {
    if (provider.isLoading) {
      return _buildShimmer();
    }

    if (provider.newsList.isEmpty) {
      return RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: 320,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white.withOpacity(0.07)),
                      ),
                      child: const Icon(Icons.newspaper_outlined,
                          size: 34, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 16),
                    const Text('No news yet',
                        style: TextStyle(
                            color: AppColors.textMuted, fontSize: 14)),
                    const SizedBox(height: 6),
                    const Text('Pull to refresh',
                        style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11)),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      onRefresh: onRefresh,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: provider.newsList.length,
        itemBuilder: (context, index) {
          final news = provider.newsList[index];
          final colors = _catColors();
          final accentColor = colors[index % colors.length];

          // First article = featured hero card
          if (index == 0) {
            return FadeInDown(
              duration: const Duration(milliseconds: 500),
              child: _FeaturedNewsCard(
                news: news,
                onTap: () => context.push('/news/article/${news.id}'),
              ),
            );
          }

          return FadeInUp(
            delay: Duration(milliseconds: 60 * ((index - 1) % 8)),
            child: _NewsCard(
              news: news,
              accentColor: accentColor,
              onTap: () => context.push('/news/article/${news.id}'),
            ),
          );
        },
      ),
    );
  }

  // ── Shimmer loader ────────────────────────────────────────────────────────

  Widget _buildShimmer() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        // Featured shimmer
        AnimatedBuilder(
          animation: _shimmerCtrl,
          builder: (_, __) => Container(
            height: 240,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: _shimmerGradient(_shimmerCtrl.value),
            ),
          ),
        ),
        ...List.generate(
          5,
              (i) => AnimatedBuilder(
            animation: _shimmerCtrl,
            builder: (_, __) => Container(
              height: 100,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: _shimmerGradient(_shimmerCtrl.value),
              ),
            ),
          ),
        ),
      ],
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
}

// ─── FEATURED HERO CARD ───────────────────────────────────────────────────────

class _FeaturedNewsCard extends StatelessWidget {
  final dynamic news;
  final VoidCallback onTap;

  const _FeaturedNewsCard({required this.news, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 260,
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
              color: AppColors.primary.withOpacity(0.18)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.10),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background image
              if ((news.image as String).isNotEmpty)
                CachedNetworkImage(
                  imageUrl: news.image as String,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                      color: const Color(0xFF1A1714)),
                  errorWidget: (_, __, ___) => Container(
                    color: const Color(0xFF1A1714),
                    child: const Icon(Icons.article_outlined,
                        color: AppColors.textMuted, size: 48),
                  ),
                )
              else
                Container(
                  color: const Color(0xFF1A1714),
                  child: const Icon(Icons.article_outlined,
                      color: AppColors.textMuted, size: 48),
                ),

              // Gradient overlay
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.5),
                        Colors.black.withOpacity(0.92),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.2, 0.55, 1.0],
                    ),
                  ),
                ),
              ),

              // Content
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Featured badge + category
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFFFB300),
                                AppColors.primary
                              ],
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            '★ FEATURED',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        if ((news.category as String).isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color:
                                  Colors.white.withOpacity(0.18)),
                            ),
                            child: Text(
                              news.category as String,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 8),

                    Text(
                      news.headline as String,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded,
                            size: 12, color: Colors.white54),
                        const SizedBox(width: 4),
                        Text(
                          news.pubTime as String,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.20)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Read',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600)),
                              SizedBox(width: 4),
                              Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: Colors.white,
                                  size: 10),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── NEWS CARD (regular) ──────────────────────────────────────────────────────

class _NewsCard extends StatelessWidget {
  final dynamic news;
  final Color accentColor;
  final VoidCallback onTap;

  const _NewsCard({
    required this.news,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = (news.image as String).isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Left accent bar
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 3.5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [accentColor, accentColor.withOpacity(0.3)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category pill
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                  color: accentColor.withOpacity(0.25)),
                            ),
                            child: Text(
                              (news.category as String).isNotEmpty
                                  ? news.category as String
                                  : 'News',
                              style: TextStyle(
                                color: accentColor,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),

                          const SizedBox(height: 7),

                          Text(
                            news.headline as String,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              height: 1.35,
                            ),
                          ),

                          if ((news.intro as String).isNotEmpty) ...[
                            const SizedBox(height: 5),
                            Text(
                              news.intro as String,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                                height: 1.4,
                              ),
                            ),
                          ],

                          const SizedBox(height: 8),

                          Row(
                            children: [
                              const Icon(Icons.access_time_rounded,
                                  size: 11,
                                  color: AppColors.textMuted),
                              const SizedBox(width: 4),
                              Text(
                                news.pubTime as String,
                                style: const TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 10),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Thumbnail
                    if (hasImage) ...[
                      const SizedBox(width: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          imageUrl: news.image as String,
                          width: 82,
                          height: 82,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            width: 82,
                            height: 82,
                            color: AppColors.cardGrey,
                          ),
                          errorWidget: (_, __, ___) => Container(
                            width: 82,
                            height: 82,
                            color: AppColors.cardGrey,
                            child: const Icon(
                              Icons.article_outlined,
                              color: AppColors.textMuted,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── CATEGORY CHIP ────────────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.16) : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? color.withOpacity(0.50)
                : Colors.white.withOpacity(0.08),
          ),
          boxShadow: selected
              ? [
            BoxShadow(
              color: color.withOpacity(0.18),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? color : AppColors.textMuted,
            fontSize: 11,
            fontWeight:
            selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ─── CATEGORY SHEET TILE ──────────────────────────────────────────────────────

class _CategorySheetTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _CategorySheetTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios_rounded,
                color: AppColors.textMuted, size: 13),
          ],
        ),
      ),
    );
  }
}