import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:temperature_histo_1/features/climate/domain/climate_model.dart';

class ClimateRepository {
  // The hardcoded _assetPaths map has been removed from here.

  /// Loads climate normal data from the given asset path.
  Future<List<ClimateNormal>> loadClimateNormals(String assetPath) async {
    if (assetPath.isEmpty) {
      throw ArgumentError('Asset path cannot be empty.');
    }

    try {
      final csvString = await rootBundle.loadString(assetPath);
      return _parseCsvData(csvString);
    } catch (e) {
      throw Exception(
          'Erreur lors du chargement du fichier de données climatiques "$assetPath": $e');
    }
  }

  List<ClimateNormal> _parseCsvData(String csvData) {
    final lines = const LineSplitter().convert(csvData);
    final normals = <ClimateNormal>[];

    for (int i = 1; i < lines.length; i++) { // Skip header
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      try {
        final parts = line.split(';');
        if (parts.length >= 4) {
          normals.add(ClimateNormal.fromCsvRow(parts));
        }
      } catch (e) {
        // Consider using a logger for production apps
        print('Erreur lors du parsing de la ligne $i: $e');
      }
    }

    return normals;
  }

  WeatherDeviation calculateDeviation(
      double forecastMax,
      double forecastMin,
      int dayOfYear,
      List<ClimateNormal> normals,
      ) {
    final normal = ClimateNormal.findByDayOfYear(normals, dayOfYear);

    if (normal == null) {
      return WeatherDeviation(
        maxDeviation: 0,
        minDeviation: 0,
        avgDeviation: 0,
        normal: null,
      );
    }

    final maxDev = forecastMax - normal.temperatureMax;
    final minDev = forecastMin - normal.temperatureMin;
    final avgDev = (maxDev + minDev) / 2;

    return WeatherDeviation(
      maxDeviation: maxDev,
      minDeviation: minDev,
      avgDeviation: avgDev,
      normal: normal,
    );
  }
}