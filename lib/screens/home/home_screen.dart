import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/constants/colors.dart';
import '../../providers/match_provider.dart';
import '../../widgets/match_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/category_item.dart';
import '../../widgets/drawer_item.dart';
import '../player/players_list_screen.dart';
import '../team/teams_screen.dart';

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
        title: FadeInLeft(child: const Text('SCORE ZONE')),
        actions: [
          FadeInRight(
            child: Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.search_rounded),
                  tooltip: 'Search matches',
                ),
                Stack(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.notifications_none_rounded),
                    ),
                    Positioned(
                      right: 12,
                      top: 12,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.error,
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
            onRefresh: () => provider.fetchMatches(),
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
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search for series, teams or players...',
                          prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                          filled: true,
                          fillColor: AppColors.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        ),
                      ),
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: FadeInDown(
                    duration: const Duration(milliseconds: 500),
                    child: _buildCategories()
                  ),
                ),
                
                if (provider.liveMatches.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: FadeInLeft(
                      child: const SectionHeader(title: 'Live Matches', isLive: true)
                    ),
                  ),
                  SliverToBoxAdapter(child: _buildLiveMatchesList(provider)),
                ],
                
                if (provider.upcomingMatches.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: FadeInLeft(
                      delay: const Duration(milliseconds: 200),
                      child: const SectionHeader(title: 'Upcoming Matches')
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => FadeInUp(
                          delay: Duration(milliseconds: 100 * index),
                          child: MatchCard(match: provider.upcomingMatches[index]),
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
                      child: const SectionHeader(title: 'Recent Matches')
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => FadeInUp(
                          delay: Duration(milliseconds: 100 * index),
                          child: MatchCard(match: provider.recentMatches[index]),
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
              image: DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1531415074968-036ba1b575da?w=500&auto=format&fit=crop&q=60'),
                fit: BoxFit.cover,
                opacity: 0.15,
              ),
            ),
            child: Center(
              child: ZoomIn(
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.sports_cricket, color: AppColors.primary, size: 48),
                    SizedBox(height: 12),
                    Text('SCORE ZONE',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2)),
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
            onTap: () => Navigator.pop(context),
          ),
          DrawerItem(
            icon: Icons.group_rounded,
            title: 'Teams',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const TeamsScreen()));
            },
          ),
          DrawerItem(
            icon: Icons.person_rounded,
            title: 'Players',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const PlayersListScreen()));
            },
          ),
          DrawerItem(
            icon: Icons.leaderboard_rounded,
            title: 'Rankings',
            onTap: () => Navigator.pop(context),
          ),
          DrawerItem(
            icon: Icons.newspaper_rounded,
            title: 'News',
            onTap: () => Navigator.pop(context),
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
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    final categories = [
      {'name': 'News', 'icon': Icons.newspaper_rounded, 'color': Colors.blue},
      {'name': 'Videos', 'icon': Icons.play_circle_fill_rounded, 'color': Colors.red},
      {'name': 'Rankings', 'icon': Icons.leaderboard_rounded, 'color': Colors.orange},
      {'name': 'Series', 'icon': Icons.emoji_events_rounded, 'color': AppColors.primary},
      {'name': 'Teams', 'icon': Icons.group_rounded, 'color': Colors.purple},
      {'name': 'Players', 'icon': Icons.person_rounded, 'color': Colors.teal},
    ];

    return SizedBox(
      height: 130,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          return CategoryItem(
            name: cat['name'] as String,
            icon: cat['icon'] as IconData,
            color: cat['color'] as Color,
            index: index,
            onTap: () {
              if (cat['name'] == 'Teams') {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const TeamsScreen()));
              } else if (cat['name'] == 'Players') {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const PlayersListScreen()));
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildLiveMatchesList(MatchProvider provider) {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const BouncingScrollPhysics(),
        itemCount: provider.liveMatches.length,
        itemBuilder: (context, index) => FadeInRight(
          delay: Duration(milliseconds: 200 * index),
          child: MatchCard(match: provider.liveMatches[index], isLive: true)
        ),
      ),
    );
  }
}
