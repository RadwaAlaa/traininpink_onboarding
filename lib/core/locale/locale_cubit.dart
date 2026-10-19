import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../storage/key_value_store.dart';

/// Owns the app language. Starts from the saved choice, else the device
/// language (Arabic if the device is Arabic, English otherwise).
class LocaleCubit extends Cubit<Locale> {
  LocaleCubit({required KeyValueStore store, required Locale deviceLocale})
    : _store = store,
      super(_initial(store.getString(_key), deviceLocale));

  static const Locale english = Locale('en');
  static const Locale arabic = Locale('ar');
  static const String _key = 'locale';

  final KeyValueStore _store;

  static Locale _initial(String? saved, Locale device) {
    final code = saved ?? device.languageCode;
    return code == arabic.languageCode ? arabic : english;
  }

  Future<void> toggle() async {
    final next = state == arabic ? english : arabic;
    emit(next);
    await _store.setString(_key, next.languageCode);
  }
}
