import '../services/api_service.dart';

class MatchApi {
  static Future getRecentMatches({bool forceRefresh = false}) async {
    return ApiService.getCached(
      '/matches/v1/recent',
      ttl: CacheTtls.liveData,
      forceRefresh: forceRefresh,
    );
  }

  static Future getLiveMatches({bool forceRefresh = false}) async {
    return ApiService.getCached(
      '/matches/v1/live',
      ttl: CacheTtls.liveData,
      forceRefresh: forceRefresh,
    );
  }

  static Future getUpcomingMatches({bool forceRefresh = false}) async {
    return ApiService.getCached(
      '/matches/v1/upcoming',
      ttl: CacheTtls.liveData,
      forceRefresh: forceRefresh,
    );
  }

  static Future getMatchInfo(String matchId, {bool forceRefresh = false}) async {
    return ApiService.getCached(
      '/mcenter/v1/$matchId',
      ttl: CacheTtls.matchCenter,
      forceRefresh: forceRefresh,
    );
  }

  static Future getScorecard(String matchId, {bool forceRefresh = false}) async {
    return ApiService.getCached(
      '/mcenter/v1/$matchId/scard',
      ttl: CacheTtls.matchCenter,
      forceRefresh: forceRefresh,
    );
  }

  static Future getCommentary(String matchId, {bool forceRefresh = false}) async {
    return ApiService.getCached(
      '/mcenter/v1/$matchId/comm',
      ttl: CacheTtls.matchCenter,
      forceRefresh: forceRefresh,
    );
  }

  static Future getCommentaryV2(String matchId, {bool forceRefresh = false}) async {
    return ApiService.getCached(
      '/mcenter/v1/$matchId/hcomm',
      ttl: CacheTtls.matchCenter,
      forceRefresh: forceRefresh,
    );
  }

  static Future getOvers(String matchId, {bool forceRefresh = false}) async {
    return ApiService.getCached(
      '/mcenter/v1/$matchId/overs',
      ttl: CacheTtls.matchCenter,
      forceRefresh: forceRefresh,
    );
  }

  static Future getTeam(String matchId, String teamId, {bool forceRefresh = false}) async {
    return ApiService.getCached(
      '/mcenter/v1/$matchId/team/$teamId',
      ttl: CacheTtls.matchCenter,
      forceRefresh: forceRefresh,
    );
  }

  static Future getHighlightsScorecard(String matchId, {bool forceRefresh = false}) async {
    return ApiService.getCached(
      '/mcenter/v1/$matchId/hscard',
      ttl: CacheTtls.matchCenter,
      forceRefresh: forceRefresh,
    );
  }

  static Future getMatchSchedule(String type, {bool forceRefresh = false}) async {
    return ApiService.getCached(
      '/schedule/v1/$type',
      ttl: CacheTtls.schedule,
      forceRefresh: forceRefresh,
    );
  }
}
