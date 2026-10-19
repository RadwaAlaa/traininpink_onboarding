import '../entities/flow_config.dart';
import '../entities/progress.dart';

abstract interface class OnboardingRepository {
  /// The bundled flow, already validated. Throws if the config is invalid.
  Future<FlowConfig> loadFlowConfig();

  /// Saved progress as stored, or null if there is none or it can't be read.
  /// Pass it through `FlowEngine.restore` before use.
  Progress? loadProgress();

  Future<void> saveProgress(Progress progress);
}
