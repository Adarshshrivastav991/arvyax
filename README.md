# ArvyaX — Immersive Session & Reflection

A calm, minimal, premium Flutter mini-app: **Explore Ambiences → Start Session → Control Player → Journaling → History**.

---

## How to Run

```bash
# 1. Clone the repository
git clone <repo-url>
cd arvyax

# 2. Install dependencies
flutter pub get

# 3. Run on a connected device or emulator
flutter run
```

**Requirements:** Flutter SDK ≥ 3.10.4, Dart ≥ 3.10.4

To build the APK:
```bash
flutter build apk --release
```

---

## Architecture

### Folder Structure

```
lib/
├── main.dart                  # App entry point & ProviderScope
├── router.dart                # GoRouter navigation + bottom nav shell
├── data/
│   ├── models/                # Hive-annotated data models
│   │   ├── ambience_model.dart
│   │   └── journal_entry_model.dart
│   └── repositories/          # Data access layer
│       ├── ambience_repository.dart   # Loads JSON, caches in memory
│       ├── journal_repository.dart    # Hive CRUD for journal entries
│       └── session_repository.dart    # Hive persistence for active session
├── features/
│   ├── ambience/              # Ambience browsing feature
│   │   ├── controller/        # Riverpod providers (filter, search)
│   │   ├── screens/           # HomeScreen, AmbienceDetailsScreen
│   │   └── widgets/           # AmbienceCard, TagFilterChip, SearchBar
│   ├── player/                # Session player feature
│   │   ├── controller/        # SessionController (StateNotifier)
│   │   ├── screens/           # SessionPlayerScreen
│   │   └── widgets/           # PlayerControls, ProgressBar, MiniPlayer
│   └── journal/               # Journaling feature
│       ├── controller/        # ReflectionController, journal providers
│       ├── screens/           # ReflectionScreen, JournalHistory, JournalDetail
│       └── widgets/           # JournalCard, MoodSelector
└── shared/
    ├── theme/                 # AppTheme (light/dark), AppColors, ThemeProvider
    ├── utils/                 # TimeFormatter
    └── widgets/               # PrimaryButton, EmptyStateWidget, FrostedGlass
```

### State Management — Riverpod

All state is managed via **flutter_riverpod**:

| Provider | Type | Purpose |
|---|---|---|
| `ambiencesProvider` | FutureProvider | Loads ambiences from JSON |
| `filteredAmbiencesProvider` | Provider | Applies search + tag filters |
| `sessionControllerProvider` | StateNotifierProvider | Audio playback, timer, session lifecycle |
| `reflectionControllerProvider` | StateNotifierProvider | Journal text + mood + save |
| `journalEntriesProvider` | FutureProvider | Reads all persisted journal entries |
| `themeProvider` | StateNotifierProvider | Dark/light theme toggle |

### Data Flow

```
JSON / Hive  →  Repository  →  Riverpod Provider  →  Widget (UI)
                                      ↑
                              User actions trigger
                              state mutations via
                              StateNotifier methods
```

1. **Repositories** are the single source of truth for data access (JSON loading, Hive read/write).
2. **Controllers (StateNotifiers)** hold mutable state and expose methods for UI actions (play, pause, save, filter).
3. **Providers** compose and derive state (e.g., `filteredAmbiencesProvider` combines search + tag + raw data).
4. **Widgets** watch providers via `ref.watch()` and rebuild reactively.

---

## Packages Used

| Package | Purpose |
|---|---|
| **flutter_riverpod** | State management — chosen for its compile-safe providers, testability, and auto-dispose lifecycle |
| **just_audio** | Audio playback with loop mode — mature, well-maintained, supports asset loading |
| **hive / hive_flutter** | Local persistence — fast, lightweight, no native dependencies, ideal for journal entries and session state |
| **go_router** | Declarative routing with ShellRoute for bottom nav — Flutter-team maintained, supports deep linking |
| **google_fonts** | Typography (Inter) — clean, modern typeface loaded on demand |
| **intl** | Date formatting for journal entries |
| **uuid** | Unique ID generation for journal entries |

---

## Features Implemented

- **Ambience Library** — 6 ambiences from local JSON, grid display, search bar, tag filter chips (Focus / Calm / Sleep / Reset), empty state with "Clear Filters"
- **Ambience Details** — Hero image, title, tag, duration, description, sensory recipe chips, "Start Session" button
- **Session Player** — Play/pause, seek bar, elapsed/total time, calm gradient background, breathing animation, looping audio, end session with confirmation dialog
- **Mini Player** — Appears on Home and Details screens when session active, shows title + play/pause + progress bar
- **Post-Session Reflection** — Prompt text, multiline journal input, mood selector (Calm/Grounded/Energized/Sleepy), save to Hive
- **Journal History** — Chronological list with date, ambience title, mood, reflection preview; tap for full detail view; empty state message
- **Persistence** — Journal entries and active session state persisted via Hive; mini-player restores after app restart
- **Dark Mode** — Full light/dark theme support with toggle button on home screen; premium frosted glass UI throughout
- **Loading & Error States** — All async providers show loading spinners and error messages

---

## Tradeoffs & Future Improvements

Given two more days, I would:

1. **Real audio assets** — Replace the placeholder MP3 with actual ambient soundscapes for each ambience.
2. **App lifecycle handling** — Pause the session timer when the app goes to background and resume correctly using `WidgetsBindingObserver`.
3. **Animated transitions** — Add Hero animations between ambience cards and the detail screen, and page transitions for the player.
4. **Search in journal** — Add full-text search across journal entries.
5. **Haptic feedback** — Add subtle haptics on play/pause, save reflection, and filter chip taps.
6. **Widget tests** — Add comprehensive widget and integration tests for critical flows (session lifecycle, journal persistence).
7. **Accessibility** — Ensure all interactive elements have semantic labels, and test with larger text sizes.
8. **Image assets** — Replace gradient placeholders with actual Unsplash images per ambience theme.
