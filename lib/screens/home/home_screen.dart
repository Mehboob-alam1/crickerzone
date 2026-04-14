import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:go_router/go_router.dart';
import 'package:score_zone/core/constants/colors.dart';
import 'package:score_zone/providers/match_provider.dart';
import 'package:score_zone/widgets/live_score_card.dart';
import 'package:score_zone/widgets/section_header.dart';
import 'package:score_zone/widgets/drawer_item.dart';
import 'package:score_zone/screens/player/players_list_screen.dart';
import 'package:score_zone/screens/team/teams_screen.dart';
import 'package:score_zone/screens/series/series_screen.dart';
import 'package:score_zone/screens/news/news_screen.dart';
import 'package:score_zone/screens/rankings/rankings_screen.dart';
import 'package:score_zone/screens/notifications/notifications_screen.dart';
import 'package:score_zone/screens/about/about_screen.dart';

import '../../widgets/match_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.delayed(Duration.zero);
    if (!mounted) return;
    await context.read<MatchProvider>().fetchMatches();
    if (!mounted) return;
    final p = context.read<MatchProvider>();
    if (p.matches.isEmpty && p.matchesLoadError != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _showMatchesLoadFailedDialog(context, p.matchesLoadError!);
      });
    }
  }

  void _showMatchesLoadFailedDialog(BuildContext context, String message) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Row(
          children: [
            Icon(Icons.wifi_off_rounded, color: AppColors.secondary, size: 28),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Data unavailable',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 18),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(
            message,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.4),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(),
      appBar: AppBar(
        title: Center(child: FadeInLeft(child: const Text('SCORE ZONE'))),
        actions: [
          FadeInRight(
            child: Row(
              children: [
                Stack(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NotificationsScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.notifications_none_rounded),
                    ),
                    Positioned(
                      right: 12,
                      top: 12,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.secondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ],
      ),
      body: Consumer<MatchProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.matches.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 3,
              ),
            );
          }

          final noMatchSections = provider.liveMatches.isEmpty &&
              provider.upcomingMatches.isEmpty &&
              provider.recentMatches.isEmpty;

          return RefreshIndicator(
            onRefresh: () async {
              await provider.fetchMatches(forceRefresh: true);
              if (!context.mounted) return;
              if (provider.matches.isEmpty && provider.matchesLoadError != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.surface,
                    content: const Text(
                      'Could not refresh matches.',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                    action: SnackBarAction(
                      label: 'Details',
                      textColor: AppColors.primary,
                      onPressed: () => _showMatchesLoadFailedDialog(
                        context,
                        provider.matchesLoadError!,
                      ),
                    ),
                  ),
                );
              }
            },
            color: AppColors.primary,
            backgroundColor: AppColors.surface,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  sliver: SliverToBoxAdapter(
                    child: FadeInDown(
                      duration: const Duration(milliseconds: 400),
                      child: GestureDetector(
                        onTap: () {
                          context.push('/search');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.search,
                                color: AppColors.textMuted,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Search for series, teams or players...',
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                if (noMatchSections)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _HomeNoMatchesState(
                      hasError: provider.matchesLoadError != null,
                      onRetry: () => provider.fetchMatches(forceRefresh: true),
                      onShowError: provider.matchesLoadError == null
                          ? null
                          : () => _showMatchesLoadFailedDialog(
                                context,
                                provider.matchesLoadError!,
                              ),
                    ),
                  )
                else ...[
                if (provider.liveMatches.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: FadeInLeft(
                      child: const SectionHeader(
                        title: 'Live Matches',
                        isLive: true,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(child: _buildLiveMatchesList(provider)),
                ],

                if (provider.upcomingMatches.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: FadeInLeft(
                      delay: const Duration(milliseconds: 200),
                      child: const SectionHeader(title: 'Upcoming Matches'),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => FadeInUp(
                          delay: Duration(milliseconds: 100 * index),
                          child: MatchCard(
                            match: provider.upcomingMatches[index],
                          ),
                        ),
                        childCount: provider.upcomingMatches.length,
                      ),
                    ),
                  ),
                ],

                if (provider.recentMatches.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: FadeInLeft(
                      delay: const Duration(milliseconds: 400),
                      child: const SectionHeader(title: 'Recent Matches'),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => FadeInUp(
                          delay: Duration(milliseconds: 100 * index),
                          child: MatchCard(
                            match: provider.recentMatches[index],
                          ),
                        ),
                        childCount: provider.recentMatches.length,
                      ),
                    ),
                  ),
                ],
                ],

                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: AppColors.background,
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppColors.surface,
            ),
            child: Center(
              child: ZoomIn(
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.sports_cricket,
                      color: AppColors.primary,
                      size: 48,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'SCORE ZONE',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          DrawerItem(
            icon: Icons.home_rounded,
            title: 'Home',
            isSelected: true,
            onTap: () => Navigator.pop(context),
          ),
          DrawerItem(
            icon: Icons.emoji_events_rounded,
            title: 'Series',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SeriesScreen()),
              );
            },
          ),
          DrawerItem(
            icon: Icons.group_rounded,
            title: 'Teams',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TeamsScreen()),
              );
            },
          ),
          DrawerItem(
            icon: Icons.person_rounded,
            title: 'Players',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PlayersListScreen(),
                ),
              );
            },
          ),
          DrawerItem(
            icon: Icons.leaderboard_rounded,
            title: 'Rankings',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RankingsScreen()),
              );
            },
          ),
          DrawerItem(
            icon: Icons.newspaper_rounded,
            title: 'News',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NewsScreen()),
              );
            },
          ),
          const Divider(color: Colors.white10, height: 32),
          DrawerItem(
            icon: Icons.settings_rounded,
            title: 'Settings',
            onTap: () => Navigator.pop(context),
          ),
          DrawerItem(
            icon: Icons.info_outline_rounded,
            title: 'About Us',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  // Widget _buildCategories() {
  //   final categories = [
  //     {
  //       'name': 'News',
  //       'icon': Icons.newspaper_rounded,
  //       'color': const Color(0xFFE57373),
  //     }, // Warm red
  //     {
  //       'name': 'Videos',
  //       'icon': Icons.play_circle_fill_rounded,
  //       'color': AppColors.secondary,
  //     },
  //     {
  //       'name': 'Rankings',
  //       'icon': Icons.leaderboard_rounded,
  //       'color': AppColors.accent,
  //     },
  //     {
  //       'name': 'Series',
  //       'icon': Icons.emoji_events_rounded,
  //       'color': AppColors.primary,
  //     },
  //     {
  //       'name': 'Teams',
  //       'icon': Icons.group_rounded,
  //       'color': const Color(0xFFBA68C8),
  //     }, // Warm purple
  //     {
  //       'name': 'Players',
  //       'icon': Icons.person_rounded,
  //       'color': const Color(0xFF4DB6AC),
  //     }, // Warm teal
  //   ];
  //
  //   return SizedBox(
  //     height: 130,
  //     child: ListView.builder(
  //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
  //       scrollDirection: Axis.horizontal,
  //       physics: const BouncingScrollPhysics(),
  //       itemCount: categories.length,
  //       itemBuilder: (context, index) {
  //         final cat = categories[index];
  //         return CategoryItem(
  //           name: cat['name'] as String,
  //           icon: cat['icon'] as IconData,
  //           color: cat['color'] as Color,
  //           index: index,
  //           onTap: () {
  //             if (cat['name'] == 'Teams') {
  //               Navigator.push(
  //                 context,
  //                 MaterialPageRoute(builder: (context) => const TeamsScreen()),
  //               );
  //             } else if (cat['name'] == 'Players') {
  //               Navigator.push(
  //                 context,
  //                 MaterialPageRoute(
  //                   builder: (context) => const PlayersListScreen(),
  //                 ),
  //               );
  //             } else if (cat['name'] == 'Series') {
  //               Navigator.push(
  //                 context,
  //                 MaterialPageRoute(builder: (context) => const SeriesScreen()),
  //               );
  //             } else if (cat['name'] == 'News') {
  //               Navigator.push(
  //                 context,
  //                 MaterialPageRoute(builder: (context) => const NewsScreen()),
  //               );
  //             } else if (cat['name'] == 'Rankings') {
  //               Navigator.push(
  //                 context,
  //                 MaterialPageRoute(builder: (context) => const RankingsScreen()),
  //               );
  //             } else if (cat['name'] == 'Videos') {
  //               Navigator.push(
  //                 context,
  //                 MaterialPageRoute(builder: (context) => const VideosScreen()),
  //               );
  //             }
  //           },
  //         );
  //       },
  //     ),
  //   );
  // }

  Widget _buildLiveMatchesList(MatchProvider provider) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const BouncingScrollPhysics(),
        itemCount: provider.liveMatches.length,
        itemBuilder: (context, index) {
          final match = provider.liveMatches[index];
          return FadeInRight(
            delay: Duration(milliseconds: 200 * index),
            child: LiveScoreCard(
              match: match,
              onTap: () => context.push('/match/${match.id}'),
            ),
          );
        },
      ),
    );
  }
}

class _HomeNoMatchesState extends StatelessWidget {
  final bool hasError;
  final VoidCallback onRetry;
  final VoidCallback? onShowError;

  const _HomeNoMatchesState({
    required this.hasError,
    required this.onRetry,
    this.onShowError,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasError ? Icons.cloud_off_rounded : Icons.event_busy_outlined,
            size: 72,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 20),
          Text(
            hasError ? 'Unable to load matches' : 'No matches to show',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            hasError
                ? 'Check your connection and try again later.'
                : 'Pull down to refresh or use the search bar above.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 14,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 28),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
            ),
          ),
          if (onShowError != null) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: onShowError,
              icon: const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
              label: const Text('Error details', style: TextStyle(color: AppColors.primary)),
            ),
          ],
        ],
      ),
    );
  }
}
