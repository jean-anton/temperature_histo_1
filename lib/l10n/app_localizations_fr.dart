// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get accept => 'Accepter';

  @override
  String get addByCityName => 'Nom';

  @override
  String get addByCoordinates => 'Coordonnées';

  @override
  String get addCityHint => 'Tapez le nom d\'une ville...';

  @override
  String get addCityInstruction =>
      'Ajoutez une ville dans le menu \"Gérer les villes\" pour commencer.';

  @override
  String get addThisLocation => 'Ajouter ce lieu';

  @override
  String get afternoon => 'Après-midi';

  @override
  String altitudeTooltip(Object altitude, Object unit, Object value) {
    return '${altitude}m : $value $unit';
  }

  @override
  String get apparent => 'Ressenti';

  @override
  String get apparentLabelUnit => 'Ressenti\n(°C)';

  @override
  String get apparentTemp => 'Temp. ressentie';

  @override
  String get appTitle => 'Aeroclim';

  @override
  String get avgDeviation => 'Écart Moyen';

  @override
  String get basicInfo => 'Information de base';

  @override
  String get bestMatch => 'Meilleur Modèle';

  @override
  String citiesImported(Object count) {
    return '$count villes importées avec succès';
  }

  @override
  String get climate => 'Climat';

  @override
  String get climateStation => 'Station climatique';

  @override
  String get close => 'Fermer';

  @override
  String get cloudCover => 'Couverture nuag.';

  @override
  String get cloudsLabelUnit => 'Nuages\n(%)';

  @override
  String get comp => 'Comp';

  @override
  String get coordsHint => 'ex: 49.101, 6.793';

  @override
  String get daily => 'Quotidien';

  @override
  String get dailyLabel => 'Journalier';

  @override
  String get date => 'Date';

  @override
  String get detailsByAltitude => 'Détails par altitude';

  @override
  String get directionAbbr => 'Dir.';

  @override
  String get dMax => 'DMax';

  @override
  String get dMin => 'DMin';

  @override
  String get disclaimerMessage =>
      'Les données sont fournies à titre informatif et peuvent différer des conditions réelles. L\'auteur décline toute responsabilité quant à leur utilisation.';

  @override
  String get disclaimerTitle => 'AVERTISSEMENT';

  @override
  String get displayMode => 'Mode d\'affichage';

  @override
  String get enterLocationNameHint => 'Entrez un nom pour ce lieu';

  @override
  String get evening => 'Soir';

  @override
  String get export => 'Exporter';

  @override
  String exportError(Object error) {
    return 'Erreur lors de l\'export: $error';
  }

  @override
  String get exportNotSupported => 'Export non supporté sur cette plateforme';

  @override
  String get extendedWind => 'Infos vent étendues';

  @override
  String failedToLoadData(Object error) {
    return 'Erreur lors du chargement des données: $error';
  }

  @override
  String get fillAllFields => 'Veuillez remplir tous les champs';

  @override
  String get filtersLabel => 'Filtres';

  @override
  String get forecastLocation => 'Lieu de prévision';

  @override
  String get graph => 'Graphique';

  @override
  String get gusts => 'Rafales';

  @override
  String get gustsLabelUnit => 'Rafales\n(km/h)';

  @override
  String get home => 'Accueil';

  @override
  String get hour => 'HEURE';

  @override
  String get hourly => 'Horaire';

  @override
  String get hourlyTableNotImplemented => 'Tableau horaire non implémenté';

  @override
  String get import => 'Importer';

  @override
  String importError(Object error) {
    return 'Erreur lors de l\'import: $error';
  }

  @override
  String get invalidCoords => 'Coordonnées invalides (format: lat, lon)';

  @override
  String get kmh => 'km/h';

  @override
  String get location => 'LOCALISATION';

  @override
  String get locationNameLabel => 'Nom du lieu';

  @override
  String get manageCities => 'Gérer les villes';

  @override
  String get map => 'Carte';

  @override
  String get max => 'Max';

  @override
  String get maxGusts => 'Rafales max';

  @override
  String get maxPrecipProb => 'Prob. précip. max';

  @override
  String get min => 'Min';

  @override
  String get minApparentTemp => 'Temp. ress. min';

  @override
  String get model => 'MODÈLE MÉTÉO';

  @override
  String get morning => 'Matin';

  @override
  String get needHelp => 'Besoin d\'aide ?';

  @override
  String get night => 'Nuit';

  @override
  String get noCityError =>
      'Aucune ville enregistrée. Veuillez en ajouter une.';

  @override
  String get noCityFound => 'Aucune ville trouvée';

  @override
  String get noCityRegisteredTitle => 'Aucune ville enregistrée';

  @override
  String get noData => 'Aucune donnée disponible';

  @override
  String get noMatchingHours =>
      'Aucune heure ne répond aux critères sélectionnés';

  @override
  String get normalMax => 'Normale Max';

  @override
  String get normalMin => 'Normale Min';

  @override
  String get period => 'PÉRIODE';

  @override
  String get periods => 'Périodes';

  @override
  String get precipChance => 'Chance de précip.';

  @override
  String get precipHours => 'Heures de précip.';

  @override
  String get precipLabelUnit => 'Précip\n(%)';

  @override
  String get precipProb => 'Précip (%)';

  @override
  String get precipitation => 'Précipitations';

  @override
  String get previewLabel => 'Aperçu';

  @override
  String get privacyInfo =>
      'Confidentialité: Aucun cookie ni tracker. Aucune donnée collectée.';

  @override
  String get readHelp => 'Lire l\'aide';

  @override
  String get registeredCities => 'Villes enregistrées:';

  @override
  String get searchError => 'Erreur lors de la recherche';

  @override
  String get selectLocation => 'Sélectionnez une localisation';

  @override
  String get settings => 'Paramètres';

  @override
  String get showWind => 'Afficher le vent';

  @override
  String get snowfall => 'Chute de neige';

  @override
  String get sourceCode => 'Code Source (GitHub)';

  @override
  String get speed => 'Vitesse';

  @override
  String get srcCodeGitHub => 'Code Source sur GitHub';

  @override
  String get sunrise => 'Lever du soleil';

  @override
  String get sunset => 'Coucher du soleil';

  @override
  String get table => 'Tableau';

  @override
  String get tempAvg => 'Temp. moyenne';

  @override
  String get tempCelsius => 'Température (°C)';

  @override
  String get tempLabelUnit => 'Temp\n(°C)';

  @override
  String get tempMax => 'Temp. max.';

  @override
  String get tempMin => 'Temp. min.';

  @override
  String get temperature => 'Température';

  @override
  String get timeMode => 'Mode temporel:';

  @override
  String get version => 'Version';

  @override
  String get viewType => 'Type de vue:';

  @override
  String get wasm => 'Wasm';

  @override
  String get weather => 'Météo';

  @override
  String get wind => 'Vent';

  @override
  String get windByAltitudeRange => 'Vent par altitude (10m-200m)';

  @override
  String get windDirection => 'Direction vent';

  @override
  String get windSettings => 'PARAMÈTRES VENT';

  @override
  String get windTableFilters => 'Filtres table vent';

  @override
  String get windTableNotAvailable => 'Tableau Vent non disponible';

  @override
  String get helpAndUserManual => 'Aide & Manuel d\'utilisation';

  @override
  String get errorLoadingHelp => 'Erreur lors du chargement de l\'aide : ';

  @override
  String get noContentFound => 'Aucun contenu trouvé.';

  @override
  String get copyUrlIfLinksDoNotWork =>
      'Si les liens ne fonctionnent pas, copiez l\'URL ci-dessous :';
}
