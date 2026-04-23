import 'package:flutter/material.dart';

class WeatherUtils {
  static String getWeatherEmoji(int code, bool isDay) {
    if (code == 0) return isDay ? '☀️' : '🌙';
    if (code <= 2) return isDay ? '⛅' : '🌤️';
    if (code == 3) return '☁️';
    if (code <= 49) return '🌫️';
    if (code <= 59) return '🌦️';
    if (code <= 69) return '🌧️';
    if (code <= 79) return '❄️';
    if (code <= 84) return '🌨️';
    if (code <= 94) return '⛈️';
    return '🌩️';
  }

  static List<Color> getGradientColors(int code, bool isDay) {
    if (!isDay) {
      return [const Color(0xFF0F0C29), const Color(0xFF302B63), const Color(0xFF24243E)];
    }
    if (code == 0) {
      return [const Color(0xFF2196F3), const Color(0xFF21CBF3), const Color(0xFF87CEEB)];
    }
    if (code <= 3) {
      return [const Color(0xFF4A90D9), const Color(0xFF7BAFD4), const Color(0xFFB0C4DE)];
    }
    if (code <= 49) {
      return [const Color(0xFF6B7B8D), const Color(0xFF8FA0B3), const Color(0xFFBCC6CC)];
    }
    if (code <= 69) {
      return [const Color(0xFF2C3E50), const Color(0xFF4A6FA5), const Color(0xFF6B8FB5)];
    }
    if (code <= 79) {
      return [const Color(0xFF4A6FA5), const Color(0xFF8ABBE8), const Color(0xFFD6E4F0)];
    }
    return [const Color(0xFF1A1A2E), const Color(0xFF16213E), const Color(0xFF0F3460)];
  }

  static Color getAccentColor(int code, bool isDay) {
    if (!isDay) return const Color(0xFFB39DDB);
    if (code == 0) return const Color(0xFFFFD54F);
    if (code <= 3) return const Color(0xFFE0E0E0);
    if (code <= 49) return const Color(0xFFB0BEC5);
    if (code <= 69) return const Color(0xFF90CAF9);
    if (code <= 79) return Colors.white;
    return const Color(0xFFEF9A9A);
  }

  static String getDayName(String dateStr) {
    final date = DateTime.parse(dateStr);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);

    if (target == today) return 'Today';
    if (target == today.add(const Duration(days: 1))) return 'Tomorrow';

    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  static String formatHour(String timeStr) {
    final dateTime = DateTime.parse(timeStr);
    final hour = dateTime.hour;
    if (hour == 0) return '12 AM';
    if (hour < 12) return '$hour AM';
    if (hour == 12) return '12 PM';
    return '${hour - 12} PM';
  }

  static String formatTime(String timeStr) {
    final dateTime = DateTime.parse(timeStr);
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    if (hour == 0) return '12:$minute AM';
    if (hour < 12) return '$hour:$minute AM';
    if (hour == 12) return '12:$minute PM';
    return '${hour - 12}:$minute PM';
  }

  static String getUVDescription(double uv) {
    if (uv < 3) return 'Low';
    if (uv < 6) return 'Moderate';
    if (uv < 8) return 'High';
    if (uv < 11) return 'Very High';
    return 'Extreme';
  }
}
