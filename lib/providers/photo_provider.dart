import 'package:flutter/material.dart';

import '../services/photo_api.dart';

class PhotoProvider extends ChangeNotifier {

  List photos = [];
  bool isLoading = false;

  Future fetchPhotos() async {
    isLoading = true;
    notifyListeners();

    photos = await PhotoApi.getPhotos();

    isLoading = false;
    notifyListeners();
  }
}