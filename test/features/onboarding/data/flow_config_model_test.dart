import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:traininpink_onboarding/features/onboarding/data/datasources/flow_config_local_data_source.dart';
import 'package:traininpink_onboarding/features/onboarding/data/models/condition_model.dart';
import 'package:traininpink_onboarding/features/onboarding/data/models/step_model.dart';
import 'package:traininpink_onboarding/features/onboarding/domain/engine/flow_engine.dart';
import 'package:traininpink_onboarding/features/onboarding/domain/entities/answer.dart';
import 'package:traininpink_onboarding/features/onboarding/domain/entities/condition.dart';
import 'package:traininpink_onboarding/features/onboarding/domain/entities/flow_step.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Condition condition(Map<String, dynamic> json) =>
      ConditionModel.fromJson(json).toEntity();

  group('bundled onboarding_flow.json', () {
    test('branches on get_back_into_it', () async {
      final model = await FlowConfigLocalDataSource(rootBundle).load();
      final engine = FlowEngine(model.toEntity());
      List<String> pathIds(Map<String, Answer> answers) =>
          engine.resolvePath(answers).map((s) => s.id).toList();

      expect(
        pathIds({'goal': const SingleChoiceAnswer('get_back_into_it')}),
        allOf(contains('last_trained'), isNot(contains('experience'))),
      );
      expect(
        pathIds({'goal': const SingleChoiceAnswer('build_strength')}),
        allOf(contains('experience'), isNot(contains('last_trained'))),
      );
    });
  });

  group('show_if parsing', () {
    test('maps every operator to its condition', () {
      expect(
        condition({
          'all': [
            {
              'eq': ['goal', 'tone_up'],
            },
            {
              'not': {
                'contains': ['focus_areas', 'core'],
              },
            },
            {
              'any': [
                {
                  'in': [
                    'experience',
                    ['beginner', 'advanced'],
                  ],
                },
              ],
            },
          ],
        }),
        const AllCondition([
          EqCondition('goal', 'tone_up'),
          NotCondition(ContainsCondition('focus_areas', 'core')),
          AnyCondition([
            InCondition('experience', ['beginner', 'advanced']),
          ]),
        ]),
      );
    });

    test('rejects more than one operator', () {
      expect(
        () => condition({
          'eq': ['goal', 'tone_up'],
          'contains': ['focus_areas', 'core'],
        }),
        throwsFormatException,
      );
    });

    test('rejects operators in the wrong shape', () {
      expect(
        () => condition({
          'eq': ['goal'],
        }),
        throwsFormatException,
      );
      expect(
        () => condition({
          'in': ['goal', 'tone_up'],
        }),
        throwsFormatException,
      );
      expect(() => condition({}), throwsFormatException);
    });
  });

  group('step parsing', () {
    Map<String, dynamic> stepJson(Map<String, dynamic> extra) => {
      'id': 'name',
      'type': 'text',
      'title': {'en': 'Name', 'ar': 'الاسم'},
      ...extra,
    };

    test('reads snake_case fields and defaults required to true', () {
      final step = StepModel.fromJson(stepJson({'max_length': 40})).toEntity();

      expect(step.type, StepType.text);
      expect(step.maxLength, 40);
      expect(step.required, isTrue);
    });

    test('rejects an unknown step type', () {
      expect(
        () => StepModel.fromJson(stepJson({'type': 'slider'})).toEntity(),
        throwsFormatException,
      );
    });

    test('names the step when its show_if is invalid', () {
      final json = stepJson({
        'show_if': {
          'eq': ['goal'],
        },
      });

      expect(
        () => StepModel.fromJson(json).toEntity(),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            startsWith('Step "name"'),
          ),
        ),
      );
    });

    test('fails loudly on a missing or mistyped field', () {
      expect(
        () => StepModel.fromJson({'id': 'name', 'type': 'text'}),
        throwsA(isA<CheckedFromJsonException>()),
      );
      expect(
        () => StepModel.fromJson(stepJson({'max_length': '40'})),
        throwsA(isA<CheckedFromJsonException>()),
      );
    });
  });
}
