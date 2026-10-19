import 'package:traininpink_onboarding/features/onboarding/domain/entities/flow_config.dart';
import 'package:traininpink_onboarding/features/onboarding/domain/entities/progress.dart';
import 'package:traininpink_onboarding/features/onboarding/domain/repositories/onboarding_repository.dart';

/// In-memory repository: [saved] is what a relaunch would read back.
class FakeOnboardingRepository implements OnboardingRepository {
  FakeOnboardingRepository(this.config, {this.saved});

  /// Null makes [loadFlowConfig] fail, like a broken bundled config.
  final FlowConfig? config;
  Progress? saved;

  @override
  Future<FlowConfig> loadFlowConfig() async =>
      config ?? (throw const FormatException('broken config'));

  @override
  Progress? loadProgress() => saved;

  @override
  Future<void> saveProgress(Progress progress) async => saved = progress;
}
