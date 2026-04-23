// lib/models/weather_model.dart

class WeatherData {
  final double temperature;
  final double feelsLike;
  final double windSpeed;
  final int humidity;
  final int weatherCode;
  final String description;
  final bool isDay;
  final List<HourlyWeather> hourly;
  final List<DailyWeather> daily;
  final double uvIndex;
  final double precipitation;

  WeatherData({
    required this.temperature,
    required this.feelsLike,
    required this.windSpeed,
    required this.humidity,
    required this.weatherCode,
    required this.description,
    required this.isDay,
    required this.hourly,
    required this.daily,
    required this.uvIndex,
    required this.precipitation,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>;
    final hourlyData = json['hourly'] as Map<String, dynamic>;
    final dailyData = json['daily'] as Map<String, dynamic>;

    List<HourlyWeather> hourlyList = [];
    final times = hourlyData['time'] as List;
    for (int i = 0; i < times.length && i < 24; i++) {
      hourlyList.add(HourlyWeather(
        time: times[i],
        temperature: (hourlyData['temperature_2m'][i] as num).toDouble(),
        weatherCode: hourlyData['weather_code'][i] as int,
        precipitation: (hourlyData['precipitation_probability'][i] as num).toDouble(),
      ));
    }

    List<DailyWeather> dailyList = [];
    final dTimes = dailyData['time'] as List;
    for (int i = 0; i < dTimes.length; i++) {
      dailyList.add(DailyWeather(
        date: dTimes[i],
        maxTemp: (dailyData['temperature_2m_max'][i] as num).toDouble(),
        minTemp: (dailyData['temperature_2m_min'][i] as num).toDouble(),
        weatherCode: dailyData['weather_code'][i] as int,
        precipitationSum: (dailyData['precipitation_sum'][i] as num).toDouble(),
        sunrise: dailyData['sunrise'][i],
        sunset: dailyData['sunset'][i],
      ));
    }

    final code = current['weather_code'] as int;

    return WeatherData(
      temperature: (current['temperature_2m'] as num).toDouble(),
      feelsLike: (current['apparent_temperature'] as num).toDouble(),
      windSpeed: (current['wind_speed_10m'] as num).toDouble(),
      humidity: current['relative_humidity_2m'] as int,
      weatherCode: code,
      description: _getDescription(code),
      isDay: current['is_day'] == 1,
      hourly: hourlyList,
      daily: dailyList,
      uvIndex: (current['uv_index'] ?? 0.0 as num).toDouble(),
      precipitation: (current['precipitation'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'feelsLike': feelsLike,
      'windSpeed': windSpeed,
      'humidity': humidity,
      'weatherCode': weatherCode,
      'description': description,
      'isDay': isDay,
      'hourly': hourly.map((item) => item.toJson()).toList(),
      'daily': daily.map((item) => item.toJson()).toList(),
      'uvIndex': uvIndex,
      'precipitation': precipitation,
    };
  }

  factory WeatherData.fromCacheJson(Map<String, dynamic> json) {
    return WeatherData(
      temperature: (json['temperature'] as num).toDouble(),
      feelsLike: (json['feelsLike'] as num).toDouble(),
      windSpeed: (json['windSpeed'] as num).toDouble(),
      humidity: json['humidity'] as int,
      weatherCode: json['weatherCode'] as int,
      description: json['description'] as String,
      isDay: json['isDay'] as bool,
      hourly: (json['hourly'] as List<dynamic>)
          .map((item) => HourlyWeather.fromJson(item as Map<String, dynamic>))
          .toList(),
      daily: (json['daily'] as List<dynamic>)
          .map((item) => DailyWeather.fromJson(item as Map<String, dynamic>))
          .toList(),
      uvIndex: (json['uvIndex'] as num).toDouble(),
      precipitation: (json['precipitation'] as num).toDouble(),
    );
  }

  static String _getDescription(int code) {
    if (code == 0) return 'Clear Sky';
    if (code <= 2) return 'Partly Cloudy';
    if (code == 3) return 'Overcast';
    if (code <= 49) return 'Foggy';
    if (code <= 59) return 'Drizzle';
    if (code <= 69) return 'Rain';
    if (code <= 79) return 'Snow';
    if (code <= 84) return 'Rain Showers';
    if (code <= 94) return 'Thunderstorm';
    return 'Heavy Thunderstorm';
  }
}

class HourlyWeather {
  final String time;
  final double temperature;
  final int weatherCode;
  final double precipitation;

  HourlyWeather({
    required this.time,
    required this.temperature,
    required this.weatherCode,
    required this.precipitation,
  });

  Map<String, dynamic> toJson() {
    return {
      'time': time,
      'temperature': temperature,
      'weatherCode': weatherCode,
      'precipitation': precipitation,
    };
  }

  factory HourlyWeather.fromJson(Map<String, dynamic> json) {
    return HourlyWeather(
      time: json['time'] as String,
      temperature: (json['temperature'] as num).toDouble(),
      weatherCode: json['weatherCode'] as int,
      precipitation: (json['precipitation'] as num).toDouble(),
    );
  }
}

class DailyWeather {
  final String date;
  final double maxTemp;
  final double minTemp;
  final int weatherCode;
  final double precipitationSum;
  final String sunrise;
  final String sunset;

  DailyWeather({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.weatherCode,
    required this.precipitationSum,
    required this.sunrise,
    required this.sunset,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'maxTemp': maxTemp,
      'minTemp': minTemp,
      'weatherCode': weatherCode,
      'precipitationSum': precipitationSum,
      'sunrise': sunrise,
      'sunset': sunset,
    };
  }

  factory DailyWeather.fromJson(Map<String, dynamic> json) {
    return DailyWeather(
      date: json['date'] as String,
      maxTemp: (json['maxTemp'] as num).toDouble(),
      minTemp: (json['minTemp'] as num).toDouble(),
      weatherCode: json['weatherCode'] as int,
      precipitationSum: (json['precipitationSum'] as num).toDouble(),
      sunrise: json['sunrise'] as String,
      sunset: json['sunset'] as String,
    );
  }
}

class LocationData {
  final double latitude;
  final double longitude;
  final String cityName;
  final String country;

  const LocationData({
    required this.latitude,
    required this.longitude,
    required this.cityName,
    required this.country,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'cityName': cityName,
      'country': country,
    };
  }

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      cityName: json['cityName'] as String,
      country: json['country'] as String,
    );
  }
}
