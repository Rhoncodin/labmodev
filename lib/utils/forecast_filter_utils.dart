import '../models/weather_model.dart';

enum ForecastFilter { all, rainy, warm, clear }

enum HourWindow { next6, next12, next24 }

class ForecastFilterUtils {
  static List<DailyWeather> filterDailyForecast(
    List<DailyWeather> daily,
    ForecastFilter filter,
  ) {
    switch (filter) {
      case ForecastFilter.all:
        return daily;
      case ForecastFilter.rainy:
        return daily.where((day) => day.precipitationSum > 0).toList();
      case ForecastFilter.warm:
        return daily.where((day) => day.maxTemp >= 30).toList();
      case ForecastFilter.clear:
        return daily.where((day) => day.weatherCode == 0).toList();
    }
  }

  static List<HourlyWeather> filterHourlyForecast(
    List<HourlyWeather> hourly,
    HourWindow window, {
    DateTime? now,
  }) {
    final count = switch (window) {
      HourWindow.next6 => 6,
      HourWindow.next12 => 12,
      HourWindow.next24 => 24,
    };

    final currentTime = now ?? DateTime.now();
    final hourFloor = DateTime(
      currentTime.year,
      currentTime.month,
      currentTime.day,
      currentTime.hour,
    );

    final upcoming = hourly
        .where((item) => !DateTime.parse(item.time).isBefore(hourFloor))
        .take(count)
        .toList();

    if (upcoming.isNotEmpty) {
      return upcoming;
    }

    return hourly.take(count).toList();
  }

  static String forecastFilterLabel(ForecastFilter filter) {
    return switch (filter) {
      ForecastFilter.all => 'All',
      ForecastFilter.rainy => 'Rainy',
      ForecastFilter.warm => 'Warm',
      ForecastFilter.clear => 'Clear',
    };
  }

  static String hourFilterLabel(HourWindow window) {
    return switch (window) {
      HourWindow.next6 => 'Next 6h',
      HourWindow.next12 => 'Next 12h',
      HourWindow.next24 => 'Next 24h',
    };
  }
}
