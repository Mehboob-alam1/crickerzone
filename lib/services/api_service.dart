import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../core/constants/api_constants.dart';

class ApiService {
  static const String baseUrl = ApiConstants.baseUrl;
  static String _apiKey = ApiConstants.apiKey;

  static Future<void> _requestQueue = Future.value();
  static Future<void>? _backoffFuture;

  static Dio dio = _createDio();

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        headers: {
          "X-Rapidapi-Key": _apiKey,
          "X-Rapidapi-Host": ApiConstants.apiHost,
          "Content-Type": "application/json",
        },
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          debugPrint("⏳ Queue: ${options.path}");

          final previous = _requestQueue;
          final completer = Completer<void>();
          _requestQueue = completer.future;

          // wait previous request
          await previous;

          // wait global backoff
          if (_backoffFuture != null) {
            debugPrint("⏳ Waiting backoff...");
            await _backoffFuture;
          }

          // delay BEFORE request (important)
          await Future.delayed(const Duration(seconds: 2));

          debugPrint("🚀 Sending: ${options.path}");

          handler.next(options);

          // complete AFTER request spacing
          completer.complete();
        },

        onResponse: (response, handler) {
          debugPrint("✅ ${response.requestOptions.path}");
          return handler.next(response);
        },

        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 429) {
            debugPrint("⚠️ 429 hit: ${e.requestOptions.path}");

            // global backoff
            if (_backoffFuture == null) {
              final c = Completer<void>();
              _backoffFuture = c.future;

              debugPrint("🛑 Backoff 10s...");
              Future.delayed(const Duration(seconds: 10), () {
                _backoffFuture = null;
                c.complete();
                debugPrint("🟢 Backoff cleared");
              });
            }

            // ❌ IMPORTANT: LIMIT RETRIES
            int retryCount = (e.requestOptions.extra["retry"] ?? 0);

            if (retryCount >= 2) {
              debugPrint("❌ Max retry reached: ${e.requestOptions.path}");
              return handler.next(e);
            }

            e.requestOptions.extra["retry"] = retryCount + 1;

            // wait before retry
            await Future.delayed(const Duration(seconds: 5));

            try {
              final response = await dio.fetch(e.requestOptions);
              return handler.resolve(response);
            } catch (_) {
              return handler.next(e);
            }
          }

          return handler.next(e);
        },
      ),
    );

    return dio;
  }
}