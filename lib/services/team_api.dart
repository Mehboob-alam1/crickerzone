import '../services/api_service.dart';

class TeamApi {

  static Future getTeams() async {
    final res = await ApiService.dio.get("/teams/v1/international");
    return res.data;
  }

  static Future getTeamPlayers(String teamId) async {
    final res = await ApiService.dio.get("/teams/v1/$teamId/players");
    return res.data;
  }

  static Future getTeamMatches(String teamId) async {
    final res = await ApiService.dio.get("/teams/v1/$teamId/schedule");
    return res.data;
  }

  static Future getTeamResults(String teamId) async {
    final res = await ApiService.dio.get("/teams/v1/$teamId/results");
    return res.data;
  }
}