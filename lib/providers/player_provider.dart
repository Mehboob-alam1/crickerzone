import 'package:flutter/material.dart';
import '../models/player_model.dart';
import '../services/player_api.dart';

class PlayerProvider with ChangeNotifier {
  PlayerModel? _currentPlayer;
  List<PlayerModel> _trendingPlayers = [];
  List<PlayerModel> _searchResults = [];
  bool _isLoading = false;
  Map<String, dynamic>? _playerBatting;
  Map<String, dynamic>? _playerBowling;
  List<dynamic>? _playerCareer;

  PlayerModel? get currentPlayer => _currentPlayer;
  List<PlayerModel> get trendingPlayers => _trendingPlayers;
  List<PlayerModel> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  Map<String, dynamic>? get playerBatting => _playerBatting;
  Map<String, dynamic>? get playerBowling => _playerBowling;
  List<dynamic>? get playerCareer => _playerCareer;

  Future<void> searchPlayers(String name) async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      final response = await PlayerApi.searchPlayer(name);
      if (response != null && response['player'] != null) {
        _searchResults = (response['player'] as List)
            .map((e) => PlayerModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      } else {
        _searchResults = [];
      }
    } catch (e) {
      debugPrint('Error searching players: $e');
      _searchResults = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchTrendingPlayers() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      final response = await PlayerApi.getTrendingPlayers();
      if (response != null && response['player'] != null) {
        _trendingPlayers = (response['player'] as List)
            .map((e) => PlayerModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
    } catch (e) {
      debugPrint('Trending players restricted or error: $e');
      _trendingPlayers = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPlayerDetails(String id) async {
    _currentPlayer = null;
    _playerBatting = null;
    _playerBowling = null;
    _playerCareer = null;
    _isLoading = true;
    notifyListeners();

    try {
      final response = await PlayerApi.getPlayerInfo(id);
      if (response is Map) {
        _currentPlayer =
            PlayerModel.fromJson(Map<String, dynamic>.from(response));
      }
    } catch (e) {
      debugPrint('Error fetching player details: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    if (_currentPlayer == null) return;

    try {
      final bat = await PlayerApi.getPlayerBatting(id);
      if (bat is Map) {
        _playerBatting = Map<String, dynamic>.from(bat as Map);
      }
    } catch (e) {
      debugPrint('Batting stats: $e');
    }
    _playerBatting ??= {'headers': <dynamic>[], 'values': <dynamic>[]};
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));

    try {
      final bowl = await PlayerApi.getPlayerBowling(id);
      if (bowl is Map) {
        _playerBowling = Map<String, dynamic>.from(bowl as Map);
      }
    } catch (e) {
      debugPrint('Bowling stats: $e');
    }
    _playerBowling ??= {'headers': <dynamic>[], 'values': <dynamic>[]};
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));

    try {
      final career = await PlayerApi.getPlayerCareer(id);
      if (career is Map && career['values'] is List) {
        _playerCareer = List<dynamic>.from(career['values'] as List);
      } else {
        _playerCareer = [];
      }
    } catch (e) {
      debugPrint('Career: $e');
      _playerCareer = [];
    }
    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> fetchPlayerNews(String id) async {
    try {
      final response = await PlayerApi.getPlayerNews(id);
      if (response is! Map || response['storyList'] is! List) return [];
      final out = <Map<String, dynamic>>[];
      for (final item in response['storyList'] as List) {
        if (item is! Map) continue;
        final m = Map<String, dynamic>.from(item);
        if (m['story'] is Map) {
          out.add(Map<String, dynamic>.from(m['story'] as Map));
        }
      }
      return out;
    } catch (e) {
      debugPrint('Player news: $e');
      return [];
    }
  }
}
