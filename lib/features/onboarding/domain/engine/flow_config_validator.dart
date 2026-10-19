import '../entities/condition.dart';
import '../entities/flow_config.dart';
import '../entities/flow_step.dart';
import '../entities/localized_text.dart';

/// Thrown when the bundled config breaks a rule. Lists every problem at once.
class InvalidFlowConfigException implements Exception {
  const InvalidFlowConfigException(this.errors);

  final List<String> errors;

  @override
  String toString() =>
      'InvalidFlowConfigException:\n${errors.map((e) => '- $e').join('\n')}';
}

/// Rules that make "no dead ends, no stale branches" hold by construction.
abstract final class FlowConfigValidator {
  static void validate(FlowConfig config) {
    final errors = findErrors(config);
    if (errors.isNotEmpty) throw InvalidFlowConfigException(errors);
  }

  static List<String> findErrors(FlowConfig config) {
    final errors = <String>[];
    if (config.steps.isEmpty) errors.add('Config has no steps.');

    final earlier = <String, FlowStep>{};
    for (final step in config.steps) {
      if (earlier.containsKey(step.id)) {
        errors.add('Duplicate step id "${step.id}".');
      }
      errors
        ..addAll(_textErrors(step))
        ..addAll(_fieldErrors(step));

      final condition = step.showIf;
      if (condition != null) {
        errors.addAll(_conditionErrors(step.id, condition, earlier));
      }
      earlier[step.id] = step;
    }
    return errors;
  }

  static List<String> _textErrors(FlowStep step) {
    final texts = <String, LocalizedText?>{
      'title': step.title,
      'subtitle': step.subtitle,
      for (final option in step.options) 'option "${option.id}"': option.label,
    };
    return [
      for (final MapEntry(key: field, value: text) in texts.entries)
        if (text != null && text.missingLanguages.isNotEmpty)
          'Step "${step.id}" $field is missing ${text.missingLanguages.join(', ')}.',
    ];
  }

  static List<String> _fieldErrors(FlowStep step) {
    final errors = <String>[];
    void check(bool ok, String problem) {
      if (!ok) errors.add('Step "${step.id}" $problem.');
    }

    final isMulti = step.type == StepType.multiChoice;
    check(
      isMulti || (step.minSelected == null && step.maxSelected == null),
      'sets min/max selected but is not multi choice',
    );
    if (!step.isChoice) {
      check(step.options.isEmpty, 'has options but is not a choice step');
      final maxLength = step.maxLength;
      check(maxLength == null || maxLength > 0, 'has a max length below 1');
      return errors;
    }

    check(step.maxLength == null, 'sets max length on a choice step');
    final ids = step.options.map((o) => o.id).toList();
    check(ids.length >= 2, 'needs at least 2 options');
    check(ids.toSet().length == ids.length, 'has duplicate option ids');

    if (isMulti) {
      final min = step.minSelections;
      final max = step.maxSelected ?? ids.length;
      check(
        min >= 0 && min <= max && max <= ids.length,
        'has invalid min/max selected',
      );
    }
    return errors;
  }

  static List<String> _conditionErrors(
    String stepId,
    Condition condition,
    Map<String, FlowStep> earlier,
  ) {
    final errors = <String>[];
    if (_hasEmptyGroup(condition)) {
      errors.add('Step "$stepId" has an empty all/any condition.');
    }

    for (final leaf in condition.leaves) {
      final target = earlier[leaf.stepId];
      if (target == null) {
        errors.add(
          'Step "$stepId" condition references "${leaf.stepId}", '
          'which is not an earlier step.',
        );
        continue;
      }

      // Free-text answers are never branched on: exact string matching on
      // what she typed is too fragile to drive the flow.
      final validType = switch (leaf) {
        EqCondition() || InCondition() => target.type == StepType.singleChoice,
        ContainsCondition() => target.type == StepType.multiChoice,
      };
      if (!validType) {
        errors.add(
          'Step "$stepId" uses ${leaf.runtimeType} on "${target.id}" '
          '(${target.type.name}).',
        );
      }

      if (leaf.values.isEmpty) {
        errors.add('Step "$stepId" has an "in" condition with no values.');
      }

      final optionIds = target.options.map((o) => o.id).toSet();
      for (final value in leaf.values.where((v) => !optionIds.contains(v))) {
        errors.add(
          'Step "$stepId" condition references unknown option '
          '"$value" of "${target.id}".',
        );
      }
    }
    return errors;
  }

  static bool _hasEmptyGroup(Condition condition) => switch (condition) {
    AllCondition(:final children) || AnyCondition(:final children) =>
      children.isEmpty || children.any(_hasEmptyGroup),
    NotCondition(:final child) => _hasEmptyGroup(child),
    AnswerCondition() => false,
  };
}
