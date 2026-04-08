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
          if (player == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

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
                      const Text(
                        'CAREER STATS',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildStatsGrid(player),
                      const SizedBox(height: 32),
                      const Text(
                        'RECENT FORM',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: AppColors.primary,
                        ),
                      ),
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    player.name.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    player.role,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (player.team != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  player.team!,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 24),
        _buildInfoRow('Born', player.dob ?? 'N/A'),
        _buildInfoRow('Birth Place', player.birthPlace ?? 'N/A'),
        _buildInfoRow('Height', player.height ?? 'N/A'),
        _buildInfoRow('Batting Style', player.batStyle ?? 'N/A'),
        _buildInfoRow('Bowling Style', player.bowlStyle ?? 'N/A'),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(player) {
    // If stats are not available yet, we could show a placeholder or just hide it
    return const Center(
      child: Text(
        'Career stats available in full subscription',
        style: TextStyle(color: AppColors.textMuted, fontSize: 12),
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
            color: index == 0
                ? AppColors.primary.withValues(alpha: 0.2)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: index == 0
                  ? AppColors.primary
                  : AppColors.textPrimary.withValues(alpha: 0.05),
            ),
          ),
          child: Center(
            child: Text(
              forms[index],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: index == 0 ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
