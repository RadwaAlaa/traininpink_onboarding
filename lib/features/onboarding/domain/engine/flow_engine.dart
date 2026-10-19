import '../entities/answer.dart';
import '../entities/flow_config.dart';
import '../entities/flow_step.dart';
import '../entities/progress.dart';

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

  /// Saved progress made safe for this config, or null if it was saved
  /// against another version. Answers off the path are dropped, a saved step
  /// that is no longer on the path restarts her at the first step, and the
  /// summary only reopens if every step on the path is answered.
  Progress? restore(Progress saved) {
    if (saved.flowVersion != config.version) return null;

    final path = resolvePath(saved.answers);
    final onPath = path.any((step) => step.id == saved.currentStepId);
    final answers = pruneAnswers(path, saved.answers);
    // Reopen the summary only if every question on the path is still answered.
    final complete = path.every((step) => step.isComplete(answers[step.id]));
    // A validated config's first step has no show_if, so the path is never
    // empty.
    return Progress(
      flowVersion: saved.flowVersion,
      currentStepId: onPath ? saved.currentStepId : path.first.id,
      answers: answers,
      reachedSummary: saved.reachedSummary && onPath && complete,
    );
  }

  /// The step after [currentId] on [path], or null at the end (or if
  /// [currentId] is not on [path]). Pass the freshly resolved path.
  FlowStep? next(List<FlowStep> path, String currentId) =>
      _neighbour(path, currentId, 1);

  /// The step before [currentId] on [path], or null at the start.
  FlowStep? previous(List<FlowStep> path, String currentId) =>
      _neighbour(path, currentId, -1);

  FlowStep? _neighbour(List<FlowStep> path, String currentId, int offset) {
    final index = path.indexWhere((step) => step.id == currentId);
    if (index == -1) return null;

    final target = index + offset;
    return target >= 0 && target < path.length ? path[target] : null;
  }
}
