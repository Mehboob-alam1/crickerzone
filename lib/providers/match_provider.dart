import 'package:flutter/material.dart';
import '../models/match_model.dart';
import '../models/match_schedule_model.dart';
import '../services/match_api.dart';

class MatchProvider with ChangeNotifier {
  List<MatchModel> _matches = [];
  List<MatchScheduleModel> _matchSchedules = [];
  bool _isLoading = false;
  Map<String, dynamic>? _matchScorecard;
  Map<String, dynamic>? _matchCommentary;
  Map<String, dynamic>? _matchInfo;

  List<MatchModel> get matches => _matches;
  List<MatchScheduleModel> get matchSchedules => _matchSchedules;
  bool get isLoading => _isLoading;
  Map<String, dynamic>? get matchScorecard => _matchScorecard;
  Map<String, dynamic>? get matchCommentary => _matchCommentary;
  Map<String, dynamic>? get matchInfo => _matchInfo;

  List<MatchModel> get liveMatches => _matches.where((m) => m.matchType == 'Live').toList();
  List<MatchModel> get upcomingMatches => _matches.where((m) => m.matchType == 'Upcoming').toList();
  List<MatchModel> get recentMatches => _matches.where((m) => m.matchType == 'Recent').toList();

  Future<void> fetchMatchSchedules(String type) async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      final data = await MatchApi.getMatchSchedule(type);
      if (data != null && data['matchScheduleMap'] != null) {
        final List map = data['matchScheduleMap'];
        _matchSchedules = map
            .where((e) => e['scheduleAdWrapper'] != null)
            .map((e) => MatchScheduleModel.fromJson(e))
            .toList();
      }
    } catch (e) {
      debugPrint('Error fetching schedules: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMatches() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      final liveData = await MatchApi.getLiveMatches();
      final upcomingData = await MatchApi.getUpcomingMatches();
      final recentData = await MatchApi.getRecentMatches();

      List<MatchModel> allMatches = [];
      allMatches.addAll(_parseMatches(liveData, 'Live'));
      allMatches.addAll(_parseMatches(upcomingData, 'Upcoming'));
      allMatches.addAll(_parseMatches(recentData, 'Recent'));

      _matches = allMatches;
    } catch (e) {
      debugPrint('Matches restricted or error: $e');
      _matches = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<MatchModel> _parseMatches(dynamic data, String type) {
    List<MatchModel> list = [];
    try {
      if (data != null && data['typeMatches'] != null) {
        for (var typeMatch in data['typeMatches']) {
          if (typeMatch['seriesMatches'] != null) {
            for (var seriesMatch in typeMatch['seriesMatches']) {
              if (seriesMatch['seriesAdWrapper'] != null) {
                final matches = seriesMatch['seriesAdWrapper']['matches'];
                if (matches != null) {
                  for (var m in (matches as List)) {
                    if (m['matchInfo'] != null) {
                      list.add(MatchModel.fromJson(m['matchInfo'], type));
                    }
                  }
                }
              }
            }
          }
        }
      }
      debugPrint('Parsed ${list.length} $type matches');
    } catch (e) {
      debugPrint('Error parsing $type matches: $e');
    }
    return list;
  }

  Future<void> fetchMatchDetails(String matchId) async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();
    try {
      // Fetching sequentially with a small delay to avoid 429 Rate Limit
      _matchScorecard = await MatchApi.getScorecard(matchId);
      await Future.delayed(const Duration(milliseconds: 500));
      
      _matchCommentary = await MatchApi.getCommentary(matchId);
      await Future.delayed(const Duration(milliseconds: 500));
      
      _matchInfo = await MatchApi.getMatchInfo(matchId);
    } catch (e) {
      debugPrint('Error fetching match details: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearMatchDetails() {
    _matchScorecard = null;
    _matchCommentary = null;
    _matchInfo = null;
  }
}

