import 'dart:developer';

import 'api_service.dart';

class PhotoApi {
  static Future<List<dynamic>> getPhotos({bool forceRefresh = false}) async {
    try {
      final data = await ApiService.getCached(
        '/photos/v1/index',
        ttl: CacheTtls.photos,
        forceRefresh: forceRefresh,
      );
      if (data is Map && data['photoGalleryInfoList'] is List) {
        return List<dynamic>.from(data['photoGalleryInfoList'] as List);
      }
      return [];
    } catch (e) {
      log('Error Photos List: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> getGallery(String galleryId, {bool forceRefresh = false}) async {
    for (final path in ['/photos/v1/gallery/$galleryId', '/photos/v1/detail/$galleryId']) {
      try {
        final data = await ApiService.getCached(
          path,
          ttl: CacheTtls.photoGallery,
          forceRefresh: forceRefresh,
        );
        if (data is Map) {
          return Map<String, dynamic>.from(data);
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
