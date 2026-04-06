import '../services/api_service.dart';

class RankingApi {
  static Future getTeamRankings(String format) async {
    // format can be: test, odi, t20
    final res = await ApiService.dio.get("/stats/v1/rankings/teams?formatType=$format");
    return res.data;
  }

  static Future getPlayerRankings(String category, String format) async {
    // category: batsmen, bowlers, allrounders
    // format: test, odi, t20
    final res = await ApiService.dio.get("/stats/v1/rankings/$category?formatType=$format");
    return res.data;
  }
}
