// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:score_zone/main.dart';
import 'package:score_zone/providers/match_provider.dart';
import 'package:score_zone/providers/news_provider.dart';
import 'package:score_zone/providers/ranking_provider.dart';
import 'package:score_zone/providers/series_provider.dart';
import 'package:score_zone/providers/team_provider.dart';
import 'package:score_zone/providers/player_provider.dart';

void main() {
  testWidgets('App splash screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MatchProvider()),
          ChangeNotifierProvider(create: (_) => TeamProvider()),
          ChangeNotifierProvider(create: (_) => PlayerProvider()),
          ChangeNotifierProvider(create: (_) => NewsProvider()),
          ChangeNotifierProvider(create: (_) => SeriesProvider()),
          ChangeNotifierProvider(create: (_) => RankingProvider()),
        ],
        child: const ScoreZoneApp(),
      ),
    );

    // Verify that splash screen text is present.
    expect(find.text('SCORE ZONE'), findsOneWidget);
  });
}
