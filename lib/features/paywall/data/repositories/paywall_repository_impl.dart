import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/paywall_progress.dart';
import '../../domain/repositories/paywall_repository.dart';
import '../datasources/paywall_local_data_source.dart';
import '../models/paywall_progress_model.dart';

class PaywallRepositoryImpl implements PaywallRepository {
  const PaywallRepositoryImpl(this._source);

  final PaywallLocalDataSource _source;

  @override
  PaywallProgress load() {
    try {
      return _source.read()?.toEntity() ?? const PaywallProgress();
    } on FormatException {
      // Unreadable progress must never block the app: start fresh instead.
      return const PaywallProgress();
    } on CheckedFromJsonException {
      return const PaywallProgress();
    }
  }

  @override
  Future<void> save(PaywallProgress progress) =>
      _source.write(PaywallProgressModel.fromEntity(progress));
}
