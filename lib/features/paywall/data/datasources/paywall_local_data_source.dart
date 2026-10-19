import 'dart:convert';

import '../../../../core/storage/key_value_store.dart';
import '../models/paywall_progress_model.dart';

/// Stores paywall progress as one JSON string.
class PaywallLocalDataSource {
  const PaywallLocalDataSource(this._store);

  static const String _key = 'paywall_progress';

  final KeyValueStore _store;

  PaywallProgressModel? read() {
    final raw = _store.getString(_key);
    if (raw == null) return null;
    final json = jsonDecode(raw);
    return json is Map<String, dynamic>
        ? PaywallProgressModel.fromJson(json)
        : null;
  }

  Future<void> write(PaywallProgressModel progress) =>
      _store.setString(_key, jsonEncode(progress.toJson()));
}
