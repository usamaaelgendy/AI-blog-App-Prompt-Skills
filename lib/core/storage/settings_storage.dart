import 'package:shared_preferences/shared_preferences.dart';

class SettingsStorage {
  final SharedPreferences _prefs;

  SettingsStorage(this._prefs);

  String getLanguage() => _prefs.getString('language') ?? 'ar';
  Future<void> setLanguage(String lang) => _prefs.setString('language', lang);
}
