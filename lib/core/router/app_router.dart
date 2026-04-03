import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../screens/splash/splash_screen.dart';
import '../../screens/main_screen.dart';
import '../../screens/match/match_detail_screen.dart';
import '../../screens/player/player_profile_screen.dart';
import '../../screens/player/players_list_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/main',
        builder: (context, state) => const MainScreen(),
      ),
      GoRoute(
        path: '/players',
        builder: (context, state) => const PlayersListScreen(),
      ),
      GoRoute(
        path: '/match/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return MatchDetailScreen(matchId: id);
        },
      ),
      GoRoute(
        path: '/player/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return PlayerProfileScreen(playerId: id);
        },
      ),
    ],
  );
}
