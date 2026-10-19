# TrainInPink Onboarding

A personalised, config-driven, branching onboarding flow that ends at a paywall.
Fully offline, English + Arabic (RTL), phone and tablet layouts.

## Requirements

- Flutter **3.47.7** (stable)
- Dart **3.13.5**

## Setup

```bash
flutter pub get
flutter run
```

## Codegen & checks

```bash
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
flutter analyze
flutter test
```

## Key decisions

_To be written._

## Assumptions

- Target platforms are Android and iOS only (desktop/web removed).
- One bundled font, **Cairo** (SIL OFL, `assets/fonts/OFL.txt`), covers both Latin and Arabic, so mixed EN/AR text stays visually consistent and nothing is fetched over the network.
- No use-case layer: at this size cubits depend directly on domain repository interfaces.

## What was cut and why

_To be written._

## Unfinished work / what I'd do next

_To be written._

## Questions

1. **Where in this flow would you put the paywall, and why? How would you find out whether you were right?**

   _To be written._

2. **What would you instrument to learn where people drop out, and what is the first change if data shows a cliff at the email step?**

   _To be written._
