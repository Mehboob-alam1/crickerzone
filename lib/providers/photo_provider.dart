import 'package:flutter/material.dart';
import '../models/photo_model.dart';
import '../services/photo_api.dart';

class PhotoProvider extends ChangeNotifier {

  List<PhotoModel> _photos = [];
  bool _isLoading = false;

  List<PhotoModel> get photos => _photos;
  bool get isLoading => _isLoading;

  Future<void> fetchPhotos() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      final List<dynamic> data = await PhotoApi.getPhotos();
      _photos = data
          .where((item) => item['photoGalleryInfo'] != null)
          .map((item) => PhotoModel.fromJson(item['photoGalleryInfo']))
          .toList();
    } catch (e) {
      debugPrint("Error fetching photos: $e");
      _photos = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
