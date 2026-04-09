import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:go_router/go_router.dart';
import 'package:score_zone/core/constants/colors.dart';
import 'package:score_zone/providers/match_provider.dart';
import 'package:score_zone/widgets/live_score_card.dart';
import 'package:score_zone/widgets/section_header.dart';
import 'package:score_zone/widgets/category_item.dart';
import 'package:score_zone/widgets/drawer_item.dart';
import 'package:score_zone/screens/player/players_list_screen.dart';
import 'package:score_zone/screens/team/teams_screen.dart';
import 'package:score_zone/screens/series/series_screen.dart';
import 'package:score_zone/screens/news/news_screen.dart';
import 'package:score_zone/screens/rankings/rankings_screen.dart';
import 'package:score_zone/screens/videos/videos_screen.dart';
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
    // Small delay to ensure context is available and avoid calling during build
    await Future.delayed(Duration.zero);
    if (mounted) {
      context.read<MatchProvider>().fetchMatches();
    }
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

          return RefreshIndicator(
            onRefresh: () => provider.fetchMatches(forceRefresh: true),
            color: AppColors.primary,
            backgroundColor: AppColors.surface,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                // Search Bar in body for better accessibility
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

                // SliverToBoxAdapter(
                //   child: FadeInDown(
                //     duration: const Duration(milliseconds: 500),
                //     child: _buildCategories(),
                //   ),
                // ),

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
