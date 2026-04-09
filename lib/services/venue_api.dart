import '../services/api_service.dart';

class VenueApi {
  static Future<dynamic> getVenueInfo(String venueId, {bool forceRefresh = false}) async {
    return ApiService.getCached(
      '/venues/v1/$venueId',
      ttl: CacheTtls.venue,
      forceRefresh: forceRefresh,
    );
  }

  static Future<dynamic> getVenueStats(String venueId, {bool forceRefresh = false}) async {
    return ApiService.getCached(
      '/venues/v1/$venueId/stats',
      ttl: CacheTtls.venue,
      forceRefresh: forceRefresh,
    );
  }
}
