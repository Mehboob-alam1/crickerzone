import '../services/api_service.dart';

class PlayerApi {
  static Future getTrendingPlayers({bool forceRefresh = false}) async {
    return ApiService.getCached(
      '/stats/v1/player/trending',
      ttl: CacheTtls.playerTrending,
      forceRefresh: forceRefresh,
    );
  }

  static Future getPlayerInfo(String playerId, {bool forceRefresh = false}) async {
    return ApiService.getCached(
      '/stats/v1/player/$playerId',
      ttl: CacheTtls.playerProfile,
      forceRefresh: forceRefresh,
    );
  }

  static Future getPlayerBatting(String playerId, {bool forceRefresh = false}) async {
    return ApiService.getCached(
      '/stats/v1/player/$playerId/batting',
      ttl: CacheTtls.playerProfile,
      forceRefresh: forceRefresh,
    );
  }

  static Future getPlayerBowling(String playerId, {bool forceRefresh = false}) async {
    return ApiService.getCached(
      '/stats/v1/player/$playerId/bowling',
      ttl: CacheTtls.playerProfile,
      forceRefresh: forceRefresh,
    );
  }

  static Future searchPlayer(String name, {bool forceRefresh = false}) async {
    return ApiService.getCached(
      '/stats/v1/player/search',
      queryParameters: {'plrN': name},
      ttl: CacheTtls.playerSearch,
      forceRefresh: forceRefresh,
    );
  }

  static Future getPlayerCareer(String playerId, {bool forceRefresh = false}) async {
    return ApiService.getCached(
      '/stats/v1/player/$playerId/career',
      ttl: CacheTtls.playerProfile,
      forceRefresh: forceRefresh,
    );
  }

  static Future getPlayerNews(String playerId, {bool forceRefresh = false}) async {
    return ApiService.getCached(
      '/stats/v1/player/$playerId/news',
      ttl: CacheTtls.newsList,
      forceRefresh: forceRefresh,
    );
  }
}
