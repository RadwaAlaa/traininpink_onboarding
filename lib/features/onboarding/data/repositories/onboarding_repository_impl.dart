import 'package:json_annotation/json_annotation.dart';

import '../../domain/engine/flow_config_validator.dart';
import '../../domain/entities/flow_config.dart';
import '../../domain/entities/progress.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../datasources/flow_config_local_data_source.dart';
import '../datasources/progress_local_data_source.dart';
import '../models/progress_model.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  const OnboardingRepositoryImpl({
    required this._flowConfigSource,
    required this._progressSource,
  });

  final FlowConfigLocalDataSource _flowConfigSource;
  final ProgressLocalDataSource _progressSource;

  @override
  Future<FlowConfig> loadFlowConfig() async {
    final config = (await _flowConfigSource.load()).toEntity();
    FlowConfigValidator.validate(config);
    return config;
  }

  @override
  Progress? loadProgress() {
    try {
      return _progressSource.read()?.toEntity();
    } on FormatException {
      // Unreadable progress must never block the app: start fresh instead.
      return null;
    } on CheckedFromJsonException {
      return null;
    }
  }

  @override
  Future<void> saveProgress(Progress progress) =>
      _progressSource.write(ProgressModel.fromEntity(progress));
}
