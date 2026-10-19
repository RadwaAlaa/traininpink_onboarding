# CLAUDE.md — TrainInPink Onboarding (Flutter take-home, Variant E)

A personalised, **config-driven, branching** onboarding flow that ends at a **paywall**.
Fully offline. Nothing is really purchased. English + Arabic (RTL is first-class).
Phone and tablet layouts. Timebox: 4–6 hours — cut scope, never quality.

---

## 1. Working agreement (read first, every session)

- Work in **small phases** (see §9). Finish one phase, then **STOP**.
- At the end of each phase:
  1. Run `dart format .`, `flutter analyze` (must be **0 issues**), and `flutter test`.
  2. Post a short report: what changed, files touched, test/analyze output, open questions.
  3. **Wait for my explicit approval** before `git commit` / `git push` and before starting the next phase.
- Never commit, push, rename branches, or rewrite history without my approval.
- One phase = one or more small commits with Conventional Commit messages
  (`feat(onboarding): …`, `test(flow): …`, `chore: …`).
- If a requirement is ambiguous, make the conventional choice, note it in the phase report
  and in README "Assumptions" — don't block.
- I must be able to explain every line: prefer plain, readable code over clever code.

---

## 2. Tooling & versions (verified 2026-10-19 with `flutter pub get`)

| Tool | Version |
|---|---|
| Flutter (stable) | **3.47.7** |
| Dart | **3.13.5** |

`pubspec.yaml` — **only these packages. Do not add anything else without asking me first.**

```yaml
environment:
  sdk: ^3.13.0

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  flutter_bloc: ^9.1.1        # Cubit state management (brings in bloc 9.2.x)
  equatable: ^3.0.0           # value equality for entities & Cubit states
  json_annotation: ^4.12.0    # annotations for json_serializable models
  shared_preferences: ^2.5.6  # persist progress / locale / chosen plan (resume midway)
  intl: ^0.20.2               # required by gen-l10n (version pinned by flutter_localizations)

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
  build_runner: ^2.16.1       # NOTE: 2.17.x needs build 5.x, json_serializable 6.14.1 needs build 4.x → resolves to 2.16.1
  json_serializable: ^6.14.1
  bloc_test: ^10.0.0          # Cubit tests (add in the phase that first uses it)

flutter:
  uses-material-design: true
  generate: true              # gen-l10n
```

Rules:
- Before adding the dependency block, run `flutter pub outdated` and confirm nothing in
  "direct dependencies" is behind its **Resolvable** version. If a newer compatible version exists, use it and tell me.
- A package is added **only in the phase that first uses it** (e.g. `bloc_test` with the first Cubit test).
- Explicitly **not** used (and why):
  - `google_fonts` → fetches fonts over the network; app must be offline. Bundle font files in `assets/fonts/` instead.
  - `get_it` / `injectable` → manual constructor injection in `lib/app/di/` is enough at this size.
  - `go_router` / `auto_route` → requirement is **named routes** with `onGenerateRoute`.
  - `freezed`, `dartz`, `fpdart`, `hydrated_bloc` → unnecessary for this scope.
  - `mocktail` as a direct dependency → use small hand-written fakes of the repository interfaces instead.
- Codegen: `dart run build_runner build --delete-conflicting-outputs`. Commit generated `*.g.dart` files
  so the project runs straight from the README.

---

## 3. Architecture — Clean Architecture, feature-first

```
lib/
  main.dart                      # bootstrap: WidgetsFlutterBinding, SharedPreferences, DI, runApp
  app/
    app.dart                     # MaterialApp: theme, locales, onGenerateRoute, BlocProviders
    di/app_dependencies.dart     # manual wiring of data sources → repositories → use cases → cubits
    router/
      route_names.dart           # static const String splash = '/'; onboarding; summary; paywall; done
      app_router.dart            # onGenerateRoute + typed route arguments + page transitions
  core/
    l10n/arb/app_en.arb          # UI chrome strings (buttons, errors, labels)
    l10n/arb/app_ar.arb
    l10n/generated/              # gen-l10n output (do not hand-edit)
    locale/                      # LocaleCubit (en/ar, persisted)
    theme/                       # AppTheme, colors, typography, spacing tokens
    responsive/                  # breakpoints, ResponsiveLayout / context extensions
    storage/                     # thin SharedPreferences wrapper (KeyValueStore)
    widgets/                     # shared, dumb widgets (PrimaryButton, AppScaffold…)
    error/                       # Failure types
  features/
    onboarding/
      data/
        models/                  # @JsonSerializable DTOs + generated .g.dart, with toEntity()
        datasources/             # FlowConfigLocalDataSource (rootBundle), ProgressLocalDataSource (prefs)
        repositories/            # OnboardingRepositoryImpl
      domain/
        entities/                # FlowConfig, Step, Option, Condition, Answer, Progress, LocalizedText
        repositories/            # abstract OnboardingRepository
        engine/flow_engine.dart  # PURE Dart branching logic — no Flutter imports
        usecases/                # LoadFlowConfig, LoadProgress, SaveProgress, ClearProgress
      presentation/
        cubit/                   # OnboardingCubit + OnboardingState
        pages/onboarding_page.dart
        widgets/                 # SingleChoiceStep, MultiChoiceStep, TextInputStep, EmailStep, ProgressHeader…
    summary/
      domain/  presentation/     # personalised plan built from the path actually taken
    paywall/
      data/ domain/ presentation/  # plans, trial, selection, "subscribe" records the choice
assets/
  config/onboarding_flow.json    # THE source of truth for steps, branching, summary & paywall plans
  fonts/                         # bundled Latin + Arabic font (OFL licence file included)
test/
  features/onboarding/domain/flow_engine_test.dart   # REQUIRED: branching logic tests
  …mirrors lib/
```

Dependency rule: `presentation → domain ← data`. `domain` imports nothing from Flutter, `data`, or
`presentation`. Widgets never touch `SharedPreferences` or `rootBundle` directly.

---

## 4. Conventions

- **Models**: every JSON shape is a `@JsonSerializable()` class in `data/models/` with
  `fromJson`/`toJson` (`part 'x.g.dart';`). Use `fieldRename: FieldRename.snake`,
  `@JsonKey(unknownEnumValue: …)` for enums, and `checked: true` so bad config fails loudly with a clear message.
  Models map to immutable domain entities (`Equatable`) via `toEntity()`. Entities have no JSON code.
- **State**: Cubit only (no Bloc events). States are immutable `Equatable` classes with `copyWith`.
  One Cubit owns one concern. UI reads with `BlocBuilder`/`BlocSelector`, side effects with `BlocListener`.
  Cubits receive use cases through the constructor.
- **Routing**: named routes only — `Navigator.pushNamed(context, RouteNames.paywall)`.
  Route names live in `RouteNames`; arguments are typed classes, never raw maps.
  Onboarding *steps* are **not** separate routes: they are one `/onboarding` route whose content is
  driven by `OnboardingCubit` (so the engine, not the navigator stack, owns the path).
  System/Android back on onboarding → `PopScope` → `cubit.back()`.
- **Null safety** everywhere, no `!` unless provably safe with a comment. No `dynamic` outside JSON parsing.
- Names: files `snake_case.dart`, one public widget/class per file, private sub-widgets `_Foo`.
- No hardcoded user-visible strings in widgets: UI chrome → ARB; question content → config JSON.
- No magic numbers in layout: use spacing tokens from `core/theme`.
- Keep files < ~250 lines; split widgets early.

---

## 5. The flow config (`assets/config/onboarding_flow.json`)

Adding a question or a branch must be a **JSON edit only — no Dart changes**.
The exact schema is ours to design (document the reasoning in README); baseline:

- `version` (int) — saved progress from a different version is discarded safely.
- `start` — first step id. Steps form a **linear ordered list**; each step may have `show_if`.
  The visible path = steps whose `show_if` evaluates true against answers **on the path so far**.
  (Chose ordered list + conditions over a free graph: no cycles/dead ends by construction, easy to diff.)
- Step `type`: `single_choice`, `multi_choice`, `text` (free input, e.g. name / injury notes),
  `number` (optional), `email`. Each with `id`, `title`/`subtitle` as `LocalizedText`
  (`{"en": "...", "ar": "..."}`), `required`, and type-specific fields (`options`, `min_selected`,
  `max_selected`, `max_length`, `keyboard`).
- Conditions (`show_if`), composable: `{"eq": ["goal", "get_back_into_it"]}`, `{"in": [...]}`,
  `{"contains": ["focus_areas", "core"]}`, `{"all": [...]}`, `{"any": [...]}`, `{"not": {...}}`.
- `summary` section: per-option/per-step summary lines + rules that pick the plan headline
  (e.g. weekly frequency, focus, intensity) from answers.
- `paywall` section: ≥ 2 plans (`id`, `title`, `price_label`, `period`, `trial_days`, `badge`,
  `default_selected`). Prices are display strings — nothing is purchased.
- Content must exist in **both `en` and `ar`**. The loader validates this.

Config is validated at load (unit-tested): unique ids, `start` exists, conditions reference only
**earlier** steps, options referenced in conditions exist, every locale present, ≥ 2 plans.

---

## 6. Branching engine rules (the heart — `domain/engine/flow_engine.dart`)

Pure functions, fully unit-tested:
- `List<Step> resolvePath(FlowConfig, Map<String, Answer>)` — recomputed on **every** answer change.
- `Map<String, Answer> pruneAnswers(path, answers)` — answers for steps **not on the current path are
  removed**, so stale answers never reach the summary or storage.
- `Step? next(currentId)` / `Step? previous(currentId)` — always on the freshly resolved path → no dead ends.
- Changing an earlier answer re-routes everything after it; answers to steps still on the path are kept.
- Going back never loses the answer of the step she lands on (pre-filled from state).
- Required tests (minimum): the brief's example — `last_trained` is asked only when
  `goal == get_back_into_it`; switching goal to `build_strength` removes it from path, answers and summary;
  switching back re-asks it; multi-choice `contains` branch; nested `all/any/not`; invalid config rejected.

---

## 7. UX, RTL & responsive non-negotiables

- **RTL**: only `EdgeInsetsDirectional`, `AlignmentDirectional`, `PositionedDirectional`,
  `TextAlign.start/end`, `start/end` — never `left/right`. Directional icons must mirror
  (back/forward chevrons, progress direction, slide transitions flip in RTL).
  Arabic uses a proper bundled Arabic font with correct line height; test every screen in Arabic.
  Email field is always LTR (`textDirection: TextDirection.ltr`) even in Arabic.
- **Locale**: default to device locale (en/ar, fallback en); in-app language toggle, persisted.
- **Progress**: clear progress indicator based on the *current resolved path length* (animate when it changes).
- **Resume**: answers + current step id + selected plan saved on every change; on relaunch she lands
  exactly where she left off (or summary/paywall if she'd reached them).
- **Email**: trimmed, validated with a sensible regex, inline error after first submit/blur, email keyboard,
  `autofillHints: [AutofillHints.email]`. Email only — no password.
- **Keyboard**: never covers the focused field or the CTA (`resizeToAvoidBottomInset`, scrollable body,
  CTA pinned above keyboard via `viewInsets`). Tap outside to dismiss. `TextInputAction.next/done` wired.
- **Motion**: smooth step transitions (~250–300 ms, `Curves.easeOutCubic`), direction-aware (forward vs back,
  flipped in RTL). No layout jumps — reserve space for error text, fixed CTA height.
- **Double-tap safety**: CTA/option taps are idempotent; ignore input while a transition is running;
  "Subscribe" disabled while recording.
- **Phone vs tablet**: breakpoint at shortestSide ≥ 600. Phone = single column. Tablet = content constrained
  (max ~560 dp) and centred for questions; summary + paywall can sit in a two-pane layout; plans side-by-side.
  Support portrait & landscape without overflow.
- Accessibility: `Semantics` on option tiles (selected state), tap targets ≥ 48 dp, respects text scaling up to 1.3.

---

## 8. Deliverables required by the brief

- `README.md`: setup steps, Flutter version, how to run codegen/tests, assumptions, key decisions
  (config shape & why, state ownership, storage), what was cut and why, unfinished work, what I'd do next,
  and the **two answers**:
  1. Where in this flow would you put the paywall, and why? How would you find out whether you were right?
  2. What would you instrument to learn where people drop out, and the first change if data shows a cliff at the email step?
- `AI_USAGE.md`: tools used, where they helped, **what was rejected and why**.
- At least one test covering the branching logic itself (we'll have many).
- `flutter analyze` clean. Clear commit history.
- Recommended: short screen recording of the flow (EN + AR).

---

## 9. Phases (stop after each one for approval)

| # | Phase | Done when |
|---|---|---|
| 0 | Scaffold: `flutter create`, pubspec (§2), lints, folder skeleton, assets dirs, git init, README stub | app runs, analyze clean |
| 1 | Core: theme & tokens, bundled fonts, gen-l10n (EN/AR ARB), `LocaleCubit`, named routes skeleton, responsive helpers | placeholder screens navigate by name in EN & AR (RTL) |
| 2 | Domain: entities, conditions, `FlowEngine` (resolve/prune/next/previous/validate) + unit tests | engine tests green, no Flutter imports in domain |
| 3 | Data: json_serializable models, `onboarding_flow.json` (EN/AR, real branching), data sources, repository, progress persistence + parsing tests | config loads & validates; progress round-trips |
| 4 | Onboarding UI: `OnboardingCubit`, step widgets (single, multi, text, email), progress, back, transitions, keyboard handling, resume | full flow works end-to-end on phone |
| 5 | Personalised summary from the path actually taken | summary changes correctly when an earlier answer changes |
| 6 | Paywall: ≥2 plans, trial, selected state, subscribe records choice, done screen | choice persisted & shown |
| 7 | Polish: tablet layouts, RTL audit, motion, double-tap guards, a11y | manual checklist in §7 passes on phone + tablet, EN + AR |
| 8 | Tests (cubit + widget), README with answers, AI_USAGE.md, final analyze | all deliverables in §8 present |

Useful commands:
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
flutter analyze
flutter test
flutter run
```
