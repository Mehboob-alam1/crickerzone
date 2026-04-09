import 'package:flutter/material.dart';
import '../models/series_model.dart';
import '../services/series_api.dart';

class SeriesProvider with ChangeNotifier {
  List<SeriesModel> _seriesList = [];
  bool _isLoading = false;

  List<SeriesModel> get seriesList => _seriesList;
  bool get isLoading => _isLoading;

  Future<void> fetchInternationalSeries({bool forceRefresh = false}) async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      final response = await SeriesApi.getInternationalSeries(forceRefresh: forceRefresh);
      if (response == null) return;

      final List<dynamic> groups =
          (response['seriesMapProto'] ?? response['seriesList']) as List? ?? [];

      final List<SeriesModel> list = [];
      for (final item in groups) {
        if (item is! Map<String, dynamic>) continue;
        final series = item['series'];
        if (series is! List) continue;
        for (final s in series) {
          if (s is Map<String, dynamic>) {
            list.add(SeriesModel.fromJson(s));
          }
        }
      }
      _seriesList = list;
    } catch (e) {
      debugPrint('Error fetching series: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<dynamic>> fetchSeriesMatches(String seriesId) async {
    try {
      final response = await SeriesApi.getSeriesMatches(seriesId);
      return response['matchDetails'] ?? [];
    } catch (e) {
      debugPrint('Error fetching series matches: $e');
      return [];
    }
  }

  Future<List<dynamic>> fetchSeriesSquads(String seriesId) async {
    try {
      final response = await SeriesApi.getSeriesSquads(seriesId);
      return response['squads'] ?? [];
    } catch (e) {
      debugPrint('Error fetching series squads: $e');
      return [];
    }
  }
}
