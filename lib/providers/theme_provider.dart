import 'package:flutter/foundation.dart';
import '../services/shared_prefs_service.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkTheme = false;

  bool get isDarkTheme => _isDarkTheme;

  Future<void> loadThemePreference() async {
    _isDarkTheme = await SharedPrefsService.getIsDarkTheme();
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkTheme = !_isDarkTheme;
    await SharedPrefsService.setIsDarkTheme(_isDarkTheme);
    notifyListeners();
  }

  Future<void> setTheme(bool isDark) async {
    _isDarkTheme = isDark;
    await SharedPrefsService.setIsDarkTheme(_isDarkTheme);
    notifyListeners();
  }
}
