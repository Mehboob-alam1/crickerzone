import '../services/api_service.dart';

class RankingApi {
  static Future getTeamRankings(String format, {bool forceRefresh = false}) async {
    return ApiService.getCached(
      '/stats/v1/rankings/teams',
      queryParameters: {'formatType': format},
      ttl: CacheTtls.rankings,
      forceRefresh: forceRefresh,
    );
  }

  static Future getPlayerRankings(String category, String format, {bool forceRefresh = false}) async {
    return ApiService.getCached(
      '/stats/v1/rankings/$category',
      queryParameters: {'formatType': format},
      ttl: CacheTtls.rankings,
      forceRefresh: forceRefresh,
    );
  }

  static Future<dynamic> getIccPlayerRankings({
    required String category,
    required String format,
    bool forceRefresh = false,
  }) async {
    return ApiService.getCached(
      '/stats/v1/icc-rankings',
      queryParameters: {'category': category, 'formatType': format},
      ttl: CacheTtls.rankings,
      forceRefresh: forceRefresh,
    );
  }

  static Future getIccStandings({bool forceRefresh = false}) async {
    return ApiService.getCached(
      '/stats/v1/icc-standings',
      ttl: CacheTtls.standings,
      forceRefresh: forceRefresh,
    );
  }

  static Future getRecordFilters({bool forceRefresh = false}) async {
    return ApiService.getCached(
      '/stats/v1/records/filters',
      ttl: CacheTtls.statsMeta,
      forceRefresh: forceRefresh,
    );
  }

  static Future getRecords({
    String? statsType,
    String? matchType,
    String? teamId,
    bool forceRefresh = false,
  }) async {
    final qp = <String, dynamic>{};
    if (statsType != null) qp['type'] = statsType;
    if (matchType != null) qp['matchType'] = matchType;
    if (teamId != null) qp['teamId'] = teamId;
    return ApiService.getCached(
      '/stats/v1/records',
      queryParameters: qp.isEmpty ? null : qp,
      ttl: CacheTtls.statsMeta,
      forceRefresh: forceRefresh,
    );
  }
}
