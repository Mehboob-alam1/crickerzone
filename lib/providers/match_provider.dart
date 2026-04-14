import 'package:flutter/material.dart';
import '../models/match_model.dart';
import '../models/match_schedule_model.dart';
import '../services/match_api.dart';

class MatchProvider with ChangeNotifier {
  List<MatchModel> _matches = [];
  List<MatchScheduleModel> _matchSchedules = [];
  bool _isLoading = false;
  String? _matchesLoadError;
  Map<String, dynamic>? _matchScorecard;
  Map<String, dynamic>? _matchCommentary;
  Map<String, dynamic>? _matchInfo;
  Map<String, dynamic>? _matchOvers;

  List<MatchModel> get matches => _matches;
  List<MatchScheduleModel> get matchSchedules => _matchSchedules;
  bool get isLoading => _isLoading;
  String? get matchesLoadError => _matchesLoadError;
  Map<String, dynamic>? get matchScorecard => _matchScorecard;
  Map<String, dynamic>? get matchCommentary => _matchCommentary;
  Map<String, dynamic>? get matchInfo => _matchInfo;
  Map<String, dynamic>? get matchOvers => _matchOvers;

  List<MatchModel> get liveMatches => _matches.where((m) => m.matchType == 'Live').toList();
  List<MatchModel> get upcomingMatches => _matches.where((m) => m.matchType == 'Upcoming').toList();
  List<MatchModel> get recentMatches => _matches.where((m) => m.matchType == 'Recent').toList();

  Future<void> fetchMatchSchedules(String type, {bool forceRefresh = false}) async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      final data = await MatchApi.getMatchSchedule(type, forceRefresh: forceRefresh);
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

  Future<void> fetchMatches({bool forceRefresh = false}) async {
    if (_isLoading) return;
    _isLoading = true;
    _matchesLoadError = null;
    notifyListeners();

    try {
      final liveData = await MatchApi.getLiveMatches(forceRefresh: forceRefresh);
      final upcomingData = await MatchApi.getUpcomingMatches(forceRefresh: forceRefresh);
      final recentData = await MatchApi.getRecentMatches(forceRefresh: forceRefresh);

      List<MatchModel> allMatches = [];
      allMatches.addAll(_parseMatches(liveData, 'Live'));
      allMatches.addAll(_parseMatches(upcomingData, 'Upcoming'));
      allMatches.addAll(_parseMatches(recentData, 'Recent'));

      _matches = allMatches;
      _matchesLoadError = null;
    } catch (e, st) {
      debugPrint('Matches restricted or error: $e\n$st');
      _matchesLoadError = e.toString();
      _matches = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearMatchesLoadError() {
    _matchesLoadError = null;
    notifyListeners();
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
                      list.add(MatchModel.fromJson(m, type));
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

  Future<void> fetchMatchDetails(String matchId, {bool forceRefresh = false}) async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();
    try {
      // Fetching with small delays to avoid 429 Rate Limit
      _matchScorecard = await MatchApi.getScorecard(matchId, forceRefresh: forceRefresh);
      await Future.delayed(const Duration(milliseconds: 300));
      
      _matchCommentary = await MatchApi.getCommentary(matchId, forceRefresh: forceRefresh);
      await Future.delayed(const Duration(milliseconds: 300));
      
      _matchInfo = await MatchApi.getMatchInfo(matchId, forceRefresh: forceRefresh);
      await Future.delayed(const Duration(milliseconds: 300));

      _matchOvers = await MatchApi.getOvers(matchId, forceRefresh: forceRefresh);
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
    _matchOvers = null;
  }
}

