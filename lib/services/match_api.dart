import '../services/api_service.dart';

class MatchApi {

  /// Recent Matches
  static Future getRecentMatches() async {
    final response = await ApiService.dio.get("/matches/v1/recent");
    return response.data;
  }

  /// Live Matches
  static Future getLiveMatches() async {
    final response = await ApiService.dio.get("/matches/v1/live");
    return response.data;
  }

  /// Upcoming Matches
  static Future getUpcomingMatches() async {
    final response = await ApiService.dio.get("/matches/v1/upcoming");
    return response.data;
  }

  /// Match Info
  static Future getMatchInfo(String matchId) async {
    final response = await ApiService.dio.get("/mcenter/v1/$matchId");
    return response.data;
  }

  /// Scorecard
  static Future getScorecard(String matchId) async {
    final response = await ApiService.dio.get("/mcenter/v1/$matchId/scard");
    return response.data;
  }

  /// Commentary
  static Future getCommentary(String matchId) async {
    final response = await ApiService.dio.get("/mcenter/v1/$matchId/comm");
    return response.data;
  }

  /// Commentary V2
  static Future getCommentaryV2(String matchId) async {
    final response = await ApiService.dio.get("/mcenter/v1/$matchId/hcomm");
    return response.data;
  }

  /// Overs
  static Future getOvers(String matchId) async {
    final response = await ApiService.dio.get("/mcenter/v1/$matchId/overs");
    return response.data;
  }

  /// Team Info in Match
  static Future getTeam(String matchId, String teamId) async {
    final response =
    await ApiService.dio.get("/mcenter/v1/$matchId/team/$teamId");
    return response.data;
  }

  /// Highlights Scorecard
  static Future getHighlightsScorecard(String matchId) async {
    final response = await ApiService.dio.get("/mcenter/v1/$matchId/hscard");
    return response.data;
  }

  /// Match Schedule
  static Future getMatchSchedule(String type) async {
    // type can be 'international', 'domestic', 't20', 'women'
    final response = await ApiService.dio.get("/schedule/v1/$type");
    return response.data;
  }
}