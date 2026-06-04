import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

class OtpCascade {
  static String? _baseUrl;
  static final LocalAuthentication _localAuth = LocalAuthentication();

  /// Initialize the OtpCascade SDK with base URL of the Laravel backend
  static void initialize({required String baseUrl}) {
    _baseUrl = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
  }

  static String get _checkBaseUrl {
    if (_baseUrl == null) {
      throw Exception('OtpCascade is not initialized. Call OtpCascade.initialize(baseUrl) first.');
    }
    return _baseUrl!;
  }

  /// Check if the device supports biometric/passkey authentication
  static Future<bool> isBiometricsSupported() async {
    final bool canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
    final bool canAuthenticate = canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();
    return canAuthenticate;
  }

  /// Step 1: Register Passkey on this device
  static Future<Map<String, dynamic>> registerPasskey({
    required String userId,
    required String phone,
  }) async {
    final baseUrl = _checkBaseUrl;

    try {
      // 1. Contact Laravel backend to begin registration and get challenge
      final responseBegin = await http.post(
        Uri.parse('$baseUrl/api/otp/passkey/register/begin'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId, 'phone': phone}),
      );

      if (responseBegin.statusCode != 200) {
        return {'success': false, 'error': 'Failed to begin registration: ${responseBegin.body}'};
      }

      final dataBegin = jsonDecode(responseBegin.body);
      final String challenge = dataBegin['challenge'];

      // 2. Request user biometrics to enroll/approve passkey
      bool authenticated = await _localAuth.authenticate(
        localizedReason: 'Ro\'yxatdan o\'tish uchun biometriyani tasdiqlang',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (!authenticated) {
        return {'success': false, 'error': 'User cancelled biometrics'};
      }

      // Generate simulated key pair for local demo / FIDO2 integration
      // In production Flutter WebAuthn, this uses android Credential Manager API or iOS AuthenticationServices.
      final String credentialId = 'cred_${DateTime.now().millisecondsSinceEpoch}';
      
      // Public key representation in PEM format
      final String mockPublicKey = '''-----BEGIN PUBLIC KEY-----
MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAE7Zc1h2hN6V4L9Z4o8Kk7G0bM7X9y
Hk4K6nZ4W9Z4o8Kk7G0bM7X9yHk4K6nZ4W9Z4o8Kk7G0bM7X9yHk4K6w==
-----END PUBLIC KEY-----''';

      // 3. Complete registration on backend
      final responseFinish = await http.post(
        Uri.parse('$baseUrl/api/otp/passkey/register/finish'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'credential_id': credentialId,
          'public_key': mockPublicKey,
        }),
      );

      if (responseFinish.statusCode == 200) {
        return {'success': true, 'message': 'Passkey registered successfully'};
      } else {
        return {'success': false, 'error': 'Failed to finish registration: ${responseFinish.body}'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Step 2: Authenticate User with Passkey
  static Future<Map<String, dynamic>> authenticateWithPasskey({
    required String userId,
  }) async {
    final baseUrl = _checkBaseUrl;

    try {
      // 1. Get challenge and allowed credentials from server
      final responseBegin = await http.post(
        Uri.parse('$baseUrl/api/otp/passkey/authenticate/begin'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId}),
      );

      if (responseBegin.statusCode != 200) {
        return {'success': false, 'error': 'Failed to begin authentication: ${responseBegin.body}'};
      }

      final dataBegin = jsonDecode(responseBegin.body);
      final List credentials = dataBegin['allowCredentials'];
      
      if (credentials.isEmpty) {
        return {'success': false, 'error': 'No registered credentials found.'};
      }

      // Choose first matching credential
      final String credentialId = credentials.first['id'];

      // 2. Prompt Face ID / Touch ID / PIN
      bool authenticated = await _localAuth.authenticate(
        localizedReason: 'Tizimga kirishni biometriya orqali tasdiqlang',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );

      if (!authenticated) {
        return {'success': false, 'error': 'User cancelled biometric prompt'};
      }

      // 3. Complete authentication on backend with signed challenge (represented by sandbox mock signature)
      final responseFinish = await http.post(
        Uri.parse('$baseUrl/api/otp/passkey/authenticate/finish'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'credential_id': credentialId,
          'signature': 'sandbox_mock_signature', // Cryptographic signature simulated
          'client_data_json': 'mock_client_data_json_with_challenge'
        }),
      );

      if (responseFinish.statusCode == 200) {
        final dataFinish = jsonDecode(responseFinish.body);
        return {
          'success': true,
          'token': dataFinish['token'],
          'message': 'Authenticated successfully with Passkey'
        };
      } else {
        return {'success': false, 'error': 'Passkey authentication failed: ${responseFinish.body}'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Step 3: Register Push token for In-App Push OTPs
  static Future<bool> registerPushToken({
    required String userId,
    required String token,
    String? deviceType,
    String? deviceName,
  }) async {
    final baseUrl = _checkBaseUrl;
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/otp/push/token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'push_token': token,
          'device_type': deviceType,
          'device_name': deviceName,
        }),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Send Push OTP
  static Future<Map<String, dynamic>> sendPushOtp({required String userId}) async {
    final baseUrl = _checkBaseUrl;
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/otp/push/send'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'fallback': true, 'error': e.toString()};
    }
  }

  /// Verify Push OTP
  static Future<Map<String, dynamic>> verifyPushOtp({
    required String userId,
    required String otp,
  }) async {
    final baseUrl = _checkBaseUrl;
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/otp/push/verify'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId, 'otp': otp}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, ...data};
      } else {
        return {'success': false, ...data};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
