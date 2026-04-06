import '../services/api_service.dart';

class SeriesApi {

  static Future getInternationalSeries() async {
    final res = await ApiService.dio.get("/series/v1/international");
    return res.data;
  }

  static Future getSeriesMatches(String seriesId) async {
    final res = await ApiService.dio.get("/series/v1/$seriesId");
    return res.data;
  }

  static Future getSeriesSquads(String seriesId) async {
    final res = await ApiService.dio.get("/series/v1/$seriesId/squads");
    return res.data;
  }

  static Future getPointsTable(String seriesId) async {
    final res =
    await ApiService.dio.get("/stats/v1/series/$seriesId/points-table");
    return res.data;
  }
}