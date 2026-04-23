import 'weather_model.dart';

class WeatherCacheEntry {
  final WeatherData weather;
  final LocationData location;
  final DateTime cachedAt;

  const WeatherCacheEntry({
    required this.weather,
    required this.location,
    required this.cachedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'weather': weather.toJson(),
      'location': location.toJson(),
      'cachedAt': cachedAt.toIso8601String(),
    };
  }

  factory WeatherCacheEntry.fromJson(Map<String, dynamic> json) {
    return WeatherCacheEntry(
      weather: WeatherData.fromCacheJson(json['weather'] as Map<String, dynamic>),
      location: LocationData.fromJson(json['location'] as Map<String, dynamic>),
      cachedAt: DateTime.parse(json['cachedAt'] as String),
    );
  }
}
