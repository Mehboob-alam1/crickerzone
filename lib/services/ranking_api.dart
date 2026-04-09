import '../services/api_service.dart';

class RankingApi {
  static Future getTeamRankings(String format) async {
    final res = await ApiService.dio.get(
      '/stats/v1/rankings/teams',
      queryParameters: {'formatType': format},
    );
    return res.data;
  }

  static Future getPlayerRankings(String category, String format) async {
    final res = await ApiService.dio.get(
      '/stats/v1/rankings/$category',
      queryParameters: {'formatType': format},
    );
    return res.data;
  }

  /// Risposta tipo `stats/get-icc-rankings` con chiave `rank`.
  static Future<dynamic> getIccPlayerRankings({
    required String category,
    required String format,
  }) async {
    final res = await ApiService.dio.get(
      '/stats/v1/icc-rankings',
      queryParameters: {'category': category, 'formatType': format},
    );
    return res.data;
  }

  /// Classifiche WTC: `headers`, `values[].value`, `seasonStandings`, `subText`.
  static Future<dynamic> getIccStandings() async {
    final res = await ApiService.dio.get('/stats/v1/icc-standings');
    return res.data;
  }

  static Future<dynamic> getRecordFilters() async {
    final res = await ApiService.dio.get('/stats/v1/records/filters');
    return res.data;
  }

  static Future<dynamic> getRecords({
    String? statsType,
    String? matchType,
    String? teamId,
  }) async {
    final qp = <String, dynamic>{};
    if (statsType != null) qp['type'] = statsType;
    if (matchType != null) qp['matchType'] = matchType;
    if (teamId != null) qp['teamId'] = teamId;
    final res = await ApiService.dio.get(
      '/stats/v1/records',
      queryParameters: qp.isEmpty ? null : qp,
    );
    return res.data;
  }
}
