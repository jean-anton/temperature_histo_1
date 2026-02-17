/// Application configuration using compile-time constants.
///
/// Use `--dart-define=INCLUDE_CLIMATE=false` to build the weather-only variant.
/// Default is `true` for the full AeroClim application.
class AppConfig {
  AppConfig._();

  /// Feature flag for climate/climatology functionality.
  /// Set to false to exclude the climate feature entirely.
  static const bool includeClimate = bool.fromEnvironment(
    'INCLUDE_CLIMATE',
    defaultValue: true,
  );

  /// Application display name.
  static String get appName => includeClimate ? 'AeroClim' : 'AeroClim Weather';

  /// Application version suffix for identification.
  static String get versionSuffix => includeClimate ? '' : '-weather';

  /// Android application ID suffix.
  static String get androidAppIdSuffix => includeClimate ? '' : '.weather';

  /// Whether to show climate-related UI elements.
  static bool get showClimateUI => includeClimate;

  /// Whether to load climate data assets.
  static bool get loadClimateData => includeClimate;
}
