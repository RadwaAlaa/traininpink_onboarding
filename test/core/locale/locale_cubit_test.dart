import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:traininpink_onboarding/core/locale/locale_cubit.dart';
import 'package:traininpink_onboarding/core/storage/key_value_store.dart';

void main() {
  Future<KeyValueStore> storeWith(Map<String, Object> values) async {
    SharedPreferences.setMockInitialValues(values);
    return KeyValueStore(await SharedPreferences.getInstance());
  }

  test('starts in Arabic on an Arabic device', () async {
    final cubit = LocaleCubit(
      store: await storeWith({}),
      deviceLocale: const Locale('ar', 'EG'),
    );

    expect(cubit.state, LocaleCubit.arabic);
  });

  test('falls back to English for unsupported device languages', () async {
    final cubit = LocaleCubit(
      store: await storeWith({}),
      deviceLocale: const Locale('fr'),
    );

    expect(cubit.state, LocaleCubit.english);
  });

  test('saved choice wins over the device language', () async {
    final cubit = LocaleCubit(
      store: await storeWith({'locale': 'ar'}),
      deviceLocale: const Locale('en'),
    );

    expect(cubit.state, LocaleCubit.arabic);
  });

  test('toggle switches language and persists it', () async {
    final store = await storeWith({});
    final cubit = LocaleCubit(store: store, deviceLocale: const Locale('en'));

    await cubit.toggle();

    expect(cubit.state, LocaleCubit.arabic);
    final restored = LocaleCubit(
      store: store,
      deviceLocale: const Locale('en'),
    );
    expect(restored.state, LocaleCubit.arabic);
  });
}
