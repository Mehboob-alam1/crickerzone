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
          final players = provider.trendingPlayers;
          
          if (players.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: players.length,
            itemBuilder: (context, index) {
              return PlayerCard(
                player: players[index],
                index: index,
              );
            },
          );
        },
      ),
    );
  }
}
