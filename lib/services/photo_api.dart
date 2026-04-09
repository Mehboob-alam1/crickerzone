import 'dart:developer';
import 'api_service.dart';

class PhotoApi {
  static Future<List<dynamic>> getPhotos() async {
    try {
      final response = await ApiService.dio.get('/photos/v1/index');
      return response.data['photoGalleryInfoList'] ?? [];
    } catch (e) {
      log('Error Photos List: $e');
      return [];
    }
  }

  /// Dettaglio galleria (`photos/get-gallery` → `photoGalleryDetails`).
  static Future<Map<String, dynamic>?> getGallery(String galleryId) async {
    for (final path in ['/photos/v1/gallery/$galleryId', '/photos/v1/detail/$galleryId']) {
      try {
        final response = await ApiService.dio.get(path);
        if (response.data is Map) {
          return Map<String, dynamic>.from(response.data as Map);
        }
      } catch (e) {
        log('Gallery $path: $e');
      }
    }
    return null;
  }

  static String getImageUrl(String imageId) {
    return 'https://static.cricbuzz.com/a/img/v1/i1/c$imageId/i.jpg';
  }
}
