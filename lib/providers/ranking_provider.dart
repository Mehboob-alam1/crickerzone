import 'package:flutter/material.dart';
import '../models/ranking_model.dart';
import '../services/ranking_api.dart';

class RankingProvider with ChangeNotifier {
  List<RankingModel> _teamRankings = [];
  List<RankingModel> _batterRankings = [];
  List<RankingModel> _bowlerRankings = [];
  Map<String, dynamic>? _iccStandings;
  bool _isLoading = false;

  List<RankingModel> get teamRankings => _teamRankings;
  List<RankingModel> get batterRankings => _batterRankings;
  List<RankingModel> get bowlerRankings => _bowlerRankings;
  Map<String, dynamic>? get iccStandings => _iccStandings;
  bool get isLoading => _isLoading;

  Future<void> fetchAllRankings(String format, {bool forceRefresh = false}) async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      _parseRankList(
        await RankingApi.getTeamRankings(format, forceRefresh: forceRefresh),
        (list) {
        _teamRankings = list;
      },
      );
      _parseRankList(
        await RankingApi.getPlayerRankings('batsmen', format, forceRefresh: forceRefresh),
        (list) {
        _batterRankings = list;
      },
      );
      _parseRankList(
        await RankingApi.getPlayerRankings('bowlers', format, forceRefresh: forceRefresh),
        (list) {
        _bowlerRankings = list;
      },
      );

      try {
        final stand = await RankingApi.getIccStandings(forceRefresh: forceRefresh);
        if (stand is Map) {
          _iccStandings = Map<String, dynamic>.from(stand);
        } else {
          _iccStandings = null;
        }
      } catch (e) {
        debugPrint('ICC standings: $e');
        _iccStandings = null;
      }
    } catch (e) {
      debugPrint('Rankings restricted or error: $e');
      _teamRankings = [];
      _batterRankings = [];
      _bowlerRankings = [];
      _iccStandings = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _parseRankList(dynamic res, void Function(List<RankingModel>) assign) {
    if (res is! Map || res['rank'] is! List) {
      assign([]);
      return;
    }
    assign(
      (res['rank'] as List)
          .whereType<Map>()
          .map((e) => RankingModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}
