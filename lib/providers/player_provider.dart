import 'package:flutter/material.dart';
import '../models/player_model.dart';
import '../services/player_api.dart';

class PlayerProvider with ChangeNotifier {
  PlayerModel? _currentPlayer;
  List<PlayerModel> _trendingPlayers = [];
  List<PlayerModel> _searchResults = [];
  bool _isLoading = false;

  PlayerModel? get currentPlayer => _currentPlayer;
  List<PlayerModel> get trendingPlayers => _trendingPlayers;
  List<PlayerModel> get searchResults => _searchResults;
  bool get isLoading => _isLoading;

  Future<void> searchPlayers(String name) async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      final response = await PlayerApi.searchPlayer(name);
      if (response != null && response['player'] != null) {
        _searchResults = (response['player'] as List)
            .map((player) => PlayerModel.fromJson(player))
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
            .map((player) => PlayerModel.fromJson(player))
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
    if (_isLoading) return;
    _isLoading = true;
    _currentPlayer = null;
    notifyListeners();

    try {
      final response = await PlayerApi.getPlayerInfo(id);
      if (response != null) {
        _currentPlayer = PlayerModel.fromJson(response);
      }
    } catch (e) {
      debugPrint('Error fetching player details: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

