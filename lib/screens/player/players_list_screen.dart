import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/player_provider.dart';
import '../../core/constants/colors.dart';
import '../../widgets/player_card.dart';

class PlayersListScreen extends StatefulWidget {
  const PlayersListScreen({super.key});

  @override
  State<PlayersListScreen> createState() => _PlayersListScreenState();
}

class _PlayersListScreenState extends State<PlayersListScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if (mounted) {
        context.read<PlayerProvider>().fetchTrendingPlayers();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('PLAYERS'),
        centerTitle: true,
      ),
      body: Consumer<PlayerProvider>(
        builder: (context, provider, child) {
          Future<void> onRefresh() =>
              context.read<PlayerProvider>().fetchTrendingPlayers(forceRefresh: true);

          if (provider.isLoading && provider.trendingPlayers.isEmpty) {
            return RefreshIndicator(
              onRefresh: onRefresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(
                    height: 400,
                    child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                  ),
                ],
              ),
            );
          }

          final players = provider.trendingPlayers;
          if (players.isEmpty) {
            return RefreshIndicator(
              onRefresh: onRefresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(
                    height: 240,
                    child: Center(
                      child: Text(
                        'No featured players',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: onRefresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: players.length,
              itemBuilder: (context, index) {
                return PlayerCard(
                  player: players[index],
                  index: index,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
