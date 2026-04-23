import 'package:flutter/material.dart';

import '../models/weather_model.dart';
import '../utils/weather_utils.dart';
import 'glass_panel.dart';

class DailyForecast extends StatelessWidget {
  final List<DailyWeather> dailyData;

  const DailyForecast({super.key, required this.dailyData});

  @override
  Widget build(BuildContext context) {
    if (dailyData.isEmpty) {
      return const SizedBox.shrink();
    }

    final globalMin = dailyData.map((e) => e.minTemp).reduce((a, b) => a < b ? a : b);
    final globalMax = dailyData.map((e) => e.maxTemp).reduce((a, b) => a > b ? a : b);
    final range = globalMax - globalMin == 0 ? 1.0 : globalMax - globalMin;

    return GlassPanel(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: dailyData.asMap().entries.map((entry) {
          final index = entry.key;
          final day = entry.value;
          final isLast = index == dailyData.length - 1;
          final lowRatio = (day.minTemp - globalMin) / range;
          final highRatio = (day.maxTemp - globalMin) / range;

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              border: isLast
                  ? null
                  : Border(
                      bottom: BorderSide(
                        color: Colors.white.withValues(alpha: 0.1),
                        width: 0.5,
                      ),
                    ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 70,
                  child: Text(
                    WeatherUtils.getDayName(day.date),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  WeatherUtils.getWeatherEmoji(day.weatherCode, true),
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 44,
                  child: day.precipitationSum > 0
                      ? Text(
                          '${day.precipitationSum.round()}mm',
                          style: TextStyle(
                            color: Colors.lightBlueAccent.withValues(alpha: 0.8),
                            fontSize: 10,
                          ),
                        )
                      : null,
                ),
                Text(
                  '${day.minTemp.round()}°',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.maxWidth;
                        return Stack(
                          children: [
                            Positioned(
                              left: lowRatio * width,
                              width: (highRatio - lowRatio) * width,
                              top: 0,
                              bottom: 0,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF90CAF9), Color(0xFFFFD54F)],
                                  ),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${day.maxTemp.round()}°',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
