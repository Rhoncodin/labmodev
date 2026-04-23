import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/utils/forecast_filter_utils.dart';

void main() {
  group('ForecastFilterUtils.filterDailyForecast', () {
    final daily = [
      DailyWeather(
        date: '2026-04-21',
        maxTemp: 31,
        minTemp: 25,
        weatherCode: 0,
        precipitationSum: 0,
        sunrise: '2026-04-21T05:45',
        sunset: '2026-04-21T18:02',
      ),
      DailyWeather(
        date: '2026-04-22',
        maxTemp: 28,
        minTemp: 24,
        weatherCode: 61,
        precipitationSum: 12,
        sunrise: '2026-04-22T05:45',
        sunset: '2026-04-22T18:02',
      ),
      DailyWeather(
        date: '2026-04-23',
        maxTemp: 29,
        minTemp: 23,
        weatherCode: 3,
        precipitationSum: 0,
        sunrise: '2026-04-23T05:45',
        sunset: '2026-04-23T18:02',
      ),
    ];

    test('returns all items for all filter', () {
      final results = ForecastFilterUtils.filterDailyForecast(
        daily,
        ForecastFilter.all,
      );

      expect(results, hasLength(3));
    });

    test('returns only rainy days for rainy filter', () {
      final results = ForecastFilterUtils.filterDailyForecast(
        daily,
        ForecastFilter.rainy,
      );

      expect(results.map((item) => item.date), ['2026-04-22']);
    });

    test('returns only warm days for warm filter', () {
      final results = ForecastFilterUtils.filterDailyForecast(
        daily,
        ForecastFilter.warm,
      );

      expect(results.map((item) => item.date), ['2026-04-21']);
    });

    test('returns only clear days for clear filter', () {
      final results = ForecastFilterUtils.filterDailyForecast(
        daily,
        ForecastFilter.clear,
      );

      expect(results.map((item) => item.date), ['2026-04-21']);
    });
  });

  group('ForecastFilterUtils.filterHourlyForecast', () {
    final hourly = List.generate(
      10,
      (index) => HourlyWeather(
        time: '2026-04-21T${index.toString().padLeft(2, '0')}:00',
        temperature: 24 + index.toDouble(),
        weatherCode: 0,
        precipitation: 0,
      ),
    );

    test('starts from the current hour block', () {
      final results = ForecastFilterUtils.filterHourlyForecast(
        hourly,
        HourWindow.next6,
        now: DateTime(2026, 4, 21, 4, 30),
      );

      expect(results, hasLength(6));
      expect(results.first.time, '2026-04-21T04:00');
      expect(results.last.time, '2026-04-21T09:00');
    });

    test('falls back to earliest entries when all data is in the past', () {
      final results = ForecastFilterUtils.filterHourlyForecast(
        hourly,
        HourWindow.next6,
        now: DateTime(2026, 4, 22, 2),
      );

      expect(results, hasLength(6));
      expect(results.first.time, '2026-04-21T00:00');
      expect(results.last.time, '2026-04-21T05:00');
    });
  });
}
