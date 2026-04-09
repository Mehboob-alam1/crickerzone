import '../services/api_service.dart';

class TeamApi {
  static Future getTeams({bool forceRefresh = false}) async {
    return ApiService.getCached(
      '/teams/v1/international',
      ttl: CacheTtls.teamsList,
      forceRefresh: forceRefresh,
    );
  }

  static Future getTeamPlayers(String teamId, {bool forceRefresh = false}) async {
    return ApiService.getCached(
      '/teams/v1/$teamId/players',
      ttl: CacheTtls.teamDetail,
      forceRefresh: forceRefresh,
    );
  }

  static Future getTeamMatches(String teamId, {bool forceRefresh = false}) async {
    return ApiService.getCached(
      '/teams/v1/$teamId/schedule',
      ttl: CacheTtls.teamDetail,
      forceRefresh: forceRefresh,
    );
  }

  static Future getTeamResults(String teamId, {bool forceRefresh = false}) async {
    return ApiService.getCached(
      '/teams/v1/$teamId/results',
      ttl: CacheTtls.teamDetail,
      forceRefresh: forceRefresh,
    );
  }
}
