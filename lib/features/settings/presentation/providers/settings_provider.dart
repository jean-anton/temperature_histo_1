import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for managing app settings state
class SettingsProvider with ChangeNotifier {
  static const String _kDisplayModeKey = 'displayMode';
  static const String _kShowWindInfoKey = 'showWindInfo';
  static const String _kMaxGustSpeedKey = 'maxGustSpeed';
  static const String _kMaxPrecipitationProbabilityKey =
      'maxPrecipitationProbability';

  // State
  String _displayMode = 'daily';
  bool _showWindInfo = true;
  bool _showChart = true;
  double _maxGustSpeed = 30.0;
  int _maxPrecipitationProbability = 20;

  // Getters
  String get displayMode => _displayMode;
  bool get showWindInfo => _showWindInfo;
  bool get showChart => _showChart;
  double get maxGustSpeed => _maxGustSpeed;
  int get maxPrecipitationProbability => _maxPrecipitationProbability;

  /// Initialize settings from SharedPreferences
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _displayMode = prefs.getString(_kDisplayModeKey) ?? 'daily';
    _showWindInfo = prefs.getBool(_kShowWindInfoKey) ?? true;
    _maxGustSpeed = prefs.getDouble(_kMaxGustSpeedKey) ?? 30.0;
    _maxPrecipitationProbability =
        prefs.getInt(_kMaxPrecipitationProbabilityKey) ?? 20;
    notifyListeners();
  }

  /// Set display mode (daily or hourly)
  Future<void> setDisplayMode(String mode) async {
    if (_displayMode != mode) {
      _displayMode = mode;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kDisplayModeKey, mode);
      notifyListeners();
    }
  }

  /// Toggle wind info display
  Future<void> toggleWindInfo() async {
    _showWindInfo = !_showWindInfo;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kShowWindInfoKey, _showWindInfo);
    notifyListeners();
  }

  /// Toggle chart display
  void toggleChart() {
    _showChart = !_showChart;
    notifyListeners();
  }

  /// Set maximum gust speed threshold for ventTable
  Future<void> setMaxGustSpeed(double speed) async {
    if (_maxGustSpeed != speed) {
      _maxGustSpeed = speed;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_kMaxGustSpeedKey, speed);
      notifyListeners();
    }
  }

  /// Set maximum precipitation probability threshold for ventTable
  Future<void> setMaxPrecipitationProbability(int probability) async {
    if (_maxPrecipitationProbability != probability) {
      _maxPrecipitationProbability = probability;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_kMaxPrecipitationProbabilityKey, probability);
      notifyListeners();
    }
  }
}
