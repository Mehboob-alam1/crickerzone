import 'package:flutter/material.dart';
import '../models/news_model.dart';
import '../services/news_api.dart';

class NewsProvider with ChangeNotifier {
  List<NewsModel> _newsList = [];
  bool _isLoading = false;

  List<NewsModel> get newsList => _newsList;
  bool get isLoading => _isLoading;

  Future<void> fetchNews() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      final response = await NewsApi.getNews();
      if (response != null && response['storyList'] != null) {
        List<NewsModel> news = [];
        for (var item in response['storyList']) {
          if (item['story'] != null) {
            news.add(NewsModel.fromJson(item['story']));
          }
        }
        _newsList = news;
      }
    } catch (e) {
      debugPrint('News access restricted or error: $e');
      _newsList = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
