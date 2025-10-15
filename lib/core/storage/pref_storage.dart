import 'package:shared_preferences/shared_preferences.dart';

class PrefsStorage {
  final SharedPreferences _prefs;
  PrefsStorage._(this._prefs);

  static Future<PrefsStorage> create() async =>
      PrefsStorage._(await SharedPreferences.getInstance());

  String? getString(String key) => _prefs.getString(key);
  Future<bool> setString(String key, String value) => _prefs.setString(key, value);
}
