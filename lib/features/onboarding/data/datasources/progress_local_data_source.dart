import 'dart:convert';

import '../../../../core/storage/key_value_store.dart';
import '../models/progress_model.dart';

/// Stores progress as one JSON string.
class ProgressLocalDataSource {
  const ProgressLocalDataSource(this._store);

  static const String _key = 'onboarding_progress';

  final KeyValueStore _store;

  ProgressModel? read() {
    final raw = _store.getString(_key);
    if (raw == null) return null;
    final json = jsonDecode(raw);
    return json is Map<String, dynamic> ? ProgressModel.fromJson(json) : null;
  }

  Future<void> write(ProgressModel progress) =>
      _store.setString(_key, jsonEncode(progress.toJson()));
}
