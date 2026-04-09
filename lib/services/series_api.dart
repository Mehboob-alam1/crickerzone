import '../services/api_service.dart';

class SeriesApi {
  static Future getInternationalSeries({bool forceRefresh = false}) async {
    return ApiService.getCached(
      '/series/v1/international',
      ttl: CacheTtls.seriesList,
      forceRefresh: forceRefresh,
    );
  }

  static Future getSeriesMatches(String seriesId, {bool forceRefresh = false}) async {
    return ApiService.getCached(
      '/series/v1/$seriesId',
      ttl: CacheTtls.seriesDetail,
      forceRefresh: forceRefresh,
    );
  }

  static Future getSeriesSquads(String seriesId, {bool forceRefresh = false}) async {
    return ApiService.getCached(
      '/series/v1/$seriesId/squads',
      ttl: CacheTtls.seriesDetail,
      forceRefresh: forceRefresh,
    );
  }

  static Future getPointsTable(String seriesId, {bool forceRefresh = false}) async {
    return ApiService.getCached(
      '/stats/v1/series/$seriesId/points-table',
      ttl: CacheTtls.seriesDetail,
      forceRefresh: forceRefresh,
    );
  }
}
