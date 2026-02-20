// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get accept => 'Accept';

  @override
  String get addByCityName => 'Name';

  @override
  String get addByCoordinates => 'Coordinates';

  @override
  String get addCityHint => 'Type a city name...';

  @override
  String get addCityInstruction =>
      'Add a city in the \"Manage Cities\" menu to begin.';

  @override
  String get addThisLocation => 'Add this location';

  @override
  String get afternoon => 'Afternoon';

  @override
  String altitudeTooltip(Object altitude, Object unit, Object value) {
    return '${altitude}m: $value $unit';
  }

  @override
  String get apparent => 'Feels like';

  @override
  String get apparentLabelUnit => 'Feels like\n(°C)';

  @override
  String get apparentTemp => 'Apparent Temp.';

  @override
  String get appTitle => 'Aeroclim';

  @override
  String get avgDeviation => 'Avg. Deviation';

  @override
  String get basicInfo => 'Basic Information';

  @override
  String get bestMatch => 'Best Match';

  @override
  String citiesImported(Object count) {
    return '$count cities imported successfully';
  }

  @override
  String get climate => 'Climate';

  @override
  String get climateStation => 'Climate Station';

  @override
  String get close => 'Close';

  @override
  String get cloudCover => 'Cloud Cover';

  @override
  String get cloudsLabelUnit => 'Clouds\n(%)';

  @override
  String get comp => 'Comp';

  @override
  String get coordsHint => 'ex: 49.101, 6.793';

  @override
  String get daily => 'Daily';

  @override
  String get dailyLabel => 'Daily';

  @override
  String get date => 'Date';

  @override
  String get detailsByAltitude => 'Details by Altitude';

  @override
  String get directionAbbr => 'Dir.';

  @override
  String get dMax => 'DMax';

  @override
  String get dMin => 'DMin';

  @override
  String get disclaimerMessage =>
      'Data is provided for informational purposes and may differ from actual conditions. The author declines all responsibility for its use.';

  @override
  String get disclaimerTitle => 'WARNING';

  @override
  String get displayMode => 'Display Mode';

  @override
  String get enterLocationNameHint => 'Enter a name for this location';

  @override
  String get evening => 'Evening';

  @override
  String get export => 'Export';

  @override
  String exportError(Object error) {
    return 'Error during export: $error';
  }

  @override
  String get exportNotSupported => 'Export not supported on this platform';

  @override
  String get extendedWind => 'Extended Wind Info';

  @override
  String failedToLoadData(Object error) {
    return 'Error loading data: $error';
  }

  @override
  String get fillAllFields => 'Please fill all fields';

  @override
  String get filtersLabel => 'Filters';

  @override
  String get forecastLocation => 'Forecast Location';

  @override
  String get graph => 'Graph';

  @override
  String get gusts => 'Gusts';

  @override
  String get gustsLabelUnit => 'Gusts\n(km/h)';

  @override
  String get home => 'Home';

  @override
  String get hour => 'Hour';

  @override
  String get hourly => 'Hourly';

  @override
  String get hourlyTableNotImplemented => 'Hourly table not implemented';

  @override
  String get import => 'Import';

  @override
  String importError(Object error) {
    return 'Error during import: $error';
  }

  @override
  String get invalidCoords => 'Invalid coordinates (format: lat, lon)';

  @override
  String get kmh => 'km/h';

  @override
  String get location => 'LOCATION';

  @override
  String get locationNameLabel => 'Location Name';

  @override
  String get manageCities => 'Manage Cities';

  @override
  String get map => 'Map';

  @override
  String get max => 'Max';

  @override
  String get maxGusts => 'Max Gusts';

  @override
  String get maxPrecipProb => 'Max Precip. Prob.';

  @override
  String get min => 'Min';

  @override
  String get minApparentTemp => 'Min Apparent Temp.';

  @override
  String get model => 'MODEL';

  @override
  String get morning => 'Morning';

  @override
  String get needHelp => 'Need help?';

  @override
  String get night => 'Night';

  @override
  String get noCityError => 'No city registered. Please add one.';

  @override
  String get noCityFound => 'No city found';

  @override
  String get noCityRegisteredTitle => 'No city registered';

  @override
  String get noData => 'No data available';

  @override
  String get noMatchingHours => 'No hours match the selected criteria';

  @override
  String get normalMax => 'Normal Max';

  @override
  String get normalMin => 'Normal Min';

  @override
  String get period => 'Period';

  @override
  String get periods => 'Periods';

  @override
  String get precipChance => 'Precip. Chance';

  @override
  String get precipHours => 'Precip. Hours';

  @override
  String get precipLabelUnit => 'Precip\n(%)';

  @override
  String get precipProb => 'Precip. (%)';

  @override
  String get precipitation => 'Precipitation';

  @override
  String get previewLabel => 'Preview';

  @override
  String get privacyInfo =>
      'Privacy: No cookies or trackers. No data collected.';

  @override
  String get readHelp => 'Read Help';

  @override
  String get registeredCities => 'Registered cities:';

  @override
  String get searchError => 'Search error';

  @override
  String get selectLocation => 'Select a location';

  @override
  String get settings => 'Settings';

  @override
  String get showWind => 'Show Wind';

  @override
  String get snowfall => 'Snowfall';

  @override
  String get sourceCode => 'Source Code (GitHub)';

  @override
  String get speed => 'Speed';

  @override
  String get srcCodeGitHub => 'Source Code on GitHub';

  @override
  String get sunrise => 'Sunrise';

  @override
  String get sunset => 'Sunset';

  @override
  String get table => 'Table';

  @override
  String get tempAvg => 'Avg. Temp.';

  @override
  String get tempCelsius => 'Temperature (°C)';

  @override
  String get tempLabelUnit => 'Temp\n(°C)';

  @override
  String get tempMax => 'Max. Temp.';

  @override
  String get tempMin => 'Min. Temp.';

  @override
  String get temperature => 'Temperature';

  @override
  String get timeMode => 'Time Mode:';

  @override
  String get version => 'Version';

  @override
  String get viewType => 'View Type:';

  @override
  String get wasm => 'Wasm';

  @override
  String get weather => 'Weather';

  @override
  String get wind => 'Wind';

  @override
  String get windByAltitudeRange => 'Wind by altitude (10m-200m)';

  @override
  String get windDirection => 'Wind Direction';

  @override
  String get windSettings => 'WIND SETTINGS';

  @override
  String get windTableFilters => 'Wind Table Filters';

  @override
  String get windTableNotAvailable => 'Wind Table not available';

  @override
  String get helpAndUserManual => 'Help & User Manual';

  @override
  String get errorLoadingHelp => 'Error loading help: ';

  @override
  String get noContentFound => 'No content found.';

  @override
  String get copyUrlIfLinksDoNotWork =>
      'If links do not work, copy the URL below:';

  @override
  String get weatherDesc0 => 'Clear sky';

  @override
  String get weatherDesc1 => 'Mainly clear';

  @override
  String get weatherDesc2 => 'Partly cloudy';

  @override
  String get weatherDesc3 => 'Overcast';

  @override
  String get weatherDesc45 => 'Fog';

  @override
  String get weatherDesc48 => 'Depositing rime fog';

  @override
  String get weatherDesc51 => 'Light drizzle';

  @override
  String get weatherDesc53 => 'Moderate drizzle';

  @override
  String get weatherDesc55 => 'Dense drizzle';

  @override
  String get weatherDesc56 => 'Light freezing drizzle';

  @override
  String get weatherDesc57 => 'Dense freezing drizzle';

  @override
  String get weatherDesc61 => 'Slight rain';

  @override
  String get weatherDesc63 => 'Moderate rain';

  @override
  String get weatherDesc65 => 'Heavy rain';

  @override
  String get weatherDesc66 => 'Freezing rain';

  @override
  String get weatherDesc67 => 'Heavy freezing rain';

  @override
  String get weatherDesc71 => 'Slight snow fall';

  @override
  String get weatherDesc73 => 'Moderate snow fall';

  @override
  String get weatherDesc75 => 'Heavy snow fall';

  @override
  String get weatherDesc77 => 'Snow grains';

  @override
  String get weatherDesc80 => 'Slight rain showers';

  @override
  String get weatherDesc81 => 'Moderate rain showers';

  @override
  String get weatherDesc82 => 'Violent rain showers';

  @override
  String get weatherDesc85 => 'Slight snow showers';

  @override
  String get weatherDesc86 => 'Heavy snow showers';

  @override
  String get weatherDesc95 => 'Thunderstorm';

  @override
  String get weatherDesc96 => 'Thunderstorm with slight hail';

  @override
  String get weatherDesc99 => 'Thunderstorm with severe hail';
}
