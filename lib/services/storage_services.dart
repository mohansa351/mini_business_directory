import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _cacheKey = 'cached_businesses_v1';

  Future<void> saveBusinessesJson(String json) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey, json);
  }

  Future<String?> loadBusinessesJson() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_cacheKey);
  }

  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
  }
}
