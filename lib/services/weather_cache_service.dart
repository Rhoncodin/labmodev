import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/weather_cache_entry.dart';

class WeatherCacheService {
  static const String _weatherCacheKey = 'cached_weather_entry';

  Future<void> save(WeatherCacheEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_weatherCacheKey, jsonEncode(entry.toJson()));
  }

  Future<WeatherCacheEntry?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_weatherCacheKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return WeatherCacheEntry.fromJson(json);
    } catch (_) {
      await prefs.remove(_weatherCacheKey);
      return null;
    }
  }
}
