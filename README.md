# ArvyaX

A calming ambient sound + journaling app built with Flutter. Pick a soundscape, run a timed session with a breathing animation, then write a quick reflection — everything gets saved locally.

Dark mode is the default because that's the vibe, but there's a light mode too.

## Getting started

```bash
flutter pub get
flutter run
```

Needs Flutter 3.10.4+. Build a release APK with `flutter build apk --release`.

## What it does

The main flow is pretty simple: **Browse → Play → Reflect → Journal**.

**Home** — Grid of ambient sessions you can search and filter by mood (Focus, Calm, Sleep, Reset). Each card opens a detail page with the full description, duration, and a "sensory recipe" — stuff like Breeze, Warm Light, Rain, Binaural beats, etc.

**Sessions Library** — Second tab, organizes the same sessions by mood. Horizontal carousels for each category. There's a quick-play button on each card so you can start playing without opening details first.

**Player** — Full screen with a breathing orb that scales in and out on a 6-second cycle. Play/pause, skip ±10s, seek bar. Audio loops continuously. When the timer ends it auto-navigates to the reflection screen. You can also end early — there's a confirmation dialog so you don't accidentally lose progress.

**Mini Player** — Shows up at the bottom of every other screen while a session is running. Play/pause + progress bar. Tap it to go back to the full player.

**Reflection** — After a session ends, you get a prompt ("What is gently present with you right now?"), a text field, and 4 mood chips (Calm, Grounded, Energized, Sleepy). Hit save and it goes into the journal.

**Journal** — Three tabs: All, Recent (last 7 days), Favorites. Each entry shows the ambience name, date, mood, a preview of what you wrote, and a "View Session" button for the full detail page with stats. You can tap the heart icon on any card to favorite/unfavorite it.

**Settings** — A haptic intensity slider that goes from subtle taps to insane vibrations. Logarithmic scale (10–10,000), 5 quick presets, and a test button. The whole app uses haptic feedback on interactions — this screen controls how strong it feels.

**Dark/Light toggle** — On the home screen. Rotates the icon when you switch. Every screen adapts.

## Audio

5 MP3 files in `assets/audio/`, mapped to 6 ambiences:

- **Forest Focus** & **Misty Peaks** → `forest.mp3`
- **Ocean Calm** → `ocean clam.mp3`
- **Rain Shelter** → `Rain shelter.mp3`
- **Sunrise Reset** → `sunrise reset.mp3`
- **Starlit Meadow** → `sleep.mp3`

Playback uses `just_audio` for the actual player, `audio_service` for background play + notification controls, and `audio_session` for focus handling. Audio keeps playing when you leave the app — you get the standard Android media notification with play/pause.

## Tech stack

Why each package:

- **flutter_riverpod** — picked over Provider/Bloc because providers are compile-safe (typo = build error, not runtime crash), auto-dispose lifecycle is basically free, and you can compose providers without nesting widgets. The ~13 providers in this app would've been a lot of boilerplate with Bloc.
- **just_audio** — the most mature audio library for Flutter. Handles asset loading, seeking, loop modes, position streams. Other options (audioplayers) had worse API ergonomics for what I needed.
- **audio_service** — needed for background playback. Without it, audio stops when the app goes to background on Android. This gives you the notification controls for free.
- **audio_session** — handles audio focus (pauses when a phone call comes in, etc.). Small package but important for a real audio app.
- **hive + hive_flutter** — chose over sqflite/drift because the data is simple key-value stuff (journal entries, session snapshots). No relations, no queries beyond "get all sorted by date." Hive is faster to set up and doesn't need native SQLite binaries.
- **go_router** — Flutter team's recommended router. ShellRoute pattern made the persistent bottom nav trivial. Deep linking support is there if I needed it later.
- **google_fonts** — Inter is a clean sans-serif that works well at small sizes. Loading via google_fonts avoids bundling font files in the asset folder.
- **vibration** — needed raw control over vibration duration and amplitude patterns. The basic `HapticFeedback` in Flutter only gives you 3 presets, I wanted a full slider.
- **intl** — standard date formatting. `DateFormat('MMMM d, y • h:mm a')` kind of stuff.
- **uuid** — journal entries need unique IDs. UUID v4 is the simplest approach.
- **json_annotation** — model serialization for the ambience JSON. Keeps the parsing code out of the model class.

## Project structure

Feature-based layout. ~37 Dart files across:

```
lib/
├── main.dart                     # entry point, Hive init, AudioService init
├── router.dart                   # GoRouter + custom bottom nav bar
├── data/
│   ├── models/                   # AmbienceModel (HiveType 0), JournalEntryModel (HiveType 1)
│   └── repositories/             # ambience (JSON+cache), journal (Hive CRUD), session (Hive k/v)
├── features/
│   ├── ambience/                 # home screen, details screen, cards, search, filter chips
│   ├── sessions/                 # mood-based library screen
│   ├── player/                   # session controller, audio handler, player screen, mini player
│   ├── journal/                  # reflection screen, journal history, journal detail, mood selector
│   └── settings/                 # haptic intensity settings
└── shared/
    ├── theme/                    # light + dark themes, 30+ color tokens, theme toggle provider
    ├── providers/                # haptic settings (intensity + vibration engine)
    ├── utils/                    # time formatting
    └── widgets/                  # primary button, empty state, frosted glass container
```

Each feature owns its own controller, screens, and widgets — nothing leaks across boundaries. `shared/` has things every feature needs (theme, common widgets). `data/` is the only layer that touches storage or raw JSON.

## State management

Everything runs through Riverpod. The approach varies by what the provider is doing:

- **Data loading** uses `FutureProvider` — `ambiencesProvider` loads from JSON once and caches, `journalEntriesProvider` reads from Hive. These auto-dispose isn't needed because they represent app-level data.
- **Mutable state** uses `StateNotifierProvider` — `SessionController` manages the full playback lifecycle (play, pause, seek, timer tick, persist, end). `ReflectionController` holds the journal text + mood while the user is typing, then resets after save. This one is `autoDispose` so stale reflections don't carry over between sessions.
- **Simple filters** use `StateProvider` — search query, selected tag, journal tab index. Lightweight, no class needed.
- **Derived state** uses plain `Provider` — `filteredAmbiencesProvider` combines the raw ambience list with the current search + tag, recalculates reactively whenever either changes.

## How data flows (Repository → Controller → UI)

The pattern is the same everywhere: repositories are the only things that touch storage. Controllers call repository methods and hold the state. UI watches the controller's state via `ref.watch()`.

Concrete example — playing a session:

1. User taps "Start Session" on the ambience detail screen
2. UI calls `ref.read(sessionControllerProvider.notifier).startSession(ambience)`
3. `SessionController.startSession()` does three things:
   - Tells `AudioHandler` to load the MP3 from assets and call `play()`
   - Starts a 1-second timer that increments `elapsedSeconds`
   - Every 5 ticks, calls `SessionRepository.saveActiveSession()` to persist progress to Hive
4. UI rebuilds because `sessionControllerProvider`'s state changed (isPlaying, elapsed, etc.)
5. When the timer hits the ambience duration, controller calls `stop()` on the audio handler, clears the session from Hive, and the UI auto-navigates to the reflection screen

Journal flow is similar: reflection screen collects text + mood → `ReflectionController.saveReflection()` → `JournalRepository.addEntry()` → Hive box. Journal history screen watches `journalEntriesProvider` which reads from the same Hive box.

The key thing is nothing in `features/` imports Hive directly. All storage access goes through the `data/repositories/` layer.

## Persistence

Two Hive boxes:
- `journal_entries` — all reflections stored as `JournalEntryModel` objects (id, mood, text, ambience info, timestamp, duration, favorite status)
- `session_state` — saves the running session every 5 seconds (ambience ID, elapsed time, playing state). On next app launch it checks if the saved session is still valid and restores it.

Journal entries survive app restarts. Session state auto-clears when the session completes normally.

## UI notes

The whole UI leans into glassmorphism — frosted glass cards, gradient overlays, translucent borders. Pretty much every tappable element has a press-scale animation (shrinks to ~0.96x). The nav bar is custom-built (not Flutter's BottomNavigationBar) — pill-style items that expand with a label when active.

Color-wise, the primary accent is a burnt orange (`#E8652B`). Each mood tag has its own color: Focus=orange, Calm=green, Sleep=blue, Reset=gold. Those colors show up everywhere — card shadows, gradient headers, tag badges, player orb.

Typography is Inter via Google Fonts, with tighter letter spacing on headings.

## Navigation

3 tabs in the bottom nav (Home, Sessions, Journal) as a ShellRoute, plus detail/player/reflection/settings as push routes. Tab switches are instant (no transition animation), other routes use Cupertino-style slide transitions.

## Build

```bash
flutter analyze    # should show 0 issues
flutter test
flutter build apk --release
```

## Tradeoffs & what I'd do with two more days

**What's working well:** The core loop (browse → play → reflect → journal) is solid. Audio actually plays, sessions persist across app kills, the journal is fully functional with favorites. The UI is polished enough to feel like a real product.

**What I'd improve:**

1. **Testing** — There are no unit or widget tests right now beyond the default. First priority would be testing `SessionController` (timer logic, persistence save/restore, edge cases like ending a session at exactly 0 seconds left) and `JournalRepository` (CRUD, favorites toggle, getRecent filter). These are the two most critical paths and the ones most likely to have subtle bugs.

2. **Error handling on audio** — Right now if an audio file fails to load, the timer still starts and the user sees a "playing" session with silence. I'd add an error state to the session controller that the player screen listens for, and show a snackbar + auto-stop the session.

3. **Real images** — The ambience cards use gradient placeholders. I'd add actual ambient photography (forest, ocean, rain, etc.) with Hero transitions between the card and the detail screen. The `image` field already exists on the model, just needs real assets.

4. **App lifecycle handling** — The session timer should pause when the app goes to background and resume when it comes back. Right now it relies on `audio_service` keeping things alive, but on some OEMs the timer could drift. A `WidgetsBindingObserver` would fix this.

5. **Search in journal** — The journal only has tab filters right now. Full-text search across reflection text would be useful once you have more than ~20 entries.

6. **Accessibility** — I haven't tested with TalkBack or larger text sizes. All interactive elements need semantic labels, and the breathing animation should have a reduced-motion alternative.
