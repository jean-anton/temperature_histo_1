// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get accept => 'Aceptar';

  @override
  String get addByCityName => 'Nombre';

  @override
  String get addByCoordinates => 'Coordenadas';

  @override
  String get addCityHint => 'Escriba el nombre de una ciudad...';

  @override
  String get addCityInstruction =>
      'Añada una ciudad en el menú \"Gestionar ciudades\" para comenzar.';

  @override
  String get addThisLocation => 'Añadir esta ubicación';

  @override
  String get afternoon => 'Tarde';

  @override
  String altitudeTooltip(Object altitude, Object unit, Object value) {
    return '${altitude}m: $value $unit';
  }

  @override
  String get apparent => 'Sensación';

  @override
  String get apparentLabelUnit => 'Sensación\n(°C)';

  @override
  String get apparentTemp => 'Temp. aparente';

  @override
  String get appTitle => 'Aeroclim';

  @override
  String get avgDeviation => 'Desviación media';

  @override
  String get basicInfo => 'Información básica';

  @override
  String get bestMatch => 'Mejor ajuste';

  @override
  String citiesImported(Object count) {
    return '$count ciudades importadas con éxito';
  }

  @override
  String get climate => 'Clima';

  @override
  String get climateStation => 'Estación climática';

  @override
  String get close => 'Cerrar';

  @override
  String get cloudCover => 'Cobertura de nubes';

  @override
  String get cloudsLabelUnit => 'Nubes\n(%)';

  @override
  String get comp => 'Comp';

  @override
  String get coordsHint => 'ej: 49.101, 6.793';

  @override
  String get daily => 'Diario';

  @override
  String get dailyLabel => 'Diario';

  @override
  String get date => 'Fecha';

  @override
  String get detailsByAltitude => 'Detalles por altitud';

  @override
  String get directionAbbr => 'Dir.';

  @override
  String get dMax => 'DMáx';

  @override
  String get dMin => 'DMín';

  @override
  String get disclaimerMessage =>
      'Los datos se proporcionan con fines informativos y pueden diferir de las condiciones reales. El autor declina toda responsabilidad por su uso.';

  @override
  String get disclaimerTitle => 'ADVERTENCIA';

  @override
  String get displayMode => 'Modo de visualización';

  @override
  String get enterLocationNameHint =>
      'Introduzca un nombre para esta ubicación';

  @override
  String get evening => 'Tarde/Noche';

  @override
  String get export => 'Exportar';

  @override
  String exportError(Object error) {
    return 'Error durante la exportación: $error';
  }

  @override
  String get exportNotSupported =>
      'Exportación no soportada en esta plataforma';

  @override
  String get extendedWind => 'Info de viento extendida';

  @override
  String failedToLoadData(Object error) {
    return 'Error al cargar los datos: $error';
  }

  @override
  String get fillAllFields => 'Por favor, rellene todos los campos';

  @override
  String get filtersLabel => 'Filtros';

  @override
  String get forecastLocation => 'Ubicación del pronóstico';

  @override
  String get graph => 'Gráfico';

  @override
  String get gusts => 'Ráfagas';

  @override
  String get gustsLabelUnit => 'Ráfagas\n(km/h)';

  @override
  String get home => 'Inicio';

  @override
  String get hour => 'Hora';

  @override
  String get hourly => 'Por horas';

  @override
  String get hourlyTableNotImplemented => 'Tabla por horas no implementada';

  @override
  String get import => 'Importar';

  @override
  String importError(Object error) {
    return 'Error durante la importación: $error';
  }

  @override
  String get invalidCoords => 'Coordenadas inválidas (formato: lat, lon)';

  @override
  String get kmh => 'km/h';

  @override
  String get location => 'UBICACIÓN';

  @override
  String get locationNameLabel => 'Nombre de la ubicación';

  @override
  String get manageCities => 'Gestionar ciudades';

  @override
  String get map => 'Mapa';

  @override
  String get max => 'Máx';

  @override
  String get maxGusts => 'Ráfagas máx.';

  @override
  String get maxPrecipProb => 'Prob. precip. máx.';

  @override
  String get min => 'Mín';

  @override
  String get minApparentTemp => 'Temp. aparente mín.';

  @override
  String get model => 'MODELO METEO';

  @override
  String get morning => 'Mañana';

  @override
  String get needHelp => '¿Necesita ayuda?';

  @override
  String get night => 'Noche';

  @override
  String get noCityError => 'Ninguna ciudad registrada. Por favor, añada una.';

  @override
  String get noCityFound => 'No se ha encontrado ninguna ciudad';

  @override
  String get noCityRegisteredTitle => 'Ninguna ciudad registrada';

  @override
  String get noData => 'No hay datos disponibles';

  @override
  String get noMatchingHours =>
      'No hay horas que coincidan con los criterios seleccionados';

  @override
  String get normalMax => 'Máx Normal';

  @override
  String get normalMin => 'Mín Normal';

  @override
  String get period => 'Periodo';

  @override
  String get periods => 'Periodos';

  @override
  String get precipChance => 'Prob. de precip.';

  @override
  String get precipHours => 'Horas de precip.';

  @override
  String get precipLabelUnit => 'Precip\n(%)';

  @override
  String get precipProb => 'Precip. (%)';

  @override
  String get precipitation => 'Precipitación';

  @override
  String get previewLabel => 'Vista previa';

  @override
  String get privacyInfo =>
      'Privacidad: Sin cookies ni rastreadores. No se recogen datos.';

  @override
  String get readHelp => 'Leer ayuda';

  @override
  String get registeredCities => 'Ciudades registradas:';

  @override
  String get searchError => 'Error de búsqueda';

  @override
  String get selectLocation => 'Seleccionar una ubicación';

  @override
  String get settings => 'Ajustes';

  @override
  String get showWind => 'Mostrar viento';

  @override
  String get snowfall => 'Nevada';

  @override
  String get sourceCode => 'Código fuente (GitHub)';

  @override
  String get speed => 'Velocidad';

  @override
  String get srcCodeGitHub => 'Código fuente en GitHub';

  @override
  String get sunrise => 'Amanecer';

  @override
  String get sunset => 'Atardecer';

  @override
  String get table => 'Tabla';

  @override
  String get tempAvg => 'Temp. media';

  @override
  String get tempCelsius => 'Temperatura (°C)';

  @override
  String get tempLabelUnit => 'Temp\n(°C)';

  @override
  String get tempMax => 'Temp. máx.';

  @override
  String get tempMin => 'Temp. mín.';

  @override
  String get temperature => 'Temperatura';

  @override
  String get timeMode => 'Modo de tiempo:';

  @override
  String get version => 'Versión';

  @override
  String get viewType => 'Tipo de vista:';

  @override
  String get wasm => 'Wasm';

  @override
  String get weather => 'Tiempo';

  @override
  String get wind => 'Viento';

  @override
  String get windByAltitudeRange => 'Viento por altitud (10m-200m)';

  @override
  String get windDirection => 'Wind Direction';

  @override
  String get windSettings => 'AJUSTES DE VIENTO';

  @override
  String get windTableFilters => 'Filtros de tabla de viento';

  @override
  String get windTableNotAvailable => 'Tabla de viento no disponible';

  @override
  String get helpAndUserManual => 'Ayuda y Manual de Usuario';

  @override
  String get errorLoadingHelp => 'Error al cargar la ayuda: ';

  @override
  String get noContentFound => 'No se encontró contenido.';

  @override
  String get copyUrlIfLinksDoNotWork =>
      'Si los enlaces no funcionan, copie la siguiente URL:';
}
