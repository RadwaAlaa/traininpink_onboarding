import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:traininpink_onboarding/core/storage/key_value_store.dart';
import 'package:traininpink_onboarding/features/onboarding/data/datasources/flow_config_local_data_source.dart';
import 'package:traininpink_onboarding/features/onboarding/data/datasources/progress_local_data_source.dart';
import 'package:traininpink_onboarding/features/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'package:traininpink_onboarding/features/onboarding/domain/engine/flow_config_validator.dart';
import 'package:traininpink_onboarding/features/onboarding/domain/entities/answer.dart';
import 'package:traininpink_onboarding/features/onboarding/domain/entities/progress.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<OnboardingRepositoryImpl> repositoryWith(
    Map<String, Object> saved, {
    AssetBundle? bundle,
  }) async {
    SharedPreferences.setMockInitialValues(saved);
    final store = KeyValueStore(await SharedPreferences.getInstance());
    return OnboardingRepositoryImpl(
      flowConfigSource: FlowConfigLocalDataSource(bundle ?? rootBundle),
      progressSource: ProgressLocalDataSource(store),
    );
  }

  final progress = Progress(
    flowVersion: 1,
    currentStepId: 'name',
    answers: {
      'goal': const SingleChoiceAnswer('get_back_into_it'),
      'focus_areas': MultiChoiceAnswer({'core', 'arms_back'}),
      'pain_notes': const TextAnswer('Worse after sitting'),
    },
  );

  test('loads the bundled config, validated', () async {
    final repository = await repositoryWith({});
    final config = await repository.loadFlowConfig();

    expect(config.steps.first.id, 'goal');
  });

  test('rejects a config that fails validation', () async {
    final repository = await repositoryWith(
      {},
      bundle: _StringBundle(
        '{"version": 1, "steps": [], '
        '"summary": {"headlines": [], "lines": []}, '
        '"paywall": {"plans": []}}',
      ),
    );

    expect(
      repository.loadFlowConfig(),
      throwsA(isA<InvalidFlowConfigException>()),
    );
  });

  test('progress round-trips through storage', () async {
    final repository = await repositoryWith({});
    await repository.saveProgress(progress);

    expect(repository.loadProgress(), progress);
  });

  test('missing or unreadable progress starts fresh', () async {
    expect((await repositoryWith({})).loadProgress(), isNull);

    for (final corrupt in [
      'not json',
      '[]',
      'null',
      '{"flow_version": "1"}',
      '{}',
    ]) {
      final repository = await repositoryWith({'onboarding_progress': corrupt});
      expect(repository.loadProgress(), isNull, reason: corrupt);
    }
  });

  test('an answer saved with no value, or two, starts fresh', () async {
    for (final answer in ['{}', '{"option_id": "a", "text": "b"}']) {
      final repository = await repositoryWith({
        'onboarding_progress':
            '{"flow_version": 1, "current_step_id": "goal", '
            '"answers": {"goal": $answer}}',
      });

      expect(repository.loadProgress(), isNull, reason: answer);
    }
  });
}

/// Serves one config string in place of the bundled asset.
class _StringBundle extends CachingAssetBundle {
  _StringBundle(this._json);

  final String _json;

  @override
  Future<String> loadString(String key, {bool cache = true}) async => _json;

  @override
  Future<ByteData> load(String key) => throw UnimplementedError();
}
