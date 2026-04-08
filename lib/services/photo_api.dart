import 'dart:developer';
import 'api_service.dart';

class PhotoApi {

  /// 🔥 Get Photos List
  static Future<List<dynamic>> getPhotos() async {
    try {
      final response = await ApiService.dio.get("/photos/v1/index");
      return response.data['photoGalleryInfoList'] ?? [];
    } catch (e) {
      log("Error Photos List: $e");
      return [];
    }
  }

  /// 🔥 Get Photo Detail
  static Future<Map<String, dynamic>?> getPhotoDetail(String photoId) async {
    try {
      final response =
      await ApiService.dio.get("/photos/v1/detail/$photoId");
      return response.data;
    } catch (e) {
      log("Error Photo Detail: $e");
      return null;
    }
  }

  /// 🔥 Get Image URL (IMPORTANT)
  static String getImageUrl(String imageId) {
    return "https://cricbuzz-cricket.p.rapidapi.com/img/v1/i1/$imageId/i.jpg";
  }
}