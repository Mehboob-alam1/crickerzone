import 'package:flutter/cupertino.dart';

import '../services/api_service.dart';

class NewsApi {

  /// Get all news
  static Future<dynamic> getNews() async {
    try {
      final res = await ApiService.dio.get("/news/v1/index");
      debugPrint("NEWS: ${res.data}");
      return res.data;
    } catch (e) {
      debugPrint("ERROR getNews: $e");
      return null;
    }
  }

  /// Get news detail by dynamic ID
  static Future<dynamic> getNewsDetail(String id) async {
    try {
      final res = await ApiService.dio.get("/news/v1/detail/$id");
      debugPrint("DETAIL: ${res.data}");
      return res.data;
    } catch (e) {
      debugPrint("ERROR getNewsDetail: $e");
      return null;
    }
  }

  /// Get all categories
  static Future<dynamic> getCategories() async {
    try {
      final res = await ApiService.dio.get("/news/v1/cat");
      debugPrint("CATEGORIES: ${res.data}");
      return res.data;
    } catch (e) {
      debugPrint("ERROR getCategories: $e");
      return null;
    }
  }

  /// Get news by category ID
  static Future<dynamic> getNewsByCategory(String id) async {
    try {
      final res = await ApiService.dio.get("/news/v1/cat/$id");
      debugPrint("CATEGORY NEWS: ${res.data}");
      return res.data;
    } catch (e) {
      debugPrint("ERROR getNewsByCategory: $e");
      return null;
    }
  }

  /// Get all topics
  static Future<dynamic> getTopics() async {
    try {
      final res = await ApiService.dio.get("/news/v1/topics");
      debugPrint("TOPICS: ${res.data}");
      return res.data;
    } catch (e) {
      debugPrint("ERROR getTopics: $e");
      return null;
    }
  }

  /// Get news by topic ID
  static Future<dynamic> getNewsByTopic(String id) async {
    try {
      final res = await ApiService.dio.get("/news/v1/topics/$id");
      debugPrint("TOPIC NEWS: ${res.data}");
      return res.data;
    } catch (e) {
      debugPrint("ERROR getNewsByTopic: $e");
      return null;
    }
  }
}