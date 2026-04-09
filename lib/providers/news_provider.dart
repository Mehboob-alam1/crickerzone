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

  Future<void> fetchNews({bool forceRefresh = false}) async {
    if (_isLoading) return;
    _isLoading = true;
    _activeCategoryId = null;
    notifyListeners();

    try {
      final response = await NewsApi.getNews(forceRefresh: forceRefresh);
      _applyStoryList(response);
    } catch (e) {
      debugPrint('News: $e');
      _newsList = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCategories({bool forceRefresh = false}) async {
    try {
      final res = await NewsApi.getCategories(forceRefresh: forceRefresh);
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

  Future<void> fetchNewsByCategory(int categoryId, {bool forceRefresh = false}) async {
    if (_isLoading) return;
    _isLoading = true;
    _activeCategoryId = categoryId;
    notifyListeners();

    try {
      final response = await NewsApi.getNewsByCategory(
        categoryId.toString(),
        forceRefresh: forceRefresh,
      );
      _applyStoryList(response);
    } catch (e) {
      debugPrint('News by category: $e');
      _newsList = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchNewsByTopic(int topicId, {bool forceRefresh = false}) async {
    if (_isLoading) return;
    _isLoading = true;
    _activeCategoryId = null;
    notifyListeners();

    try {
      final response = await NewsApi.getNewsByTopic(
        topicId.toString(),
        forceRefresh: forceRefresh,
      );
      _applyStoryList(response);
    } catch (e) {
      debugPrint('News by topic: $e');
      _newsList = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchNewsDetail(String id, {bool forceRefresh = false}) async {
    _newsDetail = null;
    _detailLoading = true;
    notifyListeners();

    try {
      final res = await NewsApi.getNewsDetail(id, forceRefresh: forceRefresh);
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
