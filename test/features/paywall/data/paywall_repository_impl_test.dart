import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:traininpink_onboarding/core/storage/key_value_store.dart';
import 'package:traininpink_onboarding/features/paywall/data/datasources/paywall_local_data_source.dart';
import 'package:traininpink_onboarding/features/paywall/data/repositories/paywall_repository_impl.dart';
import 'package:traininpink_onboarding/features/paywall/domain/entities/paywall_progress.dart';

void main() {
  Future<PaywallRepositoryImpl> repositoryWith(
    Map<String, Object> saved,
  ) async {
    SharedPreferences.setMockInitialValues(saved);
    final store = KeyValueStore(await SharedPreferences.getInstance());
    return PaywallRepositoryImpl(PaywallLocalDataSource(store));
  }

  test('progress round-trips through storage', () async {
    final repository = await repositoryWith({});
    const progress = PaywallProgress(
      selectedPlanId: 'monthly',
      subscribedPlanId: 'monthly',
    );
    await repository.save(progress);

    expect(repository.load(), progress);
  });

  test('missing or unreadable progress starts fresh', () async {
    expect((await repositoryWith({})).load(), const PaywallProgress());

    for (final corrupt in ['not json', '[]', '{"on_paywall": "yes"}']) {
      final repository = await repositoryWith({'paywall_progress': corrupt});
      expect(repository.load(), const PaywallProgress(), reason: corrupt);
    }
  });
}
