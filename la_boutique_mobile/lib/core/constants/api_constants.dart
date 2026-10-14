import 'package:flutter/foundation.dart';

class ApiConstants {
  // Configurable base URL:
  // - Android emulator: 10.0.2.2
  // - iOS simulator / Web / Desktop: localhost
  // - Physical device: set to your LAN IP (e.g. http://192.168.1.x:8088/api/v1)
  static String get defaultBaseUrl {
    if (kIsWeb) {
      return 'http://localhost:8088/api/v1';
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:8088/api/v1';
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      default:
        return 'http://localhost:8088/api/v1';
    }
  }

  static String baseUrl = defaultBaseUrl;

  // Auth endpoints
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String logoutAll = '/auth/logout-all';

  // Account endpoints
  static const String accounts = '/accounts';
  static const String accountMe = '/accounts/me';
  static const String changePassword = '/accounts/me/password';

  // Profile endpoints
  static const String profileMe = '/profiles/me';

  // Category endpoints
  static const String categories = '/categories';

  // Product endpoints
  static const String products = '/products';
  static String productById(String id) => '/products/$id';
  static String productBySlug(String slug) => '/products/slug/$slug';

  // Order endpoints
  static const String orders = '/orders';
  static const String myOrders = '/orders/me';
  static String myOrderByNumber(String orderNumber) => '/orders/me/$orderNumber';
}
