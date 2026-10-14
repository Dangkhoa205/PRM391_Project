import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/api_constants.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  final dynamic details;

  ApiException({
    required this.statusCode,
    required this.message,
    this.details,
  });

  @override
  String toString() => message;
}

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final http.Client _client = http.Client();

  static const String _keyAccessToken = 'app_access_token';
  static const String _keyRefreshToken = 'app_refresh_token';

  String? _accessToken;
  String? _refreshToken;

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  bool get hasToken => _accessToken != null && _accessToken!.isNotEmpty;

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _accessToken = prefs.getString(_keyAccessToken);
      _refreshToken = prefs.getString(_keyRefreshToken);
    } catch (e) {
      debugPrint('[ApiService] Failed to initialize tokens: $e');
    }
  }

  Future<void> setTokens({required String accessToken, required String refreshToken}) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyAccessToken, accessToken);
      await prefs.setString(_keyRefreshToken, refreshToken);
    } catch (e) {
      debugPrint('[ApiService] Failed to save tokens: $e');
    }
  }

  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyAccessToken);
      await prefs.remove(_keyRefreshToken);
    } catch (e) {
      debugPrint('[ApiService] Failed to clear tokens: $e');
    }
  }

  Map<String, String> _buildHeaders({bool requiresAuth = true}) {
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      'X-Client-Type': 'mobile', // Instructs Spring Boot BE to return tokens in body
    };

    if (requiresAuth && _accessToken != null && _accessToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }

    return headers;
  }

  Uri _buildUri(String path, [Map<String, dynamic>? queryParameters]) {
    final cleanPath = path.startsWith('/') ? path : '/$path';
    final fullUrl = '${ApiConstants.baseUrl}$cleanPath';
    final uri = Uri.parse(fullUrl);

    if (queryParameters != null && queryParameters.isNotEmpty) {
      final cleanParams = <String, String>{};
      queryParameters.forEach((key, value) {
        if (value != null) {
          cleanParams[key] = value.toString();
        }
      });
      return uri.replace(queryParameters: cleanParams);
    }
    return uri;
  }

  dynamic _processResponse(http.Response response) {
    dynamic jsonBody;
    try {
      if (response.body.isNotEmpty) {
        jsonBody = jsonDecode(utf8.decode(response.bodyBytes));
      }
    } catch (e) {
      debugPrint('[ApiService] JSON decode error: $e');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (jsonBody is Map<String, dynamic> && jsonBody.containsKey('result')) {
        return jsonBody['result'];
      }
      return jsonBody;
    }

    String errorMessage = 'Yêu cầu không thành công (${response.statusCode})';
    if (jsonBody is Map<String, dynamic>) {
      if (jsonBody['message'] != null) {
        errorMessage = jsonBody['message'].toString();
      } else if (jsonBody['error'] != null) {
        errorMessage = jsonBody['error'].toString();
      }
    }

    throw ApiException(
      statusCode: response.statusCode,
      message: errorMessage,
      details: jsonBody,
    );
  }

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParams,
    bool requiresAuth = true,
  }) async {
    final uri = _buildUri(path, queryParams);
    final headers = _buildHeaders(requiresAuth: requiresAuth);

    try {
      var response = await _client.get(uri, headers: headers);

      // Handle token expiration: attempt 1 refresh
      if (response.statusCode == 401 && requiresAuth && _refreshToken != null) {
        final refreshed = await _attemptRefreshToken();
        if (refreshed) {
          final retryHeaders = _buildHeaders(requiresAuth: true);
          response = await _client.get(uri, headers: retryHeaders);
        }
      }

      return _processResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        statusCode: 0,
        message: 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra mạng hoặc khởi động BE.',
      );
    }
  }

  Future<dynamic> post(
    String path, {
    dynamic body,
    bool requiresAuth = true,
  }) async {
    final uri = _buildUri(path);
    final headers = _buildHeaders(requiresAuth: requiresAuth);

    try {
      var response = await _client.post(
        uri,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );

      if (response.statusCode == 401 && requiresAuth && _refreshToken != null) {
        final refreshed = await _attemptRefreshToken();
        if (refreshed) {
          final retryHeaders = _buildHeaders(requiresAuth: true);
          response = await _client.post(
            uri,
            headers: retryHeaders,
            body: body != null ? jsonEncode(body) : null,
          );
        }
      }

      return _processResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        statusCode: 0,
        message: 'Không thể kết nối đến máy chủ. Vui lòng thử lại.',
      );
    }
  }

  Future<dynamic> patch(
    String path, {
    dynamic body,
    bool requiresAuth = true,
  }) async {
    final uri = _buildUri(path);
    final headers = _buildHeaders(requiresAuth: requiresAuth);

    try {
      var response = await _client.patch(
        uri,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );

      if (response.statusCode == 401 && requiresAuth && _refreshToken != null) {
        final refreshed = await _attemptRefreshToken();
        if (refreshed) {
          final retryHeaders = _buildHeaders(requiresAuth: true);
          response = await _client.patch(
            uri,
            headers: retryHeaders,
            body: body != null ? jsonEncode(body) : null,
          );
        }
      }

      return _processResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        statusCode: 0,
        message: 'Không thể kết nối đến máy chủ. Vui lòng thử lại.',
      );
    }
  }

  Future<dynamic> delete(
    String path, {
    bool requiresAuth = true,
  }) async {
    final uri = _buildUri(path);
    final headers = _buildHeaders(requiresAuth: requiresAuth);

    try {
      final response = await _client.delete(uri, headers: headers);
      return _processResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        statusCode: 0,
        message: 'Không thể kết nối đến máy chủ. Vui lòng thử lại.',
      );
    }
  }

  Future<bool> _attemptRefreshToken() async {
    if (_refreshToken == null) return false;
    try {
      final uri = _buildUri(ApiConstants.refresh);
      final response = await _client.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'X-Client-Type': 'mobile',
        },
        body: jsonEncode({'refreshToken': _refreshToken}),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        final result = body['result'];
        if (result != null && result['accessToken'] != null) {
          await setTokens(
            accessToken: result['accessToken'] as String,
            refreshToken: (result['refreshToken'] as String?) ?? _refreshToken!,
          );
          return true;
        }
      }
    } catch (e) {
      debugPrint('[ApiService] Refresh token failed: $e');
    }

    await clearTokens();
    return false;
  }
}
