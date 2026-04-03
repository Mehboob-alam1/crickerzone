import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/match_provider.dart';
import 'providers/team_provider.dart';
import 'providers/player_provider.dart';
import 'core/router/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MatchProvider()),
        ChangeNotifierProvider(create: (_) => TeamProvider()),
        ChangeNotifierProvider(create: (_) => PlayerProvider()),
      ],
      child: const ScoreZoneApp(),
    ),
  );
}

class ScoreZoneApp extends StatelessWidget {
  const ScoreZoneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Score Zone',
      theme: AppTheme.darkTheme,
      routerConfig: AppRouter.router,
    );
  }
}
