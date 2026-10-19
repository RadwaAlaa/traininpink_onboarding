import '../entities/answer.dart';
import '../entities/flow_config.dart';
import '../entities/flow_step.dart';

/// Pure branching logic. Every method recomputes from scratch, so the result
/// depends only on the config and the answers passed in — never on history.
class FlowEngine {
  const FlowEngine(this.config);

  final FlowConfig config;

  /// The steps she will see, in order. A step's `showIf` only sees answers to
  /// steps already on the path, so an answer left over from a skipped step
  /// can never switch a later step on.
  List<FlowStep> resolvePath(Map<String, Answer> answers) {
    final path = <FlowStep>[];
    final pathAnswers = <String, Answer>{};

    for (final step in config.steps) {
      final condition = step.showIf;
      if (condition != null && !condition.evaluate(pathAnswers)) continue;

      path.add(step);
      final answer = answers[step.id];
      if (answer != null) pathAnswers[step.id] = answer;
    }
    return path;
  }

  /// Drops answers to steps that are no longer on [path].
  Map<String, Answer> pruneAnswers(
    List<FlowStep> path,
    Map<String, Answer> answers,
  ) {
    final ids = path.map((step) => step.id).toSet();
    return {
      for (final entry in answers.entries)
        if (ids.contains(entry.key)) entry.key: entry.value,
    };
  }

  /// The step after [currentId] on the freshly resolved path, or null at the
  /// end (or if [currentId] is not on the path).
  FlowStep? next(String currentId, Map<String, Answer> answers) =>
      _neighbour(currentId, answers, 1);

  /// The step before [currentId], or null at the start.
  FlowStep? previous(String currentId, Map<String, Answer> answers) =>
      _neighbour(currentId, answers, -1);

  FlowStep? _neighbour(
    String currentId,
    Map<String, Answer> answers,
    int offset,
  ) {
    final path = resolvePath(answers);
    final index = path.indexWhere((step) => step.id == currentId);
    if (index == -1) return null;

    final target = index + offset;
    return target >= 0 && target < path.length ? path[target] : null;
  }
}
