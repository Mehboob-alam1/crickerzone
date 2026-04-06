import 'package:flutter/material.dart';
import '../models/ranking_model.dart';
import '../services/ranking_api.dart';

class RankingProvider with ChangeNotifier {
  List<RankingModel> _teamRankings = [];
  List<RankingModel> _batterRankings = [];
  List<RankingModel> _bowlerRankings = [];
  bool _isLoading = false;

  List<RankingModel> get teamRankings => _teamRankings;
  List<RankingModel> get batterRankings => _batterRankings;
  List<RankingModel> get bowlerRankings => _bowlerRankings;
  bool get isLoading => _isLoading;

  Future<void> fetchAllRankings(String format) async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      final teamRes = await RankingApi.getTeamRankings(format);
      if (teamRes != null && teamRes['rank'] != null) {
        _teamRankings = (teamRes['rank'] as List)
            .map((e) => RankingModel.fromJson(e))
            .toList();
      }

      final batterRes = await RankingApi.getPlayerRankings('batsmen', format);
      if (batterRes != null && batterRes['rank'] != null) {
        _batterRankings = (batterRes['rank'] as List)
            .map((e) => RankingModel.fromJson(e))
            .toList();
      }

      final bowlerRes = await RankingApi.getPlayerRankings('bowlers', format);
      if (bowlerRes != null && bowlerRes['rank'] != null) {
        _bowlerRankings = (bowlerRes['rank'] as List)
            .map((e) => RankingModel.fromJson(e))
            .toList();
      }
    } catch (e) {
      debugPrint('Rankings restricted or error: $e');
      _teamRankings = [];
      _batterRankings = [];
      _bowlerRankings = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
