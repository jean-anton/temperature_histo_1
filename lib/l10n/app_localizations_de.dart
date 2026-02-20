// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get accept => 'Akzeptieren';

  @override
  String get addByCityName => 'Name';

  @override
  String get addByCoordinates => 'Koordinaten';

  @override
  String get addCityHint => 'Stadtname eingeben...';

  @override
  String get addCityInstruction =>
      'Fügen Sie eine Stadt im Menü \"Städte verwalten\" hinzu, um zu beginnen.';

  @override
  String get addThisLocation => 'Standort hinzufügen';

  @override
  String get afternoon => 'Nachmittag';

  @override
  String altitudeTooltip(Object altitude, Object unit, Object value) {
    return '${altitude}m: $value $unit';
  }

  @override
  String get apparent => 'Gefühlt wie';

  @override
  String get apparentLabelUnit => 'Gefühlt\n(°C)';

  @override
  String get apparentTemp => 'Gefühlte Temp.';

  @override
  String get appTitle => 'Aeroclim';

  @override
  String get avgDeviation => 'Mittl. Abweichung';

  @override
  String get basicInfo => 'Basis-Informationen';

  @override
  String get bestMatch => 'Beste Übereinstimmung';

  @override
  String citiesImported(Object count) {
    return '$count Städte erfolgreich importiert';
  }

  @override
  String get climate => 'Klima';

  @override
  String get climateStation => 'Klimastation';

  @override
  String get close => 'Schließen';

  @override
  String get cloudCover => 'Bewölkung';

  @override
  String get cloudsLabelUnit => 'Wolken\n(%)';

  @override
  String get comp => 'Vergleich';

  @override
  String get coordsHint => 'z.B. 49.101, 6.793';

  @override
  String get daily => 'Täglich';

  @override
  String get dailyLabel => 'Täglich';

  @override
  String get date => 'Datum';

  @override
  String get detailsByAltitude => 'Details nach Höhe';

  @override
  String get directionAbbr => 'Dir.';

  @override
  String get dMax => 'DMax';

  @override
  String get dMin => 'DMin';

  @override
  String get disclaimerMessage =>
      'Daten dienen der Information und können von tatsächlichen Bedingungen abweichen. Der Autor lehnt jede Haftung für ihre Verwendung ab.';

  @override
  String get disclaimerTitle => 'WARNUNG';

  @override
  String get displayMode => 'Anzeige-Modus';

  @override
  String get enterLocationNameHint => 'Namen für diesen Standort eingeben';

  @override
  String get evening => 'Abend';

  @override
  String get export => 'Exportieren';

  @override
  String exportError(Object error) {
    return 'Fehler beim Export: $error';
  }

  @override
  String get exportNotSupported =>
      'Export auf dieser Plattform nicht unterstützt';

  @override
  String get extendedWind => 'Erweiterte Wind-Infos';

  @override
  String failedToLoadData(Object error) {
    return 'Fehler beim Laden der Daten: $error';
  }

  @override
  String get fillAllFields => 'Bitte alle Felder ausfüllen';

  @override
  String get filtersLabel => 'Filter';

  @override
  String get forecastLocation => 'Vorhersage-Standort';

  @override
  String get graph => 'Grafik';

  @override
  String get gusts => 'Böen';

  @override
  String get gustsLabelUnit => 'Böen\n(km/h)';

  @override
  String get home => 'Home';

  @override
  String get hour => 'Stunde';

  @override
  String get hourly => 'Stündlich';

  @override
  String get hourlyTableNotImplemented =>
      'Stündliche Tabelle nicht implementiert';

  @override
  String get import => 'Importieren';

  @override
  String importError(Object error) {
    return 'Fehler beim Import: $error';
  }

  @override
  String get invalidCoords =>
      'Ungültige Koordinaten (Format: Breitengrad, Längengrad)';

  @override
  String get kmh => 'km/h';

  @override
  String get location => 'STANDORT';

  @override
  String get locationNameLabel => 'Standortname';

  @override
  String get manageCities => 'Städte verwalten';

  @override
  String get map => 'Karte';

  @override
  String get max => 'Max';

  @override
  String get maxGusts => 'Maximale Böen';

  @override
  String get maxPrecipProb => 'Max. Niederschlagswahrsch.';

  @override
  String get min => 'Min';

  @override
  String get minApparentTemp => 'Min. gefühlte Temp.';

  @override
  String get model => 'WETTERMODELL';

  @override
  String get morning => 'Morgen';

  @override
  String get needHelp => 'Hilfe benötigt?';

  @override
  String get night => 'Nacht';

  @override
  String get noCityError =>
      'Keine Stadt registriert. Bitte fügen Sie eine hinzu.';

  @override
  String get noCityFound => 'Keine Stadt gefunden';

  @override
  String get noCityRegisteredTitle => 'Keine Stadt registriert';

  @override
  String get noData => 'Keine Daten verfügbar';

  @override
  String get noMatchingHours =>
      'Keine Stunden entsprechen den ausgewählten Kriterien';

  @override
  String get normalMax => 'Normal Max';

  @override
  String get normalMin => 'Normal Min';

  @override
  String get period => 'Zeitraum';

  @override
  String get periods => 'Zeiträume';

  @override
  String get precipChance => 'Niederschlagswahrsch.';

  @override
  String get precipHours => 'Niederschlagsstunden';

  @override
  String get precipLabelUnit => 'Niederschl.\n(%)';

  @override
  String get precipProb => 'Niederschlag (%)';

  @override
  String get precipitation => 'Niederschlag';

  @override
  String get previewLabel => 'Vorschau';

  @override
  String get privacyInfo =>
      'Datenschutz: Keine Cookies oder Tracker. Keine Datenerfassung.';

  @override
  String get readHelp => 'Hilfe lesen';

  @override
  String get registeredCities => 'Registrierte Städte:';

  @override
  String get searchError => 'Suchfehler';

  @override
  String get selectLocation => 'Standort wählen';

  @override
  String get settings => 'Einstellungen';

  @override
  String get showWind => 'Wind anzeigen';

  @override
  String get snowfall => 'Schneefall';

  @override
  String get sourceCode => 'Quellcode (GitHub)';

  @override
  String get speed => 'Geschwindigkeit';

  @override
  String get srcCodeGitHub => 'Quellcode auf GitHub';

  @override
  String get sunrise => 'Sonnenaufgang';

  @override
  String get sunset => 'Sonnenuntergang';

  @override
  String get table => 'Tabelle';

  @override
  String get tempAvg => 'Mittlere Temp.';

  @override
  String get tempCelsius => 'Temperatur (°C)';

  @override
  String get tempLabelUnit => 'Temp\n(°C)';

  @override
  String get tempMax => 'Max. Temp.';

  @override
  String get tempMin => 'Min. Temp.';

  @override
  String get temperature => 'Temperatur';

  @override
  String get timeMode => 'Zeitraum:';

  @override
  String get version => 'Version';

  @override
  String get viewType => 'Ansichtstyp:';

  @override
  String get wasm => 'Wasm';

  @override
  String get weather => 'Wetter';

  @override
  String get wind => 'Wind';

  @override
  String get windByAltitudeRange => 'Wind nach Höhe (10m-200m)';

  @override
  String get windDirection => 'Windrichtung';

  @override
  String get windSettings => 'WINDEINSTELLUNGEN';

  @override
  String get windTableFilters => 'Wind-Tabellen-Filter';

  @override
  String get windTableNotAvailable => 'Wind-Tabelle nicht verfügbar';

  @override
  String get helpAndUserManual => 'Hilfe & Benutzerhandbuch';

  @override
  String get errorLoadingHelp => 'Fehler beim Laden der Hilfe: ';

  @override
  String get noContentFound => 'Kein Inhalt gefunden.';

  @override
  String get copyUrlIfLinksDoNotWork =>
      'Wenn Links nicht funktionieren, kopieren Sie die folgende URL:';

  @override
  String get weatherDesc0 => 'Klarer Himmel';

  @override
  String get weatherDesc1 => 'Überwiegend klar';

  @override
  String get weatherDesc2 => 'Teilweise bewölkt';

  @override
  String get weatherDesc3 => 'Bedeckt';

  @override
  String get weatherDesc45 => 'Nebel';

  @override
  String get weatherDesc48 => 'Raureifnebel';

  @override
  String get weatherDesc51 => 'Leichter Nieselregen';

  @override
  String get weatherDesc53 => 'Mäßiger Nieselregen';

  @override
  String get weatherDesc55 => 'Dichter Nieselregen';

  @override
  String get weatherDesc56 => 'Leichter gefrierender Nieselregen';

  @override
  String get weatherDesc57 => 'Dichter gefrierender Nieselregen';

  @override
  String get weatherDesc61 => 'Leichter Regen';

  @override
  String get weatherDesc63 => 'Mäßiger Regen';

  @override
  String get weatherDesc65 => 'Starker Regen';

  @override
  String get weatherDesc66 => 'Gefrierender Regen';

  @override
  String get weatherDesc67 => 'Starker gefrierender Regen';

  @override
  String get weatherDesc71 => 'Leichter Schneefall';

  @override
  String get weatherDesc73 => 'Mäßiger Schneefall';

  @override
  String get weatherDesc75 => 'Starker Schneefall';

  @override
  String get weatherDesc77 => 'Schneegriesel';

  @override
  String get weatherDesc80 => 'Leichte Regenschauer';

  @override
  String get weatherDesc81 => 'Mäßige Regenschauer';

  @override
  String get weatherDesc82 => 'Heftige Regenschauer';

  @override
  String get weatherDesc85 => 'Leichte Schneeschauer';

  @override
  String get weatherDesc86 => 'Starke Schneeschauer';

  @override
  String get weatherDesc95 => 'Gewitter';

  @override
  String get weatherDesc96 => 'Gewitter mit leichtem Hagel';

  @override
  String get weatherDesc99 => 'Gewitter mit starkem Hagel';
}
