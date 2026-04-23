import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/weather_model.dart';

class WeatherApiService {
  WeatherApiService({http.Client? client}) : _client = client ?? http.Client();

  static const String _baseUrl = 'https://api.open-meteo.com/v1/forecast';
  static const String _geocodeUrl = 'https://geocoding-api.open-meteo.com/v1/search';

  final http.Client _client;

  Future<WeatherData> fetchWeather(double lat, double lon) async {
    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'latitude': lat.toString(),
      'longitude': lon.toString(),
      'current': [
        'temperature_2m',
        'apparent_temperature',
        'relative_humidity_2m',
        'weather_code',
        'wind_speed_10m',
        'is_day',
        'precipitation',
        'uv_index',
      ].join(','),
      'hourly': [
        'temperature_2m',
        'weather_code',
        'precipitation_probability',
      ].join(','),
      'daily': [
        'temperature_2m_max',
        'temperature_2m_min',
        'weather_code',
        'precipitation_sum',
        'sunrise',
        'sunset',
      ].join(','),
      'timezone': 'auto',
      'forecast_days': '7',
    });

    try {
      final response = await _client.get(uri).timeout(const Duration(seconds: 12));
      if (response.statusCode != 200) {
        throw const WeatherRequestException(
          'The weather station is taking a break right now.',
        );
      }
      return WeatherData.fromJson(json.decode(response.body) as Map<String, dynamic>);
    } on SocketException {
      throw const WeatherRequestException(
        'No internet connection. Showing the latest saved forecast instead.',
      );
    } on TimeoutException {
      throw const WeatherRequestException(
        'The forecast took too long to arrive. Showing the latest saved weather instead.',
      );
    } on FormatException {
      throw const WeatherRequestException(
        'The weather report arrived in an unreadable format.',
      );
    }
  }

  Future<List<LocationData>> searchCity(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    final uri = Uri.parse(_geocodeUrl).replace(queryParameters: {
      'name': query,
      'count': '5',
      'language': 'en',
      'format': 'json',
    });

    try {
      final response = await _client.get(uri).timeout(const Duration(seconds: 12));
      if (response.statusCode != 200) {
        throw const WeatherRequestException(
          'City search is unavailable right now. Try again in a moment.',
        );
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>? ?? [];
      return results
          .map(
            (result) => LocationData(
              latitude: (result['latitude'] as num).toDouble(),
              longitude: (result['longitude'] as num).toDouble(),
              cityName: result['name'] as String? ?? 'Unknown',
              country: result['country'] as String? ?? '',
            ),
          )
          .toList();
    } on SocketException {
      throw const WeatherRequestException(
        'City search needs an internet connection.',
      );
    } on TimeoutException {
      throw const WeatherRequestException(
        'City search is moving slowly. Please try again.',
      );
    } on FormatException {
      throw const WeatherRequestException(
        'City search returned an unexpected response.',
      );
    }
  }
}

class WeatherRequestException implements Exception {
  final String message;

  const WeatherRequestException(this.message);

  @override
  String toString() => message;
}
