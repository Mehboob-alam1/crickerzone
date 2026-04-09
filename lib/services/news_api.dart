import 'package:flutter/foundation.dart';

import '../services/api_service.dart';

/// Allineato a `news/list`, `news/detail`, `news/list-by-category`, `news/list-by-topic`, ecc.
class NewsApi {
  static Future<dynamic> getNews() async {
    try {
      final res = await ApiService.dio.get('/news/v1/index');
      return res.data;
    } catch (e) {
      debugPrint('getNews: $e');
      return null;
    }
  }

  static Future<dynamic> getNewsDetail(String id) async {
    try {
      final res = await ApiService.dio.get('/news/v1/detail/$id');
      return res.data;
    } catch (e) {
      debugPrint('getNewsDetail: $e');
      return null;
    }
  }

  static Future<dynamic> getCategories() async {
    try {
      final res = await ApiService.dio.get('/news/v1/cat');
      return res.data;
    } catch (e) {
      debugPrint('getCategories: $e');
      return null;
    }
  }

  static Future<dynamic> getNewsByCategory(String id) async {
    try {
      final res = await ApiService.dio.get('/news/v1/cat/$id');
      return res.data;
    } catch (e) {
      debugPrint('getNewsByCategory: $e');
      return null;
    }
  }

  static Future<dynamic> getTopics() async {
    try {
      final res = await ApiService.dio.get('/news/v1/topics');
      return res.data;
    } catch (e) {
      debugPrint('getTopics: $e');
      return null;
    }
  }

  static Future<dynamic> getNewsByTopic(String id) async {
    try {
      final res = await ApiService.dio.get('/news/v1/topics/$id');
      return res.data;
    } catch (e) {
      debugPrint('getNewsByTopic: $e');
      return null;
    }
  }
}