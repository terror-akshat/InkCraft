import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing user preferences
class PreferencesService {
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyGridView = 'grid_view';
  static const String _keyDefaultColor = 'default_color';
  static const String _keyFontSize = 'font_size';

  /// Get theme mode (0: system, 1: light, 2: dark)
  Future<int> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyThemeMode) ?? 0;
  }

  /// Set theme mode
  Future<void> setThemeMode(int mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyThemeMode, mode);
  }

  /// Get grid view preference
  Future<bool> getGridView() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyGridView) ?? false;
  }

  /// Set grid view preference
  Future<void> setGridView(bool isGrid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyGridView, isGrid);
  }

  /// Get default note color
  Future<String> getDefaultColor() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyDefaultColor) ?? '#FFFFFF';
  }

  /// Set default note color
  Future<void> setDefaultColor(String color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDefaultColor, color);
  }

  /// Get font size multiplier
  Future<double> getFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyFontSize) ?? 1.0;
  }

  /// Set font size multiplier
  Future<void> setFontSize(double size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyFontSize, size);
  }
}
