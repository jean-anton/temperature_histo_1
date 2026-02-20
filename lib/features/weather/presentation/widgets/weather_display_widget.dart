import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:aeroclim/features/weather/domain/weather_model.dart';
import 'package:aeroclim/features/locations/domain/location_model.dart';
import 'package:aeroclim/features/climate/domain/climate_model.dart';
import 'package:aeroclim/core/widgets/responsive_layout.dart';
import 'package:aeroclim/core/config/app_config.dart';
import 'package:aeroclim/features/weather/presentation/widgets/weather_chart_widget.dart';
import 'package:aeroclim/features/weather/presentation/widgets/weather_table_widget.dart';
import 'package:aeroclim/features/weather/presentation/widgets/vent_table_widget.dart';
import 'package:aeroclim/features/weather/presentation/widgets/comparison_table_widget.dart';

import 'package:aeroclim/core/widgets/help_dialog.dart';

class WeatherDisplayWidget extends StatefulWidget {
  final WeatherLocationInfo weatherInfo;
  final ClimateLocationInfo? climateInfo;
  final String modelName;
  final String displayMode;
  final DisplayType displayType;
  final DailyWeather? forecast;
  final HourlyWeather? hourlyForecast;
  final MultiModelWeather? multiModelForecast;
  final MultiModelHourlyWeather? multiModelHourlyForecast;
  final List<ClimateNormal> climateNormals;
  final bool showWindInfo;
  final bool showExtendedWindInfo;
  final double maxGustSpeed;
  final int maxPrecipitationProbability;
  final double minApparentTemperature;
  final VoidCallback? onRefresh;

  const WeatherDisplayWidget({
    super.key,
    required this.weatherInfo,
    this.climateInfo,
    required this.modelName,
    required this.displayMode,
    required this.displayType,
    this.forecast,
    this.hourlyForecast,
    this.multiModelForecast,
    this.multiModelHourlyForecast,
    required this.climateNormals,
    required this.showWindInfo,
    required this.showExtendedWindInfo,
    required this.maxGustSpeed,
    required this.maxPrecipitationProbability,
    required this.minApparentTemperature,
    this.onRefresh,
  });

  @override
  State<WeatherDisplayWidget> createState() => _WeatherDisplayWidgetState();
}

class _WeatherDisplayWidgetState extends State<WeatherDisplayWidget> {
  DateTime? _focusedDate;

  @override
  void initState() {
    super.initState();
    _focusedDate = widget.forecast?.dailyForecasts.firstOrNull?.date;
  }

  @override
  void didUpdateWidget(WeatherDisplayWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.forecast != oldWidget.forecast ||
        widget.displayMode != oldWidget.displayMode) {
      _focusedDate = widget.forecast?.dailyForecasts.firstOrNull?.date;
    }
  }

  @override
  Widget build(BuildContext context) {
    String distanceInKm = '';
    if (AppConfig.includeClimate && widget.climateInfo != null) {
      const distanceVal = Distance();
      final meters = distanceVal(
        LatLng(widget.weatherInfo.lat, widget.weatherInfo.lon),
        LatLng(widget.climateInfo!.lat, widget.climateInfo!.lon),
      );
      distanceInKm = (meters / 1000).toStringAsFixed(1);
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeroSection(context, distanceInKm),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              child: _buildMainContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, String distanceInKm) {
    DailyForecast? displayedDay;
    if (_focusedDate != null && widget.forecast != null) {
      displayedDay = widget.forecast!.dailyForecasts.firstWhere(
        (daily) =>
            daily.date.year == _focusedDate!.year &&
            daily.date.month == _focusedDate!.month &&
            daily.date.day == _focusedDate!.day,
        orElse: () => widget.forecast!.dailyForecasts.first,
      );
    } else {
      displayedDay = widget.forecast?.dailyForecasts.firstOrNull;
    }

    final temp = displayedDay?.temperatureMax.toStringAsFixed(1) ?? '--';
    final isMobile = ResponsiveLayout.isMobile(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -5,
              top: -5,
              child: Icon(
                Icons.wb_sunny_outlined,
                size: 80,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16, isMobile ? 12 : 12, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.weatherInfo.formattedLocation,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 18,
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (AppConfig.includeClimate &&
                                widget.climateInfo != null)
                              Text(
                                "Climat: ${widget.climateInfo!.displayName} (${widget.climateInfo!.startYear}-${widget.climateInfo!.endYear}) • $distanceInKm km",
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Colors.white.withValues(
                                        alpha: 0.7,
                                      ),
                                      fontSize: 11,
                                    ),
                              ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          if (widget.onRefresh != null)
                            IconButton(
                              icon: const Icon(
                                Icons.refresh,
                                color: Colors.white70,
                                size: 20,
                              ),
                              onPressed: widget.onRefresh,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          if (widget.onRefresh != null)
                            const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(
                              Icons.help_outline,
                              color: Colors.white70,
                              size: 20,
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => const HelpDialog(),
                              );
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 8),
                          Badge(
                            label: Text(
                              widget.modelName,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 15,
                              ),
                            ),
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.2,
                            ),
                            textColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "$temp°",
                        style: GoogleFonts.outfit(
                          fontSize: 42,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (displayedDay != null)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayedDay.formattedDate,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                "Min: ${displayedDay.temperatureMin.toStringAsFixed(1)}°",
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    if (widget.displayType == DisplayType.comparatifTable) {
      return ComparisonTableWidget(
        multiModelForecast: widget.multiModelForecast,
        multiModelHourlyForecast: widget.multiModelHourlyForecast,
        displayMode: widget.displayMode,
        showExtendedWindInfo: widget.showExtendedWindInfo,
      );
    } else if (widget.displayType != DisplayType.tableau &&
        widget.displayType != DisplayType.ventTable) {
      return WeatherChart2(
        forecast: widget.forecast,
        hourlyWeather: widget.hourlyForecast,
        multiModelForecast: widget.multiModelForecast,
        multiModelHourlyWeather: widget.multiModelHourlyForecast,
        climateNormals: widget.climateNormals,
        displayMode: widget.displayMode,
        displayType: widget.displayType,
        showWindInfo: widget.showWindInfo,
        showExtendedWindInfo: widget.showExtendedWindInfo,
        onVisibleDayChanged: (date) {
          if (_focusedDate != date) {
            setState(() {
              _focusedDate = date;
            });
          }
        },
      );
    } else if (widget.displayType == DisplayType.ventTable) {
      return widget.hourlyForecast != null && widget.forecast != null
          ? VentTableWidget(
              hourlyWeather: widget.hourlyForecast!,
              dailyWeather: widget.forecast!,
              maxGustSpeed: widget.maxGustSpeed,
              maxPrecipitationProbability: widget.maxPrecipitationProbability,
              minApparentTemperature: widget.minApparentTemperature,
            )
          : const Center(child: Text('Tableau Vent non disponible'));
    } else {
      return widget.displayMode == 'daily' && widget.forecast != null
          ? WeatherTable(
              forecast: widget.forecast!,
              climateNormals: widget.climateNormals,
            )
          : const Center(child: Text('Tableau horaire non implémenté'));
    }
  }
}
