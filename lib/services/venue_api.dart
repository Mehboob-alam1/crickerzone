import '../services/api_service.dart';

/// Dettaglio e statistiche impianto (`venues/get-info`, `venues/get-stats`).
/// L'id di solito è `venueInfo.id` nel match center.
class VenueApi {
  static Future<dynamic> getVenueInfo(String venueId) async {
    final res = await ApiService.dio.get('/venues/v1/$venueId');
    return res.data;
  }

  static Future<dynamic> getVenueStats(String venueId) async {
    final res = await ApiService.dio.get('/venues/v1/$venueId/stats');
    return res.data;
  }
}
