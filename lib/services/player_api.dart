import '../services/api_service.dart';

class PlayerApi {

  static Future getTrendingPlayers() async {
    final res = await ApiService.dio.get("/stats/v1/player/trending");
    return res.data;
  }

  static Future getPlayerInfo(String playerId) async {
    final res = await ApiService.dio.get("/stats/v1/player/$playerId");
    return res.data;
  }

  static Future getPlayerBatting(String playerId) async {
    final res =
    await ApiService.dio.get("/stats/v1/player/$playerId/batting");
    return res.data;
  }

  static Future getPlayerBowling(String playerId) async {
    final res =
    await ApiService.dio.get("/stats/v1/player/$playerId/bowling");
    return res.data;
  }

  static Future searchPlayer(String name) async {
    final res =
    await ApiService.dio.get("/stats/v1/player/search?plrN=$name");
    return res.data;
  }
}