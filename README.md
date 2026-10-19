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
- No `start` field in the config: steps are an ordered list, so the flow starts at the first step (which can't have a `show_if`, since conditions may only reference earlier steps).
- The optional `number` step type is cut; the flow doesn't need one. Text and email answers share one `TextAnswer` type.
- The domain step entity is `FlowStep`, not `Step`, to avoid clashing with Flutter's material `Step` widget.
- A step's `show_if` only sees answers to steps already on the path, so a leftover answer from a skipped step can never switch a later step on.

## What was cut and why

_To be written._

## Unfinished work / what I'd do next

_To be written._

## Questions

1. **Where in this flow would you put the paywall, and why? How would you find out whether you were right?**

   _To be written._

2. **What would you instrument to learn where people drop out, and what is the first change if data shows a cliff at the email step?**

   _To be written._
