import 'package:flutter/foundation.dart';

import '../services/api_service.dart';

class NewsApi {
  static Future<dynamic> getNews({bool forceRefresh = false}) async {
    try {
      return await ApiService.getCached(
        '/news/v1/index',
        ttl: CacheTtls.newsList,
        forceRefresh: forceRefresh,
      );
    } catch (e) {
      debugPrint('getNews: $e');
      return null;
    }
  }

  static Future<dynamic> getNewsDetail(String id, {bool forceRefresh = false}) async {
    try {
      return await ApiService.getCached(
        '/news/v1/detail/$id',
        ttl: CacheTtls.newsDetail,
        forceRefresh: forceRefresh,
      );
    } catch (e) {
      debugPrint('getNewsDetail: $e');
      return null;
    }
  }

  static Future<dynamic> getCategories({bool forceRefresh = false}) async {
    try {
      return await ApiService.getCached(
        '/news/v1/cat',
        ttl: CacheTtls.newsMeta,
        forceRefresh: forceRefresh,
      );
    } catch (e) {
      debugPrint('getCategories: $e');
      return null;
    }
  }

  static Future<dynamic> getNewsByCategory(String id, {bool forceRefresh = false}) async {
    try {
      return await ApiService.getCached(
        '/news/v1/cat/$id',
        ttl: CacheTtls.newsList,
        forceRefresh: forceRefresh,
      );
    } catch (e) {
      debugPrint('getNewsByCategory: $e');
      return null;
    }
  }

  static Future<dynamic> getTopics({bool forceRefresh = false}) async {
    try {
      return await ApiService.getCached(
        '/news/v1/topics',
        ttl: CacheTtls.newsMeta,
        forceRefresh: forceRefresh,
      );
    } catch (e) {
      debugPrint('getTopics: $e');
      return null;
    }
  }

  static Future<dynamic> getNewsByTopic(String id, {bool forceRefresh = false}) async {
    try {
      return await ApiService.getCached(
        '/news/v1/topics/$id',
        ttl: CacheTtls.newsList,
        forceRefresh: forceRefresh,
      );
    } catch (e) {
      debugPrint('getNewsByTopic: $e');
      return null;
    }
  }
}
