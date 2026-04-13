import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import '../models/session.dart';
import '../../utils/app_logger.dart';

/// Service for Strava API integration
class StravaIntegrationService {
  static const String _tag = 'StravaIntegrationService';

  // Strava OAuth endpoints
  static const String _authUrl = 'https://www.strava.com/oauth/token';
  static const String _apiBaseUrl = 'https://www.strava.com/api/v3';

  late final String _clientId;
  late final String _clientSecret;
  late final SharedPreferences _prefs;

  String? _accessToken;
  String? _refreshToken;
  DateTime? _expiresAt;

  StravaIntegrationService({
    required String clientId,
    required String clientSecret,
  })  : _clientId = clientId,
        _clientSecret = clientSecret;

  /// Initialize the service and load stored tokens
  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _loadTokens();
      AppLogger.info('StravaIntegrationService initialized', tag: _tag);
    } catch (e) {
      AppLogger.error(
        'Error initializing StravaIntegrationService',
        tag: _tag,
        exception: e,
      );
      rethrow;
    }
  }

  /// Load tokens from SharedPreferences
  void _loadTokens() {
    _accessToken = _prefs.getString('strava_access_token');
    _refreshToken = _prefs.getString('strava_refresh_token');

    final expiresAtMs = _prefs.getInt('strava_expires_at');
    if (expiresAtMs != null) {
      _expiresAt = DateTime.fromMillisecondsSinceEpoch(expiresAtMs);
    }

    AppLogger.debug(
      'Tokens loaded: accessToken=${_accessToken != null}, '
      'refreshToken=${_refreshToken != null}',
      tag: _tag,
    );
  }

  /// Save tokens to SharedPreferences
  Future<void> _saveTokens() async {
    await _prefs.setString('strava_access_token', _accessToken ?? '');
    await _prefs.setString('strava_refresh_token', _refreshToken ?? '');
    if (_expiresAt != null) {
      await _prefs.setInt(
        'strava_expires_at',
        _expiresAt!.millisecondsSinceEpoch,
      );
    }
  }

  /// Authenticate with Strava using authorization code (OAuth2)
  Future<bool> authenticate(String authCode) async {
    try {
      AppLogger.info('Authenticating with Strava', tag: _tag);

      final response = await http.post(
        Uri.parse(_authUrl),
        body: {
          'client_id': _clientId,
          'client_secret': _clientSecret,
          'code': authCode,
          'grant_type': 'authorization_code',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException('Authentication timeout'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _accessToken = data['access_token'] as String;
        _refreshToken = data['refresh_token'] as String;
        _expiresAt =
            DateTime.now().add(Duration(seconds: data['expires_in'] as int));

        await _saveTokens();
        AppLogger.info('Successfully authenticated with Strava', tag: _tag);
        return true;
      } else {
        AppLogger.error(
          'Authentication failed: ${response.body}',
          tag: _tag,
        );
        return false;
      }
    } catch (e) {
      AppLogger.error(
        'Error authenticating with Strava',
        tag: _tag,
        exception: e,
      );
      return false;
    }
  }

  /// Refresh access token if expired
  Future<bool> refreshToken() async {
    try {
      if (_refreshToken == null) {
        AppLogger.warning('No refresh token available', tag: _tag);
        return false;
      }

      AppLogger.info('Refreshing Strava access token', tag: _tag);

      final response = await http.post(
        Uri.parse(_authUrl),
        body: {
          'client_id': _clientId,
          'client_secret': _clientSecret,
          'grant_type': 'refresh_token',
          'refresh_token': _refreshToken,
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException('Token refresh timeout'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _accessToken = data['access_token'] as String;
        _refreshToken = data['refresh_token'] as String;
        _expiresAt =
            DateTime.now().add(Duration(seconds: data['expires_in'] as int));

        await _saveTokens();
        AppLogger.info('Token refreshed successfully', tag: _tag);
        return true;
      } else {
        AppLogger.error(
          'Token refresh failed: ${response.body}',
          tag: _tag,
        );
        return false;
      }
    } catch (e) {
      AppLogger.error(
        'Error refreshing token',
        tag: _tag,
        exception: e,
      );
      return false;
    }
  }

  /// Upload a session activity to Strava
  Future<bool> uploadActivity(Session session) async {
    try {
      // Check if token needs refresh
      if (_expiresAt != null && DateTime.now().isAfter(_expiresAt!)) {
        final refreshed = await refreshToken();
        if (!refreshed) {
          AppLogger.error('Failed to refresh token', tag: _tag);
          return false;
        }
      }

      if (_accessToken == null) {
        AppLogger.error('No access token available', tag: _tag);
        return false;
      }

      AppLogger.info('Uploading activity to Strava for session: ${session.id}',
          tag: _tag);

      final activityData = {
        'name': 'GoPaddler - ${session.sportType}',
        'type': _mapToStravaActivityType(session.sportType),
        'start_date_local': session.startTime.toIso8601String(),
        'elapsed_time': session.duration.inSeconds,
        'distance': session.totalDistance,
        'description': 'Recorded with GoPaddler',
      };

      final response = await http
          .post(
            Uri.parse('$_apiBaseUrl/activities'),
            headers: {
              'Authorization': 'Bearer $_accessToken',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(activityData),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw TimeoutException('Strava upload timeout'),
          );

      if (response.statusCode == 201) {
        AppLogger.info(
          'Activity uploaded to Strava successfully',
          tag: _tag,
        );
        return true;
      } else {
        AppLogger.error(
          'Strava upload failed with status ${response.statusCode}: '
          '${response.body}',
          tag: _tag,
        );
        return false;
      }
    } catch (e) {
      AppLogger.error(
        'Error uploading to Strava',
        tag: _tag,
        exception: e,
      );
      return false;
    }
  }

  /// Get athlete profile from Strava
  Future<Map<String, dynamic>?> getAthleteProfile() async {
    try {
      if (_accessToken == null) {
        AppLogger.error('No access token available', tag: _tag);
        return null;
      }

      AppLogger.info('Fetching athlete profile from Strava', tag: _tag);

      final response = await http.get(
        Uri.parse('$_apiBaseUrl/athlete'),
        headers: {'Authorization': 'Bearer $_accessToken'},
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException('Profile fetch timeout'),
      );

      if (response.statusCode == 200) {
        final profile = jsonDecode(response.body) as Map<String, dynamic>;
        AppLogger.debug('Athlete profile retrieved', tag: _tag);
        return profile;
      } else {
        AppLogger.error(
          'Failed to fetch profile with status ${response.statusCode}',
          tag: _tag,
        );
        return null;
      }
    } catch (e) {
      AppLogger.error(
        'Error fetching athlete profile',
        tag: _tag,
        exception: e,
      );
      return null;
    }
  }

  /// Fetch activities from Strava
  Future<List<dynamic>> fetchActivities({int limit = 30}) async {
    try {
      if (_accessToken == null) {
        AppLogger.error('No access token available', tag: _tag);
        return [];
      }

      AppLogger.info('Fetching activities from Strava (limit: $limit)',
          tag: _tag);

      final response = await http.get(
        Uri.parse('$_apiBaseUrl/athlete/activities?per_page=$limit'),
        headers: {'Authorization': 'Bearer $_accessToken'},
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException('Activities fetch timeout'),
      );

      if (response.statusCode == 200) {
        final activities = jsonDecode(response.body) as List<dynamic>;
        AppLogger.info('Retrieved ${activities.length} activities from Strava',
            tag: _tag);
        return activities;
      } else {
        AppLogger.error(
          'Failed to fetch activities with status ${response.statusCode}',
          tag: _tag,
        );
        return [];
      }
    } catch (e) {
      AppLogger.error(
        'Error fetching activities',
        tag: _tag,
        exception: e,
      );
      return [];
    }
  }

  /// Check if authenticated
  bool get isAuthenticated => _accessToken != null;

  /// Map local sport type to Strava activity type
  String _mapToStravaActivityType(String sportType) {
    switch (sportType.toLowerCase()) {
      case 'canoeing':
        return 'Canoeing';
      case 'kayaking':
        return 'Kayaking';
      case 'cycling':
        return 'Ride';
      default:
        return 'Other';
    }
  }

  /// Clear stored tokens
  Future<void> clearTokens() async {
    try {
      _accessToken = null;
      _refreshToken = null;
      _expiresAt = null;
      await _prefs.remove('strava_access_token');
      await _prefs.remove('strava_refresh_token');
      await _prefs.remove('strava_expires_at');
      AppLogger.info('Tokens cleared', tag: _tag);
    } catch (e) {
      AppLogger.error(
        'Error clearing tokens',
        tag: _tag,
        exception: e,
      );
    }
  }
}
