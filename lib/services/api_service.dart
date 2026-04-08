import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../core/constants/api_constants.dart';

class ApiService {
  static const String baseUrl = ApiConstants.baseUrl;
  static String _apiKey = ApiConstants.apiKey;

  // Global queue to ensure ONLY one request is processed at a time across the entire app
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

          // 1. Take a spot in the queue
          final previousTurn = _requestQueue;
          final myTurn = Completer<void>();
          _requestQueue = myTurn.future;

          // Attach myTurn completer to options so we can finish the turn in response/error
          options.extra["_myTurn"] = myTurn;

          // 2. Wait for the previous request to FULLY FINISH (response or error)
          await previousTurn;

          // 3. Wait for global backoff if active (e.g., from a 429)
          if (_backoffFuture != null) {
            debugPrint("⏳ Waiting for backoff to clear...");
            await _backoffFuture;
          }

          // 4. Mandatory spacing delay: Cricbuzz Basic plan is very strict (1 req/sec).
          // 4 seconds is safe to avoid overlapping due to network latency.
          await Future.delayed(const Duration(milliseconds: 4000));

          debugPrint("🚀 Sending: ${options.path}");
          return handler.next(options);
        },

        onResponse: (response, handler) {
          debugPrint("✅ ${response.requestOptions.path}");
          
          // Complete the queue turn so the next request can start its delay
          _completeTurn(response.requestOptions);
          
          return handler.next(response);
        },

        onError: (DioException e, handler) async {
          final options = e.requestOptions;

          // 429 means rate limit exceeded
          if (e.response?.statusCode == 429) {
            debugPrint("⚠️ 429 hit: ${options.path}");

            // Start global backoff if not already active
            if (_backoffFuture == null) {
              final c = Completer<void>();
              _backoffFuture = c.future;

              debugPrint("🛑 Starting 15s global backoff...");
              Future.delayed(const Duration(seconds: 15), () {
                _backoffFuture = null;
                c.complete();
                debugPrint("🟢 Backoff cleared");
              });
            }

            // Retry logic
            int retryCount = (options.extra["retry"] ?? 0);
            if (retryCount < 2) {
              options.extra["retry"] = retryCount + 1;
              debugPrint("🔄 Retrying (${retryCount + 1}/2): ${options.path}");
              
              // CRITICAL: Complete the current turn BEFORE re-fetching.
              // This allows the next request in line to start its wait, 
              // while this retry goes to the back of the queue.
              _completeTurn(options);

              // Wait for backoff to clear before retrying
              await _backoffFuture;

              try {
                // Re-fetch will go through the queue again
                final response = await dio.fetch(options);
                return handler.resolve(response);
              } catch (retryError) {
                return handler.next(e);
              }
            }
          }

          if (e.response?.statusCode == 403) {
            debugPrint("🚫 403 Forbidden: ${options.path}. Check if your RapidAPI key is valid and subscribed to the Cricbuzz API plan.");
          }

          // Final failure or non-rate-limit error: complete the turn
          _completeTurn(options);
          debugPrint("❌ Failed: ${options.path} [${e.response?.statusCode}]");
          return handler.next(e);
        },
      ),
    );

    return dio;
  }

  static void _completeTurn(RequestOptions options) {
    final myTurn = options.extra["_myTurn"] as Completer<void>?;
    if (myTurn != null && !myTurn.isCompleted) {
      myTurn.complete();
    }
  }
}
