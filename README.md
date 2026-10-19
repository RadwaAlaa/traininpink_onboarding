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
- Conditions only branch on choice steps (`eq`/`in` on single choice, `contains` on multi choice), never on free text: exact matching on typed text is too fragile to drive the flow.
- A required multi-choice step without `min_selected` needs at least one pick.
- Saved progress that can't be read, or was saved against a different config `version`, is discarded and she starts fresh — it never blocks the app.
- Every step, single choice included, is answered and then confirmed with Continue (no auto-advance), so all step types behave the same and nothing moves on from a mis-tap.
- Taps are ignored while a step transition (or the push to the summary) is running, so a double tap can never skip a step.
- With saved progress the app opens straight on the onboarding route; the splash stays underneath, so back from the first question returns to it.
- Moving from the last question to the summary is the one navigation call made in a button handler instead of a `BlocListener`: a "completed" state would need resetting every time she comes back to edit, so the page pushes the route directly and the cubit stays a plain record of her answers.
- Progress is saved on every real change, including each keystroke in a text field. Writes are tiny and local, and saving on blur instead would lose text if the app is killed mid-answer.
- The summary is config too: `summary.headlines` (first match wins, the last has no `show_if`) and `summary.lines` (every match shows), using the same conditions as steps, evaluated only on answers left on her path. `{step_id}` fills in a required, always-shown text answer such as `{name}`.
- Reaching the summary is saved, so a relaunch rebuilds splash → questions → summary and back still walks the same way.
- Paywall plans are config (`paywall.plans`: at least 2, exactly one `default_selected`); prices and periods are display text, localised like everything else. Subscribing only records the chosen plan locally, with nothing charged, and the page says so.
- Paywall progress (selected plan, on the paywall, subscribed plan) is saved separately from the questions by its own `PaywallCubit`. A relaunch on the paywall rebuilds splash → questions → summary → paywall, and after subscribing only the done screen remains.
- An optional step left blank shows "Skip" instead of "Continue".
- Config models only generate `fromJson` (`createToJson: false`): the app reads the config but never writes it, so a `toJson` would be dead code. Progress models, which are saved, have both.
- Saved progress is checked against the current config on resume: answers off the path are dropped, and if her saved step is no longer on the path she restarts at the first step.
- The config's `summary` and `paywall` sections are added in the phases that use them (5 and 6), so the parser only knows about what the app reads.

## What was cut and why

_To be written._

## Unfinished work / what I'd do next

_To be written._

## Questions

1. **Where in this flow would you put the paywall, and why? How would you find out whether you were right?**

   _To be written._

2. **What would you instrument to learn where people drop out, and what is the first change if data shows a cliff at the email step?**

   _To be written._
