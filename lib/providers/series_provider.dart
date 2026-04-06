import 'package:flutter/material.dart';
import '../models/series_model.dart';
import '../services/series_api.dart';

class SeriesProvider with ChangeNotifier {
  List<SeriesModel> _seriesList = [];
  bool _isLoading = false;

  List<SeriesModel> get seriesList => _seriesList;
  bool get isLoading => _isLoading;

  Future<void> fetchInternationalSeries() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      final response = await SeriesApi.getInternationalSeries();
      if (response != null && response['seriesList'] != null) {
        List<SeriesModel> list = [];
        for (var item in response['seriesList']) {
          if (item['series'] != null) {
            for (var s in item['series']) {
              list.add(SeriesModel.fromJson(s));
            }
          }
        }
        _seriesList = list;
      }
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
