import 'package:flutter/material.dart';
import '../models/team_model.dart';
import '../services/team_api.dart';

class TeamProvider with ChangeNotifier {
  List<TeamModel> _teams = [];
  bool _isLoading = false;

  List<TeamModel> get teams => _teams;
  bool get isLoading => _isLoading;

  Future<void> fetchTeams() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      final response = await TeamApi.getTeams();
      if (response != null && response['list'] != null) {
        _teams = (response['list'] as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .map(TeamModel.fromJson)
            .toList();
      }
    } catch (e) {
      debugPrint('Teams restricted or error: $e');
      _teams = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<dynamic>> fetchTeamMatches(String teamId) async {
    try {
      final response = await TeamApi.getTeamMatches(teamId);
      if (response == null) return [];
      return (response['teamMatchesData'] ?? response['schedule'] ?? []) as List;
    } catch (e) {
      debugPrint('Error fetching team matches: $e');
      return [];
    }
  }

  Future<List<dynamic>> fetchTeamResults(String teamId) async {
    try {
      final response = await TeamApi.getTeamResults(teamId);
      if (response == null) return [];
      return (response['teamMatchesData'] ?? response['results'] ?? []) as List;
    } catch (e) {
      debugPrint('Error fetching team results: $e');
      return [];
    }
  }

  Future<List<dynamic>> fetchTeamPlayers(String teamId) async {
    try {
      final response = await TeamApi.getTeamPlayers(teamId);
      if (response == null) return [];
      return response['player'] ?? [];
    } catch (e) {
      debugPrint('Error fetching team players: $e');
      return [];
    }
  }

}

