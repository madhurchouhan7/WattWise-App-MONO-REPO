// lib/core/network/api_constants.dart
// Central place for all API base URLs and route paths.

class ApiConstants {
  ApiConstants._();

  // ── Base URLs ─────────────────────────────────────────────────────────────
  // Use 10.0.2.2 on Android emulator (maps to host machine's localhost).
  // Use localhost for web / iOS simulator.
  // For a physical device, replace with your machine's local IP (e.g. 192.168.x.x).
  static const String _localHost = 'http://10.0.2.2:5000'; // Android emulator
  // static const String _localHost = 'http://localhost:5000'; // Web / iOS sim
  // static const String _localHost = 'http://192.168.1.x:5000'; // Physical device

  static const String baseUrl = '$_localHost/api/v1';
  static const String healthUrl = '$_localHost/health';

  // ── Timeouts ──────────────────────────────────────────────────────────────
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 20);
  static const Duration sendTimeout = Duration(seconds: 15);

  // ── Auth Routes ───────────────────────────────────────────────────────────
  static const String authMe = '/auth/me';
  static const String authLogout = '/auth/logout';

  // ── User Routes ───────────────────────────────────────────────────────────
  static const String userProfile = '/users/profile';

  // ── (Add more as you build features) ─────────────────────────────────────
}
