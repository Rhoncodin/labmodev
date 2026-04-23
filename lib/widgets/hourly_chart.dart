import 'package:flutter/material.dart';

import '../models/weather_model.dart';
import '../utils/weather_utils.dart';
import 'glass_panel.dart';

class HourlyChart extends StatelessWidget {
  final List<HourlyWeather> hourlyData;
  final Color accentColor;

  const HourlyChart({
    super.key,
    required this.hourlyData,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    if (hourlyData.isEmpty) {
      return const SizedBox.shrink();
    }

    final temps = hourlyData.map((e) => e.temperature).toList();
    final minTemp = temps.reduce((a, b) => a < b ? a : b);
    final maxTemp = temps.reduce((a, b) => a > b ? a : b);
    final range = maxTemp - minTemp == 0 ? 1.0 : maxTemp - minTemp;

    return GlassPanel(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      child: SizedBox(
        height: 130,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: hourlyData.length,
          itemBuilder: (context, index) {
            final item = hourlyData[index];
            final normalized = (item.temperature - minTemp) / range;
            final barHeight = 40 + (normalized * 50);

            return SizedBox(
              width: 70,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '${item.temperature.round()}°',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  AnimatedContainer(
                    duration: Duration(milliseconds: 300 + index * 50),
                    height: barHeight,
                    width: 24,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          accentColor.withValues(alpha: 0.9),
                          accentColor.withValues(alpha: 0.3),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    index == 0 ? 'Now' : WeatherUtils.formatHour(item.time),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    WeatherUtils.getWeatherEmoji(item.weatherCode, true),
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
