import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local JSON cache for API responses (reduces RapidAPI calls and queue waits).
class ApiCacheService {
  ApiCacheService._();
  static final ApiCacheService instance = ApiCacheService._();

  static const _prefix = 'sz_api_v1_';

  String cacheKey(String path, Map<String, dynamic>? queryParameters) {
    if (queryParameters == null || queryParameters.isEmpty) return path;
    final keys = queryParameters.keys.toList()..sort();
    final q = keys.map((k) => '$k=${queryParameters[k]}').join('&');
    return '$path?$q';
  }

  Future<dynamic> read(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_prefix$key');
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final exp = decoded['e'] as int;
      if (DateTime.now().millisecondsSinceEpoch > exp) {
        await prefs.remove('$_prefix$key');
        return null;
      }
      return decoded['d'];
    } catch (_) {
      await prefs.remove('$_prefix$key');
      return null;
    }
  }

  Future<void> write(String key, dynamic data, Duration ttl) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final exp = DateTime.now().add(ttl).millisecondsSinceEpoch;
      await prefs.setString(
        '$_prefix$key',
        jsonEncode({'e': exp, 'd': data}),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Cache write skip ($key): $e');
      }
    }
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith(_prefix));
    for (final k in keys) {
      await prefs.remove(k);
    }
  }
}

/// TTL presets per type of data.
abstract final class CacheTtls {
  static const liveData = Duration(seconds: 45);
  static const matchCenter = Duration(seconds: 45);
  static const schedule = Duration(minutes: 30);
  static const teamsList = Duration(hours: 6);
  static const teamDetail = Duration(minutes: 20);
  static const seriesList = Duration(minutes: 45);
  static const seriesDetail = Duration(minutes: 20);
  static const playerTrending = Duration(minutes: 15);
  static const playerProfile = Duration(minutes: 25);
  static const playerSearch = Duration(minutes: 3);
  static const newsList = Duration(minutes: 12);
  static const newsDetail = Duration(hours: 1);
  static const newsMeta = Duration(hours: 24);
  static const rankings = Duration(minutes: 45);
  static const standings = Duration(hours: 1);
  static const statsMeta = Duration(hours: 12);
  static const photos = Duration(minutes: 20);
  static const photoGallery = Duration(hours: 1);
  static const venue = Duration(hours: 12);
}
