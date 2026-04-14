import 'package:shared_preferences/shared_preferences.dart';
import '../models/session.dart';
import '../../utils/app_logger.dart';

/// Service for Strava API integration (MVP: Disabled)
/// 
/// In MVP mode, this service is disabled and all methods return false/empty.
/// Strava integration requires:
/// - OAuth2 credentials (clientId, clientSecret)
/// - Valid Strava account
/// - Internet connectivity
/// 
/// This can be re-enabled when backend infrastructure and credentials are available.
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
  /// MVP: DISABLED - No server connections in MVP mode
  Future<bool> authenticate(String authCode) async {
    try {
      AppLogger.info(
        'MVP MODE: Strava authentication disabled. '
        'Implement when Strava credentials available.',
        tag: _tag,
      );
      return false;
    } catch (e) {
      AppLogger.error(
        'Error in MVP authenticate',
        tag: _tag,
        exception: e,
      );
      return false;
    }
  }

  /// Refresh access token if expired
  /// MVP: DISABLED - No server connections in MVP mode
  Future<bool> refreshToken() async {
    try {
      AppLogger.info('MVP MODE: Token refresh disabled', tag: _tag);
      return false;
    } catch (e) {
      AppLogger.error(
        'Error in MVP refreshToken',
        tag: _tag,
        exception: e,
      );
      return false;
    }
  }

  /// Upload a session activity to Strava
  /// MVP: DISABLED - No server connections in MVP mode
  Future<bool> uploadActivity(Session session) async {
    try {
      AppLogger.info(
        'MVP MODE: Strava activity upload disabled for session: ${session.id}',
        tag: _tag,
      );
      return false;
    } catch (e) {
      AppLogger.error(
        'Error in MVP uploadActivity',
        tag: _tag,
        exception: e,
      );
      return false;
    }
  }

  /// Get athlete profile from Strava
  /// MVP: DISABLED - No server connections in MVP mode
  Future<Map<String, dynamic>?> getAthleteProfile() async {
    try {
      AppLogger.info('MVP MODE: Athlete profile fetch disabled', tag: _tag);
      return null;
    } catch (e) {
      AppLogger.error(
        'Error in MVP getAthleteProfile',
        tag: _tag,
        exception: e,
      );
      return null;
    }
  }

  /// Fetch activities from Strava
  /// MVP: DISABLED - No server connections in MVP mode
  Future<List<dynamic>> fetchActivities({int limit = 30}) async {
    try {
      AppLogger.info(
        'MVP MODE: Activity fetch disabled (limit: $limit)',
        tag: _tag,
      );
      return [];
    } catch (e) {
      AppLogger.error(
        'Error in MVP fetchActivities',
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
