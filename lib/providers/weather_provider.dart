import 'package:flutter/foundation.dart';

import '../models/weather_cache_entry.dart';
import '../models/weather_model.dart';
import '../services/weather_api_service.dart';
import '../services/weather_cache_service.dart';

class WeatherProvider extends ChangeNotifier {
  WeatherProvider({
    WeatherApiService? apiService,
    WeatherCacheService? cacheService,
  })  : _apiService = apiService ?? WeatherApiService(),
        _cacheService = cacheService ?? WeatherCacheService();

  final WeatherApiService _apiService;
  final WeatherCacheService _cacheService;

  WeatherData? _weatherData;
  LocationData _location = const LocationData(
    latitude: 1.1301,
    longitude: 104.0529,
    cityName: 'Batam',
    country: 'Indonesia',
  );
  bool _isLoading = true;
  bool _isUsingCachedData = false;
  String? _errorMessage;
  String? _statusMessage;
  DateTime? _lastUpdated;

  WeatherData? get weatherData => _weatherData;
  LocationData get location => _location;
  bool get isLoading => _isLoading;
  bool get isUsingCachedData => _isUsingCachedData;
  String? get errorMessage => _errorMessage;
  String? get statusMessage => _statusMessage;
  DateTime? get lastUpdated => _lastUpdated;
  bool get hasData => _weatherData != null;

  Future<void> initialize() async {
    final cached = await _cacheService.load();
    if (cached != null) {
      _restoreCache(cached);
      _isLoading = false;
      _statusMessage = 'Offline-ready mode: showing your last saved forecast.';
      notifyListeners();
    }

    await refreshWeather(showLoading: cached == null);
  }

  Future<void> refreshWeather({bool showLoading = true}) async {
    if (showLoading) {
      _isLoading = true;
      _errorMessage = null;
      _statusMessage = null;
      notifyListeners();
    } else {
      _statusMessage = null;
    }

    try {
      final data = await _apiService.fetchWeather(
        _location.latitude,
        _location.longitude,
      );
      _weatherData = data;
      _isLoading = false;
      _isUsingCachedData = false;
      _errorMessage = null;
      _statusMessage = null;
      _lastUpdated = DateTime.now();
      notifyListeners();

      await _cacheService.save(
        WeatherCacheEntry(
          weather: data,
          location: _location,
          cachedAt: _lastUpdated!,
        ),
      );
    } on WeatherRequestException catch (error) {
      _isLoading = false;
      final cached = await _cacheService.load();
      if (cached != null) {
        _restoreCache(cached);
        _statusMessage = error.message;
      } else {
        _errorMessage = error.message;
      }
      notifyListeners();
    } catch (_) {
      _isLoading = false;
      final cached = await _cacheService.load();
      if (cached != null) {
        _restoreCache(cached);
        _statusMessage = 'The latest forecast could not be refreshed, so this is your saved weather snapshot.';
      } else {
        _errorMessage = 'The sky map is temporarily unavailable. Please try again shortly.';
      }
      notifyListeners();
    }
  }

  Future<void> selectLocation(LocationData location) async {
    _location = location;
    notifyListeners();
    await refreshWeather();
  }

  Future<List<LocationData>> searchLocations(String query) {
    return _apiService.searchCity(query);
  }

  void clearStatusMessage() {
    if (_statusMessage == null) {
      return;
    }
    _statusMessage = null;
    notifyListeners();
  }

  void _restoreCache(WeatherCacheEntry cached) {
    _weatherData = cached.weather;
    _location = cached.location;
    _lastUpdated = cached.cachedAt;
    _isUsingCachedData = true;
    _errorMessage = null;
  }
}
