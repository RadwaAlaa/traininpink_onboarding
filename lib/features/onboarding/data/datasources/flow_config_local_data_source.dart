import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/flow_config_model.dart';

/// Reads the bundled flow config.
class FlowConfigLocalDataSource {
  const FlowConfigLocalDataSource(this._bundle);

  static const String _path = 'assets/config/onboarding_flow.json';

  final AssetBundle _bundle;

  Future<FlowConfigModel> load() async {
    final raw = await _bundle.loadString(_path);
    return FlowConfigModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }
}
