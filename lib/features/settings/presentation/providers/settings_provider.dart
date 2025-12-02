import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for managing app settings state
class SettingsProvider with ChangeNotifier {
  static const String _kDisplayModeKey = 'displayMode';
  static const String _kShowWindInfoKey = 'showWindInfo';

  // State
  String _displayMode = 'daily';
  bool _showWindInfo = true;
  bool _showChart = true;

  // Getters
  String get displayMode => _displayMode;
  bool get showWindInfo => _showWindInfo;
  bool get showChart => _showChart;

  /// Initialize settings from SharedPreferences
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _displayMode = prefs.getString(_kDisplayModeKey) ?? 'daily';
    _showWindInfo = prefs.getBool(_kShowWindInfoKey) ?? true;
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
}
