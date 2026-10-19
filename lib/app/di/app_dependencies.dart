import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/locale/locale_cubit.dart';
import '../../core/storage/key_value_store.dart';

/// Manual constructor injection: builds every long-lived object once.
class AppDependencies {
  AppDependencies._(this._store, this._deviceLocale);

  final KeyValueStore _store;
  final Locale _deviceLocale;

  static Future<AppDependencies> create({required Locale deviceLocale}) async {
    final prefs = await SharedPreferences.getInstance();
    return AppDependencies._(KeyValueStore(prefs), deviceLocale);
  }

  LocaleCubit createLocaleCubit() =>
      LocaleCubit(store: _store, deviceLocale: _deviceLocale);
}
