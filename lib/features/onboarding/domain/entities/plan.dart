import 'package:equatable/equatable.dart';

import 'localized_text.dart';

/// A subscription plan on the paywall. Prices are display text only:
/// nothing is ever purchased.
class Plan extends Equatable {
  const Plan({
    required this.id,
    required this.title,
    required this.priceLabel,
    required this.period,
    this.trialDays = 0,
    this.badge,
    this.defaultSelected = false,
  });

  final String id;
  final LocalizedText title;
  final LocalizedText priceLabel;
  final LocalizedText period;
  final int trialDays;
  final LocalizedText? badge;

  /// Exactly one plan is pre-selected when she first opens the paywall.
  final bool defaultSelected;

  @override
  List<Object?> get props => [
    id,
    title,
    priceLabel,
    period,
    trialDays,
    badge,
    defaultSelected,
  ];
}
