// lib/core/network/api_constants.dart
// Central place for all API base URLs and route paths.

class ApiConstants {
  ApiConstants._();

  // ── Base URLs ─────────────────────────────────────────────────────────────
  // Bound dynamically to your host machine's physical network IPv4 space
  // This allows BOTH Emulators and Real Devices on your Wi-Fi to hit the backend!
  // static const String _localHost = 'http://10.78.211.93:5000';

  // static const String _localHost =
  //     'http://10.0.2.2:5000'; // Android emulator ONLY

  static const String _localHost =
      'https://wattwise-app-mono-repo.onrender.com';

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

  // ── BBPS Routes ───────────────────────────────────────────────────────────
  static const String bbpsFetchBill = '/bbps/fetch-bill';

  // ── (Add more as you build features) ─────────────────────────────────────
}
