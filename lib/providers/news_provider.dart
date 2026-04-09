import 'package:flutter/material.dart';
import '../models/news_model.dart';
import '../services/news_api.dart';

class NewsProvider with ChangeNotifier {
  List<NewsModel> _newsList = [];
  List<Map<String, dynamic>> _categories = [];
  Map<String, dynamic>? _newsDetail;
  bool _isLoading = false;
  bool _detailLoading = false;
  int? _activeCategoryId;

  List<NewsModel> get newsList => _newsList;
  List<Map<String, dynamic>> get categories => _categories;
  Map<String, dynamic>? get newsDetail => _newsDetail;
  bool get isLoading => _isLoading;
  bool get detailLoading => _detailLoading;
  int? get activeCategoryId => _activeCategoryId;

  void _applyStoryList(dynamic response) {
    _newsList = [];
    if (response is! Map || response['storyList'] is! List) return;
    for (final item in response['storyList'] as List) {
      if (item is! Map || item['story'] is! Map) continue;
      _newsList.add(
        NewsModel.fromJson(
          Map<String, dynamic>.from(item['story'] as Map),
        ),
      );
    }
  }

  Future<void> fetchNews() async {
    if (_isLoading) return;
    _isLoading = true;
    _activeCategoryId = null;
    notifyListeners();

    try {
      final response = await NewsApi.getNews();
      _applyStoryList(response);
    } catch (e) {
      debugPrint('News: $e');
      _newsList = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCategories() async {
    try {
      final res = await NewsApi.getCategories();
      if (res is Map && res['storyType'] is List) {
        _categories = (res['storyType'] as List)
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Categories: $e');
    }
  }

  Future<void> fetchNewsByCategory(int categoryId) async {
    if (_isLoading) return;
    _isLoading = true;
    _activeCategoryId = categoryId;
    notifyListeners();

    try {
      final response = await NewsApi.getNewsByCategory(categoryId.toString());
      _applyStoryList(response);
    } catch (e) {
      debugPrint('News by category: $e');
      _newsList = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchNewsByTopic(int topicId) async {
    if (_isLoading) return;
    _isLoading = true;
    _activeCategoryId = null;
    notifyListeners();

    try {
      final response = await NewsApi.getNewsByTopic(topicId.toString());
      _applyStoryList(response);
    } catch (e) {
      debugPrint('News by topic: $e');
      _newsList = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchNewsDetail(String id) async {
    _newsDetail = null;
    _detailLoading = true;
    notifyListeners();

    try {
      final res = await NewsApi.getNewsDetail(id);
      if (res is Map) {
        _newsDetail = Map<String, dynamic>.from(res);
      }
    } catch (e) {
      debugPrint('News detail: $e');
    } finally {
      _detailLoading = false;
      notifyListeners();
    }
  }

  void clearNewsDetail() {
    _newsDetail = null;
    notifyListeners();
  }
}
