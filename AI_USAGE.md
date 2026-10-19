# AI usage

## Tools

| Tool | Used for |
|---|---|
| **Claude Code** (Claude Opus 5.5, in the Claude desktop app) | Writing code phase by phase, code reviews, running `flutter analyze` / `flutter test` / builds, git and GitHub PRs |
| **Claude's iOS Simulator control** | Walking through the flow on an iPhone 15 Pro Max simulator in English and Arabic |
| **`CLAUDE.md`** (in this repo) | The working agreement the AI had to follow: architecture, allowed packages, conventions, phases, and "stop for approval after every phase" |

No other AI tools were used.

## How I worked with it

- **I wrote the rules first.** `CLAUDE.md` fixes the architecture (feature-first Clean Architecture, Cubit, named routes), the only packages allowed and why the rest are out, the config/engine design, the RTL and UX rules, and a 9-phase plan.
- **One phase at a time, with me approving every step.** After each phase the AI had to run `dart format`, `flutter analyze` (0 issues) and `flutter test`, then report and stop. Nothing was committed, pushed or merged without my say-so.
- **A review after every phase, before committing.** I asked for a code review of each phase's diff, then decided which findings to fix. Each fix had to come with a test where possible.
- **Minimal code.** I told it early on not to write any code that isn't used now or in the very next phase, because I need to be able to explain every line.

## Where it helped

- **Speed on the boring but necessary parts:** `json_serializable` models, ARB files, the validator's error messages, test scaffolding and fakes, and README notes.
- **The branching engine and its tests.** It turned the "ordered list + `show_if`" design into pure functions (`resolvePath`, `pruneAnswers`, `next`/`previous`, `restore`). It also wrote tests for the brief's `last_trained` example, nested `all`/`any`/`not`, and stale answers that must not switch steps on.
- **Reviews caught real bugs before they shipped**, for example:
  - A required multi-choice step could be passed with nothing selected.
  - Saved progress from an edited config could leave her stuck on a step that no longer exists.
  - A double tap on Continue could skip a step.
  - Progress from an old config version still skipped the splash.
  - Resuming onto the summary didn't check that every question was still answered.
  - A failed save left the Subscribe button disabled forever.
- **Checking on a real screen.** On the simulator it confirmed:
  - The branches appear and disappear correctly.
  - The Arabic layout mirrors: back chevron, progress direction and slide direction.
  - The email field stays left-to-right inside Arabic, and the inline error appears on blur.
  - Resume works after a cold relaunch.

## What I rejected or changed, and why

| Suggestion / output | What I did | Why |
|---|---|---|
| Packages like `google_fonts`, `get_it`, `go_router`, `freezed`, `mocktail` | Not used (decided up front in `CLAUDE.md`) | The app must work offline (bundled Cairo font instead of `google_fonts`); manual DI and named routes are enough at this size; small hand-written fakes are easier to explain than mocks. |
| Review finding: "the config has no `start` field" | Rejected | Steps are an ordered list, so the first step is the start, and it can't have a `show_if`. This is documented in the README. |
| Letting `eq` conditions branch on free-text answers | Changed: conditions only work on choice steps | Exact matching on typed text ("Sara " vs "Sara") is too fragile to drive the flow. |
| Moving to the summary through a `BlocListener`, as `CLAUDE.md` asks | Kept as a direct call in the Continue handler, with the reason in the README | A "completed" state would need resetting every time she comes back to edit an answer. A direct push is simpler to explain. |
| `bloc_test` | Not added | Plain tests on `cubit.state` with a fake repository were enough. |
| The AI's first fix for widget tests stuck on "loading" (warming the asset cache with `runAsync`) | Replaced | It didn't work: the cached future completed in the wrong zone. The real fix was letting tests inject an `AssetBundle` that reads the file synchronously. |
| A widget test that "passed" for the double-tap guard | Proved it with a mutation check | Disabling `IgnorePointer` alone still passed, because `_continue` also checks the lock. Disabling the lock itself made the test fail, which showed the test really covers the guard. |
| Rebuilding the iOS app just to look at the launch-screen colour | Stopped it | Not worth the build time at that point. It's left for the Phase 7 device check. |

## What I checked myself, and what's still open

- The AI's reports were checked against reality, not taken on trust. When I said a PR was merged and it wasn't, it checked GitHub, found the PR still open, and removed the branch it had started too early.
- **Arabic copy** in the config and ARB files was written with AI help. Everything AI-generated was meant to be reviewed by me before shipping, and the Arabic copy should get a native speaker's read before release.
- **Not yet verified on a device:**
  - Keyboard avoidance with the software keyboard (the simulator used the hardware keyboard).
  - The paywall and done screens, which so far are covered by widget tests only.
  - Tablet layouts (Phase 7).
- The release APK and the GitHub release workflow sign with Flutter's debug key, so they're for testing, not the store.
