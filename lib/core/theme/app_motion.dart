import 'package:flutter/animation.dart';

/// Motion tokens shared by page and step transitions.
abstract final class AppMotion {
  static const Duration transition = Duration(milliseconds: 280);
  static const Curve curve = Curves.easeOutCubic;
}
