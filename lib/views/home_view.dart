import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../models/weather_model.dart';
import '../providers/weather_provider.dart';
import '../utils/forecast_filter_utils.dart';
import '../utils/weather_utils.dart';
import '../widgets/daily_forecast.dart';
import '../widgets/filter_chip_bar.dart';
import '../widgets/hourly_chart.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/stat_card.dart';
import '../widgets/weather_loading_shimmer.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  late final WeatherProvider _provider;
  late final AnimationController _fadeController;
  late final AnimationController _slideController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  ForecastFilter _forecastFilter = ForecastFilter.all;
  HourWindow _hourWindow = HourWindow.next12;

  @override
  void initState() {
    super.initState();
    _provider = WeatherProvider()..addListener(_handleProviderChanged);
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _provider.initialize();
  }

  @override
  void dispose() {
    _provider
      ..removeListener(_handleProviderChanged)
      ..dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _handleProviderChanged() {
    if (_provider.hasData && !_provider.isLoading) {
      _fadeController.forward(from: 0);
      _slideController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _provider,
      builder: (context, _) {
        final weather = _provider.weatherData;
        final gradientColors = weather != null
            ? WeatherUtils.getGradientColors(weather.weatherCode, weather.isDay)
            : [const Color(0xFF2196F3), const Color(0xFF21CBF3), const Color(0xFF87CEEB)];

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Scaffold(
            body: AnimatedContainer(
              duration: const Duration(milliseconds: 800),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: gradientColors,
                ),
              ),
              child: SafeArea(
                child: _provider.isLoading && weather == null
                    ? const WeatherLoadingShimmer()
                    : _provider.errorMessage != null && weather == null
                        ? _buildError()
                        : _buildContent(weather!),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                size: 54,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Forecast temporarily out of reach',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              _provider.errorMessage ?? '',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 15,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 22),
            Text(
              'Try again when your connection settles down.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                _provider.refreshWeather();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1565C0),
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(WeatherData weather) {
    final accentColor = WeatherUtils.getAccentColor(weather.weatherCode, weather.isDay);
    final filteredDaily = ForecastFilterUtils.filterDailyForecast(
      weather.daily,
      _forecastFilter,
    );
    final filteredHourly = ForecastFilterUtils.filterHourlyForecast(
      weather.hourly,
      _hourWindow,
    );

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: RefreshIndicator(
          onRefresh: () => _provider.refreshWeather(),
          color: Colors.white,
          backgroundColor: Colors.transparent,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: SearchBarWidget(
                              onLocationSelected: _provider.selectLocation,
                              onSearch: _provider.searchLocations,
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () {
                              _provider.refreshWeather();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.refresh, color: Colors.white, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_provider.statusMessage != null || _provider.isUsingCachedData)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                        child: _buildStatusBanner(),
                      ),
                    const SizedBox(height: 32),
                    Text(
                      _provider.location.cityName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 2,
                      ),
                    ),
                    Text(
                      _provider.location.country,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 14,
                        letterSpacing: 1,
                      ),
                    ),
                    if (_provider.lastUpdated != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _provider.isUsingCachedData
                              ? 'Saved ${DateFormat('MMM d, HH:mm').format(_provider.lastUpdated!.toLocal())}'
                              : 'Updated ${DateFormat('MMM d, HH:mm').format(_provider.lastUpdated!.toLocal())}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 12,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                    Text(
                      WeatherUtils.getWeatherEmoji(weather.weatherCode, weather.isDay),
                      style: const TextStyle(fontSize: 80),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${weather.temperature.round()}°',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 90,
                        fontWeight: FontWeight.w100,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      weather.description,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 20,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'H:${weather.daily.first.maxTemp.round()}°  L:${weather.daily.first.minTemp.round()}°',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: StatCard(
                              icon: '💧',
                              label: 'Humidity',
                              value: '${weather.humidity}%',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: StatCard(
                              icon: '💨',
                              label: 'Wind',
                              value: '${weather.windSpeed.round()} km/h',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: StatCard(
                              icon: '🌡️',
                              label: 'Feels Like',
                              value: '${weather.feelsLike.round()}°',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: StatCard(
                              icon: '☔',
                              label: 'Rain',
                              value: '${weather.precipitation} mm',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: StatCard(
                              icon: '🕐',
                              label: 'Sunrise',
                              value: WeatherUtils.formatTime(weather.daily.first.sunrise),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: StatCard(
                              icon: '🌆',
                              label: 'Sunset',
                              value: WeatherUtils.formatTime(weather.daily.first.sunset),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Hourly Outlook'),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                      child: FilterChipBar<HourWindow>(
                        options: HourWindow.values,
                        selected: _hourWindow,
                        labelBuilder: ForecastFilterUtils.hourFilterLabel,
                        onSelected: (value) {
                          setState(() {
                            _hourWindow = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    HourlyChart(
                      hourlyData: filteredHourly,
                      accentColor: accentColor,
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle('7-Day Forecast'),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                      child: FilterChipBar<ForecastFilter>(
                        options: ForecastFilter.values,
                        selected: _forecastFilter,
                        labelBuilder: ForecastFilterUtils.forecastFilterLabel,
                        onSelected: (value) {
                          setState(() {
                            _forecastFilter = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (filteredDaily.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildEmptyFilterState(),
                      )
                    else
                      DailyForecast(dailyData: filteredDaily),
                    const SizedBox(height: 32),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        _provider.isUsingCachedData
                            ? 'Powered by Open-Meteo, backed by your saved forecast'
                            : 'Powered by Open-Meteo API',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 11,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBanner() {
    final background = _provider.isUsingCachedData
        ? Colors.white.withValues(alpha: 0.16)
        : Colors.white.withValues(alpha: 0.12);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Row(
        children: [
          Icon(
            _provider.isUsingCachedData ? Icons.wifi_off_rounded : Icons.info_outline_rounded,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _provider.statusMessage ??
                  'Showing your saved forecast while we wait for the network.',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                height: 1.35,
              ),
            ),
          ),
          if (_provider.statusMessage != null)
            IconButton(
              onPressed: _provider.clearStatusMessage,
              icon: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyFilterState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: const Column(
        children: [
          Icon(Icons.filter_alt_off_rounded, color: Colors.white, size: 28),
          SizedBox(height: 10),
          Text(
            'No days match this filter yet.',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Try another filter to explore the rest of the week.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(),
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}
