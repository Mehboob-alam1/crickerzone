import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../screens/splash/splash_screen.dart';
import '../../screens/main_screen.dart';
import '../../screens/match/match_detail_screen.dart';
import '../../screens/player/player_profile_screen.dart';
import '../../screens/player/players_list_screen.dart';
import '../../screens/team/team_detail_screen.dart';
import '../../screens/team/teams_screen.dart';
import '../../screens/series/series_screen.dart';
import '../../screens/news/news_screen.dart';
import '../../screens/rankings/rankings_screen.dart';
import '../../screens/videos/videos_screen.dart';
import '../../screens/notifications/notifications_screen.dart';
import '../../screens/about/about_screen.dart';
import '../../screens/schedule/schedule_screen.dart';
import '../../screens/settings/settings_screen.dart';
import '../../screens/favorites/favorites_screen.dart';
import '../../screens/search/search_screen.dart';

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
        path: '/schedule',
        builder: (context, state) => const ScheduleScreen(),
      ),
      GoRoute(
        path: '/teams',
        builder: (context, state) => const TeamsScreen(),
      ),
      GoRoute(
        path: '/players',
        builder: (context, state) => const PlayersListScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/favorites',
        builder: (context, state) => const FavoritesScreen(),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchScreen(),
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
      GoRoute(
        path: '/team/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return TeamDetailScreen(teamId: id);
        },
      ),
      GoRoute(
        path: '/series',
        builder: (context, state) => const SeriesScreen(),
      ),
      GoRoute(
        path: '/news',
        builder: (context, state) => const NewsScreen(),
      ),
      GoRoute(
        path: '/rankings',
        builder: (context, state) => const RankingsScreen(),
      ),
      GoRoute(
        path: '/videos',
        builder: (context, state) => const VideosScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/about',
        builder: (context, state) => const AboutScreen(),
      ),
    ],
  );
}
