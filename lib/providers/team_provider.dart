import 'package:flutter/material.dart';
import '../models/team_model.dart';
import '../services/team_api.dart';

class TeamProvider with ChangeNotifier {
  List<TeamModel> _teams = [];
  bool _isLoading = false;

  List<TeamModel> get teams => _teams;
  bool get isLoading => _isLoading;

  Future<void> fetchTeams({bool forceRefresh = false}) async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      final response = await TeamApi.getTeams(forceRefresh: forceRefresh);
      if (response != null && response['list'] != null) {
        String? currentCategory;
        _teams = (response['list'] as List).map((e) {
          final json = Map<String, dynamic>.from(e as Map);
          final isSectionHeader = json['teamId'] == null;
          final name =
              json['teamName']?.toString() ?? json['name']?.toString() ?? '';

          if (isSectionHeader) {
            currentCategory = name;
          }

          return TeamModel.fromJson(
            json,
            category: currentCategory,
          );
        }).toList();
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

