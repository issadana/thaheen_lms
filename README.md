# Thaheen LMS – Mini Offline Student App

A small, fully offline version of the Thaheen student app. It shows courses, sections and video lessons from bundled assets, with sequential unlock, resume and auto-completion at 90%. The interface is Arabic-first (RTL), with an English switch.

## How to run

Requires Flutter stable (built with Flutter 3.41).

```bash
flutter pub get
flutter run
```

The app ships with two extra catalogs that make the edge cases easy to review without changing the real data:

```bash
flutter run --dart-define=CATALOG=edge     # missing video, corrupt video, empty section, empty course, missing thumbnail
flutter run --dart-define=CATALOG=corrupt  # invalid JSON → catalog error screen with retry
```

Tests:

```bash
flutter test
```

## Features

**Required**

- **Courses screen:** thumbnail, title, instructor, lesson count and progress %. A "Continue watching" card shows the most recently watched unfinished lesson.
- **Course details:** sections and lessons with duration and status (not started / in progress / completed). Lessons unlock in order, across sections. Tapping a locked lesson explains which lesson to finish first. The header offers Start / Continue / Watch again.
- **Player:**
  - Play/pause, a seek bar that shows frames while you drag, current time and duration.
  - Speed 1x / 1.25x / 1.5x / 2x.
  - Fullscreen in landscape, with controls that fade out and come back on tap.
  - Resumes from the last position. A lesson is marked completed at 90%, with a short "Lesson completed" badge, and "Next lesson" follows the unlock rule.
- **Persistence:** positions and completed lessons survive a restart.
- **Arabic-first RTL:** Arabic by default. Layout, paddings, arrows and the seek bar follow the reading direction. Times and speeds (`1.5x`, `03:14`) always read left to right.
- **States:** loading, empty catalog, empty course, empty section, course or lesson not found, catalog error, and missing or corrupt video. Every error screen explains the problem and offers a retry where it makes sense.

**Bonus:** Arabic/English switch, dark mode, course search, remembered playback speed, widget tests.

## Architecture

```
lib/
  core/            shared: config (portrait-only orientation), theme, router, l10n,
                   localized content text, shared widgets
  features/
    courses/       data (repository) · domain (Course/Section/Lesson) · presentation
    progress/      data (store) · domain (rules) · presentation (cubit)
    player/        presentation (cubit, screen, widgets)
    settings/      data (store) · presentation (cubit, app-bar actions)
```

Each feature has three layers, and each layer only depends on the ones below it:

- **data** reads assets and local storage and turns them into domain objects. Examples: `CourseRepository`, `ProgressStore`, `SettingsStore`.
- **domain** is plain Dart with no Flutter code. It holds the models and the rules. All the progress logic, such as the 90% rule, unlocking, progress %, the resume position and "Continue watching", is pure functions in `progress_rules.dart`. That's why it can be tested without widgets.
- **presentation** holds the cubits, screens and widgets.

Some parts that aren't obvious from the code:

- **Routing (go_router).** `RoutesManager` owns the router and every navigation call. Screens don't know about routes; they receive callbacks such as `onOpenLesson`. Routes are nested (courses → course → lesson) and opened with `go`, so the back stack is always correct, even when a lesson is opened from "Continue watching".
- **Screens load their data from the URL.** The course and player screens only receive IDs. `CatalogGate` handles the "not loaded yet", "failed" and "not found" cases in one place, so a screen only builds its content once the course or lesson exists. Because nothing is passed in memory between screens, a rebuilt route never loses its data.
- **The unlock rule is enforced in two places.** The course list disables locked lessons, and the player checks again when it opens, so a direct link can't skip ahead.
- **Two kinds of translation.** Fixed UI text uses Flutter's `gen-l10n` with ARB files. Course content comes from the JSON, so it can't use ARB files; `LocalizedText` holds each value in both languages and falls back to Arabic.

### State management: Bloc (Cubit)

- `CoursesCubit`: the catalog and the search query.
- `ProgressCubit`: the single source of truth for progress. Every screen reads it and calculates statuses and percentages with the domain rules.
- `SettingsCubit`: language, theme and playback speed.
- `PlayerCubit`: one per open lesson. It owns the video controller, saves progress and handles the controls' visibility.

I chose Cubit over full Bloc because the app's events are simple method calls ("play", "search", "record position"), so separate event classes would only add code. The state is also easy to test, and screens never write to storage themselves.

The only `setState` left is in the seek bar (`player_controls.dart`), for the thumb's position while it's being dragged. The thumb has to follow the finger every frame, but the video's reported position lags behind while it seeks, so that position stays local to the widget.

### Local storage: SharedPreferences

Progress is a small map of `courseId/lessonId → {position, duration, completed, updatedAt}`, saved as one versioned JSON value (`progress.v1`). SharedPreferences fits that well:

- **The data is small and has no relations.** One lesson is only a few bytes, and the app has no queries or schema that would need a database.
- **No code generation or native database setup.** Hive and Isar need adapters or schemas and code generation, and both have uncertain maintenance at the moment.
- **Reads are synchronous once it's loaded.** Progress is available the moment the app starts, with no loading state.
- **Corrupt data can't block the app.** If the stored JSON can't be read, the app logs it and starts with empty progress.

With many courses, or features like notes and sync, I would switch to a real database (Drift/sqflite), because saving the whole map on every write would get expensive.

**When progress is saved:** on pause, on seek, when the lesson reaches 90%, when the video ends, when the app goes to the background, when the player closes, and every 5 seconds while playing. So a crash or a killed app loses at most a few seconds.

### Changes to the suggested JSON shape

- Text fields (`title`, `instructor`) accept a plain string **or** `{"ar": "...", "en": "..."}`. That's what makes the English switch work for content too. If a translation is missing, the Arabic text is shown.
- `thumbnail` is optional. A missing or broken image shows a placeholder.
- Lesson IDs only need to be unique **within their course**, because progress is stored per course (the sample data reuses `l1`).
- The catalog is validated when it loads: missing or wrong-typed fields, empty IDs, duplicate course IDs, duplicate lesson IDs within a course, and negative durations. A bad file shows the catalog error screen, not a crash.

## Tests

49 tests.

- **`progress_rules_test.dart`:** the 90% completion rule (at 90%, just below 90%, unknown duration, completion stays after seeking back, out-of-range positions), the unlock rule (first lesson, across sections, progress from another course, unknown lesson), progress % (including an empty course), the course action button, the resume position and "Continue watching".
- **Cubits and data:** `ProgressCubit`, `CoursesCubit` search, and `CourseRepository` parsing and validation (valid catalog, bundled catalog, malformed JSON, missing field, duplicate IDs, missing file).
- **Widget tests (`app_test.dart`):** the main flows, including the corrupt-catalog error with retry and the empty catalog.

## Trade-offs and known issues

- **Fullscreen only through the button.** The app stays in portrait, and landscape is only unlocked while fullscreen is on. When landscape is allowed on a normal screen, the system briefly jumps to the last orientation it remembers before correcting, which makes screens flip on their own.
- **Three clips shared by nine lessons.** This keeps the app small (the videos total under 21 MB); each lesson still stores its own progress.
- **Durations.** The `durationSec` in the catalog is only used for display. Completion and resume use the real duration reported by the player.
- **Progress depends on IDs.** Progress is stored by course and lesson ID, so renaming an ID in the catalog would lose the progress stored under the old ID.
- **No `PlayerCubit` tests.** Testing it would need a fake video controller. The rules it relies on are covered by the domain tests.
- <!-- TODO: add anything you noticed on a real device, e.g. "Tested on: Pixel 7 (Android 15), iPhone 13 (iOS 18)". -->

## What I'd do with more time

- **Per-lesson notes** (the one bonus I skipped): a notes store keyed like progress, plus a notes panel under the player.
- Tests for `PlayerCubit` with a fake video controller (control hiding, completion badge, scrubbing), and golden tests for the RTL and LTR layouts.
- A move to Drift/sqflite once the data grows, with a migration from `progress.v1`.
- Accessibility: a screen-reader review, larger font sizes, and announcing when a lesson is completed.
- Picture-in-picture and background audio.

## Time spent

<!-- TODO: fill in, e.g. "About 6 hours: 1 h data and domain, 2.5 h player, 1.5 h UI/RTL, 1 h tests and README." -->
