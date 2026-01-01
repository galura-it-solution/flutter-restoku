import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_query_flutter/cached_query_flutter.dart';

/// -------------------------
/// Helper untuk data biasa
/// -------------------------

class SharedPrefsHelper {
  static Future<void> saveModel(String key, dynamic data) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(data);
    await prefs.setString(key, jsonString);
  }

  static Future<dynamic> getModel(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(key);
    if (jsonString == null) return null;
    return jsonDecode(jsonString);
  }

  static Future<void> saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  static Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  static Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
}

/// -------------------------
/// Storage untuk CachedQuery
/// -------------------------

class SharedPreferencesStorage implements StorageInterface {
  SharedPreferences? _prefs;

  Future<void> _init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  @override
  Future<StoredQuery?> get(String key) async {
    await _init();
    final jsonString = _prefs!.getString(key);
    if (jsonString == null) return null;

    try {
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      return StoredQuery(
        key: map['key'] as String,
        data: map['data'],
        createdAt: DateTime.parse(map['createdAt'] as String),
        storageDuration: map['storageDuration'] != null
            ? Duration(milliseconds: map['storageDuration'] as int)
            : null,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> put(StoredQuery query) async {
    await _init();
    final map = {
      'key': query.key,
      'data': query.data,
      'createdAt': query.createdAt.toIso8601String(),
      'storageDuration': query.storageDuration?.inMilliseconds,
    };
    await _prefs!.setString(query.key, jsonEncode(map));
  }

  @override
  Future<void> delete(String key) async {
    await _init();
    await _prefs!.remove(key);
  }

  @override
  Future<void> deleteAll() async {
    await _init();
    await _prefs!.clear();
  }

  @override
  void close() {
    // SharedPreferences tidak perlu close, tapi interface butuh
  }
}
