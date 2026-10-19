import '../entities/paywall_progress.dart';

abstract interface class PaywallRepository {
  /// Saved paywall progress, or an empty one if none or unreadable.
  PaywallProgress load();

  Future<void> save(PaywallProgress progress);
}
