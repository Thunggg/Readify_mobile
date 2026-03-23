import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';

import 'api_config.dart';

class ApiClient {
  ApiClient._(this.dio);

  final Dio dio;

  static final CookieJar _cookieJar = CookieJar();

  static ApiClient? _instance;
  static ApiClient get instance => _instance ??= ApiClient._(_buildDio());

  static Dio _buildDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 20),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(CookieManager(_cookieJar));

    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true),
      );
    }

    return dio;
  }

  /// Save a cookie for the API base URL (so subsequent requests include it).
  static Future<void> saveCookie(String name, String value) async {
    final uri = Uri.parse(ApiConfig.baseUrl);
    final cookie = Cookie(name, value);
    _cookieJar.saveFromResponse(uri, [cookie]);
  }

  /// Clear all cookies (useful for logout)
  static Future<void> clearCookies() async {
    _cookieJar.deleteAll();
  }
}
