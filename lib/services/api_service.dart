import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../core/constants/api_constants.dart';

class ApiService {
  static const String baseUrl = ApiConstants.baseUrl;
  
  static String _apiKey = ApiConstants.apiKey;

  static void setApiKey(String key) {
    _apiKey = key;
    _updateDio();
  }

  static Dio dio = _createDio();

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        headers: {
          "X-Rapidapi-Key": _apiKey,
          "X-Rapidapi-Host": "cricbuzz-cricket.p.rapidapi.com",
          "Content-Type": "application/json",
        },
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add a small delay before every request to respect the 1 req/sec limit
        await Future.delayed(const Duration(milliseconds: 1100));
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 429) {
          // If we still get a 429, wait longer and retry once
          debugPrint("Rate limit hit (429). Retrying in 2 seconds...");
          await Future.delayed(const Duration(seconds: 2));
          final response = await dio.fetch(e.requestOptions);
          return handler.resolve(response);
        }
        return handler.next(e);
      },
    ));

    dio.interceptors.add(LogInterceptor(
      requestHeader: false,
      responseHeader: false,
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => debugPrint(obj.toString()),
    ));

    return dio;
  }

  static void _updateDio() {
    dio = _createDio();
  }
}
