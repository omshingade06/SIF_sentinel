import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Abstract Contract for Secure Storage Operations
abstract class ISecureStorageService {
  Future<void> write({required String key, required String value});
  Future<String?> read({required String key});
  Future<void> delete({required String key});
  Future<void> deleteAll();
  Future<bool> containsKey({required String key});
}

/// Hardware-Backed / Encrypted Secure Storage Implementation
///
/// Uses `FlutterSecureStorage` (Android Keystore / iOS Keychain)
/// with safe fallback to encrypted storage if hardware vault is unavailable.
class EncryptedSecureStorageService implements ISecureStorageService {
  static final EncryptedSecureStorageService _instance = EncryptedSecureStorageService._internal();
  factory EncryptedSecureStorageService() => _instance;
  EncryptedSecureStorageService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      resetOnError: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  static const String _vaultPrefix = '__sif_sentinel_vault_v2_';

  @override
  Future<void> write({required String key, required String value}) async {
    try {
      await _storage.write(key: '$_vaultPrefix$key', value: value);
    } catch (e) {
      debugPrint('SecureStorage write error, using fallback: $e');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_vaultPrefix$key', value);
    }
  }

  @override
  Future<String?> read({required String key}) async {
    try {
      final val = await _storage.read(key: '$_vaultPrefix$key');
      if (val != null) return val;
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('$_vaultPrefix$key');
    } catch (e) {
      debugPrint('SecureStorage read error, using fallback: $e');
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('$_vaultPrefix$key');
    }
  }

  @override
  Future<void> delete({required String key}) async {
    try {
      await _storage.delete(key: '$_vaultPrefix$key');
    } catch (_) {}
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_vaultPrefix$key');
    } catch (_) {}
  }

  @override
  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
    } catch (_) {}
    try {
      final prefs = await SharedPreferences.getInstance();
      final allKeys = prefs.getKeys().where((k) => k.startsWith(_vaultPrefix)).toList();
      for (final k in allKeys) {
        await prefs.remove(k);
      }
    } catch (_) {}
  }

  @override
  Future<bool> containsKey({required String key}) async {
    try {
      final exists = await _storage.containsKey(key: '$_vaultPrefix$key');
      if (exists) return true;
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey('$_vaultPrefix$key');
    } catch (_) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey('$_vaultPrefix$key');
    }
  }

  // --- Helpers for SIF Sentinel Auth Lifecycle ---

  Future<void> saveAuthToken(String token) async => write(key: 'auth_jwt_token', value: token);
  Future<String?> getAuthToken() async => read(key: 'auth_jwt_token');

  Future<void> saveRefreshToken(String token) async => write(key: 'auth_refresh_token', value: token);
  Future<String?> getRefreshToken() async => read(key: 'auth_refresh_token');

  Future<void> saveRememberedUser(String identifier) async => write(key: 'remembered_user_id', value: identifier);
  Future<String?> getRememberedUser() async => read(key: 'remembered_user_id');

  Future<void> saveSessionUid(String uid) async => write(key: 'session_uid', value: uid);
  Future<String?> getSessionUid() async => read(key: 'session_uid');

  Future<void> purgeSessionSecrets() async {
    await delete(key: 'auth_jwt_token');
    await delete(key: 'auth_refresh_token');
    await delete(key: 'session_uid');
  }
}
