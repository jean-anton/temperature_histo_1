import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
  ];

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @addByCityName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get addByCityName;

  /// No description provided for @addByCoordinates.
  ///
  /// In en, this message translates to:
  /// **'Coordinates'**
  String get addByCoordinates;

  /// No description provided for @addCityHint.
  ///
  /// In en, this message translates to:
  /// **'Type a city name...'**
  String get addCityHint;

  /// No description provided for @addCityInstruction.
  ///
  /// In en, this message translates to:
  /// **'Add a city in the \"Manage Cities\" menu to begin.'**
  String get addCityInstruction;

  /// No description provided for @addThisLocation.
  ///
  /// In en, this message translates to:
  /// **'Add this location'**
  String get addThisLocation;

  /// No description provided for @afternoon.
  ///
  /// In en, this message translates to:
  /// **'Afternoon'**
  String get afternoon;

  /// No description provided for @altitudeTooltip.
  ///
  /// In en, this message translates to:
  /// **'{altitude}m: {value} {unit}'**
  String altitudeTooltip(Object altitude, Object unit, Object value);

  /// No description provided for @apparent.
  ///
  /// In en, this message translates to:
  /// **'Feels like'**
  String get apparent;

  /// No description provided for @apparentLabelUnit.
  ///
  /// In en, this message translates to:
  /// **'Feels like\n(°C)'**
  String get apparentLabelUnit;

  /// No description provided for @apparentTemp.
  ///
  /// In en, this message translates to:
  /// **'Apparent Temp.'**
  String get apparentTemp;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Aeroclim'**
  String get appTitle;

  /// No description provided for @avgDeviation.
  ///
  /// In en, this message translates to:
  /// **'Avg. Deviation'**
  String get avgDeviation;

  /// No description provided for @basicInfo.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get basicInfo;

  /// No description provided for @bestMatch.
  ///
  /// In en, this message translates to:
  /// **'Best Match'**
  String get bestMatch;

  /// No description provided for @citiesImported.
  ///
  /// In en, this message translates to:
  /// **'{count} cities imported successfully'**
  String citiesImported(Object count);

  /// No description provided for @climate.
  ///
  /// In en, this message translates to:
  /// **'Climate'**
  String get climate;

  /// No description provided for @climateStation.
  ///
  /// In en, this message translates to:
  /// **'Climate Station'**
  String get climateStation;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @cloudCover.
  ///
  /// In en, this message translates to:
  /// **'Cloud Cover'**
  String get cloudCover;

  /// No description provided for @cloudsLabelUnit.
  ///
  /// In en, this message translates to:
  /// **'Clouds\n(%)'**
  String get cloudsLabelUnit;

  /// No description provided for @comp.
  ///
  /// In en, this message translates to:
  /// **'Comp'**
  String get comp;

  /// No description provided for @coordsHint.
  ///
  /// In en, this message translates to:
  /// **'ex: 49.101, 6.793'**
  String get coordsHint;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @dailyLabel.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get dailyLabel;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @detailsByAltitude.
  ///
  /// In en, this message translates to:
  /// **'Details by Altitude'**
  String get detailsByAltitude;

  /// No description provided for @directionAbbr.
  ///
  /// In en, this message translates to:
  /// **'Dir.'**
  String get directionAbbr;

  /// No description provided for @dMax.
  ///
  /// In en, this message translates to:
  /// **'DMax'**
  String get dMax;

  /// No description provided for @dMin.
  ///
  /// In en, this message translates to:
  /// **'DMin'**
  String get dMin;

  /// No description provided for @disclaimerMessage.
  ///
  /// In en, this message translates to:
  /// **'Data is provided for informational purposes and may differ from actual conditions. The author declines all responsibility for its use.'**
  String get disclaimerMessage;

  /// No description provided for @disclaimerTitle.
  ///
  /// In en, this message translates to:
  /// **'WARNING'**
  String get disclaimerTitle;

  /// No description provided for @displayMode.
  ///
  /// In en, this message translates to:
  /// **'Display Mode'**
  String get displayMode;

  /// No description provided for @enterLocationNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a name for this location'**
  String get enterLocationNameHint;

  /// No description provided for @evening.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get evening;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @exportError.
  ///
  /// In en, this message translates to:
  /// **'Error during export: {error}'**
  String exportError(Object error);

  /// No description provided for @exportNotSupported.
  ///
  /// In en, this message translates to:
  /// **'Export not supported on this platform'**
  String get exportNotSupported;

  /// No description provided for @extendedWind.
  ///
  /// In en, this message translates to:
  /// **'Extended Wind Info'**
  String get extendedWind;

  /// No description provided for @failedToLoadData.
  ///
  /// In en, this message translates to:
  /// **'Error loading data: {error}'**
  String failedToLoadData(Object error);

  /// No description provided for @fillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all fields'**
  String get fillAllFields;

  /// No description provided for @filtersLabel.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filtersLabel;

  /// No description provided for @forecastLocation.
  ///
  /// In en, this message translates to:
  /// **'Forecast Location'**
  String get forecastLocation;

  /// No description provided for @graph.
  ///
  /// In en, this message translates to:
  /// **'Graph'**
  String get graph;

  /// No description provided for @gusts.
  ///
  /// In en, this message translates to:
  /// **'Gusts'**
  String get gusts;

  /// No description provided for @gustsLabelUnit.
  ///
  /// In en, this message translates to:
  /// **'Gusts\n(km/h)'**
  String get gustsLabelUnit;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @hour.
  ///
  /// In en, this message translates to:
  /// **'Hour'**
  String get hour;

  /// No description provided for @hourly.
  ///
  /// In en, this message translates to:
  /// **'Hourly'**
  String get hourly;

  /// No description provided for @hourlyTableNotImplemented.
  ///
  /// In en, this message translates to:
  /// **'Hourly table not implemented'**
  String get hourlyTableNotImplemented;

  /// No description provided for @import.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get import;

  /// No description provided for @importError.
  ///
  /// In en, this message translates to:
  /// **'Error during import: {error}'**
  String importError(Object error);

  /// No description provided for @invalidCoords.
  ///
  /// In en, this message translates to:
  /// **'Invalid coordinates (format: lat, lon)'**
  String get invalidCoords;

  /// No description provided for @kmh.
  ///
  /// In en, this message translates to:
  /// **'km/h'**
  String get kmh;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'LOCATION'**
  String get location;

  /// No description provided for @locationNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Location Name'**
  String get locationNameLabel;

  /// No description provided for @manageCities.
  ///
  /// In en, this message translates to:
  /// **'Manage Cities'**
  String get manageCities;

  /// No description provided for @map.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get map;

  /// No description provided for @max.
  ///
  /// In en, this message translates to:
  /// **'Max'**
  String get max;

  /// No description provided for @maxGusts.
  ///
  /// In en, this message translates to:
  /// **'Max Gusts'**
  String get maxGusts;

  /// No description provided for @maxPrecipProb.
  ///
  /// In en, this message translates to:
  /// **'Max Precip. Prob.'**
  String get maxPrecipProb;

  /// No description provided for @min.
  ///
  /// In en, this message translates to:
  /// **'Min'**
  String get min;

  /// No description provided for @minApparentTemp.
  ///
  /// In en, this message translates to:
  /// **'Min Apparent Temp.'**
  String get minApparentTemp;

  /// No description provided for @model.
  ///
  /// In en, this message translates to:
  /// **'MODEL'**
  String get model;

  /// No description provided for @morning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get morning;

  /// No description provided for @needHelp.
  ///
  /// In en, this message translates to:
  /// **'Need help?'**
  String get needHelp;

  /// No description provided for @night.
  ///
  /// In en, this message translates to:
  /// **'Night'**
  String get night;

  /// No description provided for @noCityError.
  ///
  /// In en, this message translates to:
  /// **'No city registered. Please add one.'**
  String get noCityError;

  /// No description provided for @noCityFound.
  ///
  /// In en, this message translates to:
  /// **'No city found'**
  String get noCityFound;

  /// No description provided for @noCityRegisteredTitle.
  ///
  /// In en, this message translates to:
  /// **'No city registered'**
  String get noCityRegisteredTitle;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noData;

  /// No description provided for @noMatchingHours.
  ///
  /// In en, this message translates to:
  /// **'No hours match the selected criteria'**
  String get noMatchingHours;

  /// No description provided for @normalMax.
  ///
  /// In en, this message translates to:
  /// **'Normal Max'**
  String get normalMax;

  /// No description provided for @normalMin.
  ///
  /// In en, this message translates to:
  /// **'Normal Min'**
  String get normalMin;

  /// No description provided for @period.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get period;

  /// No description provided for @periods.
  ///
  /// In en, this message translates to:
  /// **'Periods'**
  String get periods;

  /// No description provided for @precipChance.
  ///
  /// In en, this message translates to:
  /// **'Precip. Chance'**
  String get precipChance;

  /// No description provided for @precipHours.
  ///
  /// In en, this message translates to:
  /// **'Precip. Hours'**
  String get precipHours;

  /// No description provided for @precipLabelUnit.
  ///
  /// In en, this message translates to:
  /// **'Precip\n(%)'**
  String get precipLabelUnit;

  /// No description provided for @precipProb.
  ///
  /// In en, this message translates to:
  /// **'Precip. (%)'**
  String get precipProb;

  /// No description provided for @precipitation.
  ///
  /// In en, this message translates to:
  /// **'Precipitation'**
  String get precipitation;

  /// No description provided for @previewLabel.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get previewLabel;

  /// No description provided for @privacyInfo.
  ///
  /// In en, this message translates to:
  /// **'Privacy: No cookies or trackers. No data collected.'**
  String get privacyInfo;

  /// No description provided for @readHelp.
  ///
  /// In en, this message translates to:
  /// **'Read Help'**
  String get readHelp;

  /// No description provided for @registeredCities.
  ///
  /// In en, this message translates to:
  /// **'Registered cities:'**
  String get registeredCities;

  /// No description provided for @searchError.
  ///
  /// In en, this message translates to:
  /// **'Search error'**
  String get searchError;

  /// No description provided for @selectLocation.
  ///
  /// In en, this message translates to:
  /// **'Select a location'**
  String get selectLocation;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @showWind.
  ///
  /// In en, this message translates to:
  /// **'Show Wind'**
  String get showWind;

  /// No description provided for @snowfall.
  ///
  /// In en, this message translates to:
  /// **'Snowfall'**
  String get snowfall;

  /// No description provided for @sourceCode.
  ///
  /// In en, this message translates to:
  /// **'Source Code (GitHub)'**
  String get sourceCode;

  /// No description provided for @speed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get speed;

  /// No description provided for @srcCodeGitHub.
  ///
  /// In en, this message translates to:
  /// **'Source Code on GitHub'**
  String get srcCodeGitHub;

  /// No description provided for @sunrise.
  ///
  /// In en, this message translates to:
  /// **'Sunrise'**
  String get sunrise;

  /// No description provided for @sunset.
  ///
  /// In en, this message translates to:
  /// **'Sunset'**
  String get sunset;

  /// No description provided for @table.
  ///
  /// In en, this message translates to:
  /// **'Table'**
  String get table;

  /// No description provided for @tempAvg.
  ///
  /// In en, this message translates to:
  /// **'Avg. Temp.'**
  String get tempAvg;

  /// No description provided for @tempCelsius.
  ///
  /// In en, this message translates to:
  /// **'Temperature (°C)'**
  String get tempCelsius;

  /// No description provided for @tempLabelUnit.
  ///
  /// In en, this message translates to:
  /// **'Temp\n(°C)'**
  String get tempLabelUnit;

  /// No description provided for @tempMax.
  ///
  /// In en, this message translates to:
  /// **'Max. Temp.'**
  String get tempMax;

  /// No description provided for @tempMin.
  ///
  /// In en, this message translates to:
  /// **'Min. Temp.'**
  String get tempMin;

  /// No description provided for @temperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get temperature;

  /// No description provided for @timeMode.
  ///
  /// In en, this message translates to:
  /// **'Time Mode:'**
  String get timeMode;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @viewType.
  ///
  /// In en, this message translates to:
  /// **'View Type:'**
  String get viewType;

  /// No description provided for @wasm.
  ///
  /// In en, this message translates to:
  /// **'Wasm'**
  String get wasm;

  /// No description provided for @weather.
  ///
  /// In en, this message translates to:
  /// **'Weather'**
  String get weather;

  /// No description provided for @wind.
  ///
  /// In en, this message translates to:
  /// **'Wind'**
  String get wind;

  /// No description provided for @windByAltitudeRange.
  ///
  /// In en, this message translates to:
  /// **'Wind by altitude (10m-200m)'**
  String get windByAltitudeRange;

  /// No description provided for @windDirection.
  ///
  /// In en, this message translates to:
  /// **'Wind Direction'**
  String get windDirection;

  /// No description provided for @windSettings.
  ///
  /// In en, this message translates to:
  /// **'WIND SETTINGS'**
  String get windSettings;

  /// No description provided for @windTableFilters.
  ///
  /// In en, this message translates to:
  /// **'Wind Table Filters'**
  String get windTableFilters;

  /// No description provided for @windTableNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Wind Table not available'**
  String get windTableNotAvailable;

  /// No description provided for @helpAndUserManual.
  ///
  /// In en, this message translates to:
  /// **'Help & User Manual'**
  String get helpAndUserManual;

  /// No description provided for @errorLoadingHelp.
  ///
  /// In en, this message translates to:
  /// **'Error loading help: '**
  String get errorLoadingHelp;

  /// No description provided for @noContentFound.
  ///
  /// In en, this message translates to:
  /// **'No content found.'**
  String get noContentFound;

  /// No description provided for @copyUrlIfLinksDoNotWork.
  ///
  /// In en, this message translates to:
  /// **'If links do not work, copy the URL below:'**
  String get copyUrlIfLinksDoNotWork;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'es', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
