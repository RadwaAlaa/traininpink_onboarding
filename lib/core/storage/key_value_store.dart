import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper so nothing outside `core/storage` touches SharedPreferences.
class KeyValueStore {
  const KeyValueStore(this._prefs);

  final SharedPreferences _prefs;

  String? getString(String key) => _prefs.getString(key);

  Future<void> setString(String key, String value) =>
      _prefs.setString(key, value);
}
