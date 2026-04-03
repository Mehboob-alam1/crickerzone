import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/player_provider.dart';
import '../../core/constants/colors.dart';

class PlayerProfileScreen extends StatefulWidget {
  final String playerId;
  const PlayerProfileScreen({super.key, required this.playerId});

  @override
  State<PlayerProfileScreen> createState() => _PlayerProfileScreenState();
}

class _PlayerProfileScreenState extends State<PlayerProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if (mounted) {
        context.read<PlayerProvider>().fetchTrendingPlayers();
        context.read<PlayerProvider>().fetchPlayerDetails(widget.playerId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<PlayerProvider>(
        builder: (context, provider, child) {
          final player = provider.currentPlayer;
          if (player == null) return const Center(child: CircularProgressIndicator(color: AppColors.primary));

          return CustomScrollView(
            slivers: [
              _buildAppBar(player),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMainInfo(player),
                      const SizedBox(height: 32),
                      const Text('CAREER STATS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: AppColors.primary)),
                      const SizedBox(height: 16),
                      _buildStatsGrid(player),
                      const SizedBox(height: 32),
                      const Text('RECENT FORM', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: AppColors.primary)),
                      const SizedBox(height: 16),
                      _buildRecentForm(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar(player) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: AppColors.surface,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: player.image,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.1),
                    AppColors.background,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainInfo(player) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name.toUpperCase(),
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
                Text(
                  player.role,
                  style: const TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('RANK #1', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsGrid(player) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        _buildStatCard('RUNS', player.runs, Icons.sports_cricket),
        _buildStatCard('AVERAGE', player.average, Icons.trending_up),
        _buildStatCard('S/R', player.strikeRate, Icons.speed),
        _buildStatCard('WICKETS', player.wickets, Icons.scuba_diving),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primary.withValues(alpha: 0.5), size: 20),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildRecentForm() {
    final forms = ['102', '45', '12', '88*', '67'];
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: forms.length,
        itemBuilder: (context, index) => Container(
          width: 60,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: index == 0 ? AppColors.primary.withValues(alpha: 0.2) : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: index == 0 ? AppColors.primary : Colors.white10),
          ),
          child: Center(
            child: Text(
              forms[index],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: index == 0 ? AppColors.primary : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
