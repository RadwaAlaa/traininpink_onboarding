import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/locale/locale_cubit.dart';
import '../../core/storage/key_value_store.dart';
import '../../features/onboarding/data/datasources/flow_config_local_data_source.dart';
import '../../features/onboarding/data/datasources/progress_local_data_source.dart';
import '../../features/onboarding/data/repositories/onboarding_repository_impl.dart';
import '../../features/onboarding/presentation/cubit/onboarding_cubit.dart';

/// Manual constructor injection: builds every long-lived object once.
class AppDependencies {
  AppDependencies._(this._store, this._deviceLocale, this.onboardingCubit);

  final KeyValueStore _store;
  final Locale _deviceLocale;

  /// Loaded before the first frame, so the app can open straight on the step
  /// she left off at. Lives as long as the app.
  final OnboardingCubit onboardingCubit;

  /// [assets] defaults to the app bundle; widget tests pass their own.
  static Future<AppDependencies> create({
    required Locale deviceLocale,
    AssetBundle? assets,
  }) async {
    final store = KeyValueStore(await SharedPreferences.getInstance());
    final onboardingCubit = OnboardingCubit(
      OnboardingRepositoryImpl(
        flowConfigSource: FlowConfigLocalDataSource(assets ?? rootBundle),
        progressSource: ProgressLocalDataSource(store),
      ),
    );
    await onboardingCubit.load();
    return AppDependencies._(store, deviceLocale, onboardingCubit);
  }

  LocaleCubit createLocaleCubit() =>
      LocaleCubit(store: _store, deviceLocale: _deviceLocale);
}
