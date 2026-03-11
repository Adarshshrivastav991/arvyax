# ArvyaX — Immersive Ambient Session & Reflection App

> A premium, dark-mode-first Flutter application for ambient sound sessions, mood-based exploration, and post-session journaling. Built with clean architecture, Riverpod state management, and ultra-polished glassmorphism UI.

---

## Screenshots & Flow

```
Home (Browse)  →  Ambience Details  →  Session Player  →  Reflection  →  Journal
     ↕                                      ↕
Sessions Library (Mood-based)           Mini Player
     ↕
  Journal History  →  Journal Detail
     ↕
  Settings (Haptic Control)
```

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

**Requirements:** Flutter SDK ≥ 3.10.4 · Dart ≥ 3.10.4

```bash
# Build release APK
flutter build apk --release
```

---

## Complete Feature List

### 1. Home Screen — Ambience Browser
- SliverAppBar with gradient header and "ArvyaX" branding
- Real-time search bar with animated clear button
- Tag filter chips: **Focus** / **Calm** / **Sleep** / **Reset** with press-scale animation
- 2-column grid of ambience cards with radial glow overlays
- Section title with orange accent bar indicator
- Theme toggle (dark ↔ light) with rotation animation
- Settings gear icon for quick access
- Mini player docked at bottom when session is active

### 2. Sessions Library — Mood-Based Sound Library
- Dedicated tab with SliverAppBar (180px), gradient background, headphones icon
- **4 mood category cards** (horizontal scroll):
  - **Focus** — Orange gradient (`#E8652B → #FF8A65`)
  - **Calm** — Green gradient (`#6B8E7B → #81C784`)
  - **Sleep** — Blue gradient (`#5B6AAF → #7986CB`)
  - **Reset** — Gold gradient (`#D4A017 → #FFD54F`)
- Each mood expands into a horizontal session carousel
- Session count badge per mood ("X sessions")
- Quick-play button on each card (instant playback without going to details)
- Duration badge on each card
- Press-scale animation on every interactive card

### 3. Ambience Details Screen
- Hero image with tag-based gradient + radial glow + bottom fade
- Tag badge (Focus/Calm/Sleep/Reset) with colored icon
- Duration badge formatted in minutes
- Full description text with 1.6x line height
- **Sensory Recipe chips** — Each recipe ingredient gets a unique icon and color:
  - Breeze → air icon (blue), Warm Light → sun icon (gold), Mist → cloud icon (grey)
  - Binaural → headphones icon (purple), Rain → water icon (cyan), Waves → waves icon
  - White Noise → equalizer icon, Birdsong → music note (green), Thunder → flash icon
  - Fireplace → fire icon (red), Night Sounds → moon icon (indigo)
- "Start Session" button with gradient glow shadow
- Back button with frosted circle overlay
- Mini player visible if another session is running

### 4. Session Player — Full-Screen Audio Playback
- Breathing circle animation (6-second cycle, 0.85x → 1.0x scale) with radial glow + inner glow
- Tag-colored gradient orb (210px) with shadow bloom
- "NOW PLAYING" label with orange-accented tracking
- Tag badge pill below title
- **Seek bar** — Rounded track (5px), orange thumb, elapsed time highlighted in orange
- **Player controls** — Skip back 10s / Play-Pause (gradient button with AnimatedSwitcher) / Skip forward 10s
- Pill-shaped page indicator (active dot stretches to 20px)
- "END SESSION" outlined pill button
- End session confirmation dialog with cancel/end actions
- Top bar with rounded back/more containers
- Looping audio playback via `just_audio` with `LoopMode.all`

### 5. Mini Player (Persistent)
- Appears on Home, Sessions Library, Details, and Journal screens when a session is active
- Compact card with gradient play button + AnimatedSwitcher icon swap
- Title, subtitle, skip previous/next buttons
- Linear progress indicator synced to session timer
- Frosted glass styling with drop shadow
- Tap anywhere to open full player

### 6. Post-Session Reflection
- Prompt: "What is gently present with you right now?"
- Multiline text field (8 lines) with privacy note: "Shared only with you"
- **Mood selector** — 4 animated mood chips:
  - **Calm** (spa icon, peachy) · **Grounded** (landscape icon, tan)
  - **Energized** (bolt icon, green) · **Sleepy** (moon icon, lavender)
- Selected mood chip gets gradient fill + orange border
- Save button with loading spinner
- Auto-navigates to journal after save

### 7. Journal History
- Custom header with "Journal" title + "Your reflections & growth" subtitle
- **Pill-style tabs**: All / Recent (last 7 days) / Favorites
  - Active tab gets orange fill + border
- Chronological card list with:
  - Tag-colored gradient header with radial glow
  - Date + ambience title
  - Mood label in orange uppercase
  - Italicized reflection preview (3-line max)
  - Duration info + gradient "View Session" button with shadow
  - Favorite heart icon
- Empty state with icon + message when no entries exist

### 8. Journal Detail
- Expandable SliverAppBar (220px) with tag-based gradient hero
- Mood badge with icon + name
- Date/time formatted: "March 11, 2026 • 3:45 PM"
- Full reflection text at 1.8x line height
- **Session stats card**: Duration + Focus Score (80–99%)
- Edit Entry button (outline orange, haptic feedback)
- Copyright footer

### 9. Haptic Settings (Settings Screen)
- **Vibration intensity slider**: Logarithmic scale from 10 to 10,000
- Live percentage badge
- Dynamic intensity label with color coding:
  - Subtle (green) → Normal (green) → Strong (blue) → Ultra (blue) → Extreme (orange) → Mega (red) → INSANE (red)
- **5 quick presets**: Subtle (25) · Normal (100) · Strong (200) · Extreme (500) · Insane (2000)
- Test vibration button
- Haptic vibration profiles per intensity range:
  - `< 40`: Light pulse (10ms)
  - `40–80`: Normal (20ms)
  - `80–150`: Strong (30ms)
  - `150–300`: Double impact burst
  - `300–500`: Triple burst
  - `500–1000`: Rapid fire (4x pulses)
  - `> 1000`: Maximum intensity (6x pulses)

### 10. Dark / Light Theme Toggle
- System-independent toggle on home screen
- Full dual theme with 25+ semantic color tokens
- Rotation animation on toggle icon switch
- All screens, cards, nav bar, player adapt instantly

---

## Audio System

### Audio Files (5 ambient MP3 tracks)
| File | Mapped To |
|---|---|
| `forest.mp3` | Forest Focus, Misty Peaks |
| `ocean clam.mp3` | Ocean Calm |
| `Rain shelter.mp3` | Rain Shelter |
| `sunrise reset.mp3` | Sunrise Reset |
| `sleep.mp3` | Starlit Meadow |

### Audio Playback Stack
- **`just_audio`** — Core audio player engine (asset loading, seek, loop)
- **`audio_service`** — Background playback with Android notification controls
- **`audio_session`** — Audio focus management and interruption handling
- Loop mode: `LoopMode.all` (continuous ambient looping)
- Controls: Play, Pause, Stop, Seek, Rewind (−10s), FastForward (+10s)
- Session timer runs independently (1-second ticks), persists every 5 seconds to Hive
- Media notification with: Title, Artist ("ArvyaX"), Album (tag name), Duration

---

## Ambience Library (6 Sessions)

| ID | Title | Tag | Duration | Audio | Recipe |
|---|---|---|---|---|---|
| `forest_focus` | Forest Focus | Focus | 3 min | forest.mp3 | Breeze, Warm Light, Mist, Binaural |
| `ocean_calm` | Ocean Calm | Calm | 2.5 min | ocean clam.mp3 | Waves, Sea Breeze, Soft Rain |
| `rain_shelter` | Rain Shelter | Sleep | 3 min | Rain shelter.mp3 | Rain, Thunder, Fireplace |
| `sunrise_reset` | Sunrise Reset | Reset | 2 min | sunrise reset.mp3 | Warm Light, Birdsong, Breeze |
| `misty_peaks` | Misty Peaks | Focus | 2.5 min | forest.mp3 | Wind, Cool Mist, White Noise |
| `starlit_meadow` | Starlit Meadow | Sleep | 3 min | sleep.mp3 | Night Sounds, Cool Breeze, Binaural |

---

## Architecture

### Folder Structure

```
lib/
├── main.dart                       # App entry, Hive init, AudioService init, ProviderScope
├── router.dart                     # GoRouter config + custom bottom nav shell
├── data/
│   ├── models/
│   │   ├── ambience_model.dart     # @HiveType(0) — id, title, tag, duration, audio, recipe
│   │   ├── ambience_model.g.dart   # Generated Hive adapter
│   │   ├── journal_entry_model.dart # @HiveType(1) — mood, text, timestamps, stats
│   │   └── journal_entry_model.g.dart
│   └── repositories/
│       ├── ambience_repository.dart    # JSON loader with in-memory cache
│       ├── journal_repository.dart     # Hive CRUD — add, get, getAll, delete, getRecent
│       └── session_repository.dart     # Hive key-value — save/restore active session
├── features/
│   ├── ambience/
│   │   ├── controller/
│   │   │   └── ambience_controller.dart   # FutureProvider, search/tag StateProviders, filtered
│   │   ├── screens/
│   │   │   ├── home_screen.dart           # SliverAppBar, search, filter grid
│   │   │   └── ambience_details_screen.dart # Hero, recipe chips, start session
│   │   └── widgets/
│   │       ├── ambience_card.dart          # Animated card with radial glow
│   │       ├── search_bar.dart            # Glassmorphism search input
│   │       └── tag_filter_chip.dart       # Press-scale animated tag pill
│   ├── sessions/
│   │   └── screens/
│   │       └── sessions_library_screen.dart # Mood categories + horizontal session carousels
│   ├── player/
│   │   ├── controller/
│   │   │   └── session_controller.dart    # Play, pause, seek, timer, persist, end
│   │   ├── services/
│   │   │   └── audio_handler.dart         # BaseAudioHandler + just_audio bridge
│   │   ├── screens/
│   │   │   └── session_player_screen.dart # Breathing orb, controls, progress
│   │   └── widgets/
│   │       ├── player_controls.dart       # Gradient play button, skip buttons
│   │       ├── progress_bar.dart          # Custom slider with orange timer
│   │       └── mini_player.dart           # Compact persistent player card
│   ├── journal/
│   │   ├── controller/
│   │   │   └── journal_controller.dart    # ReflectionController + providers
│   │   ├── screens/
│   │   │   ├── reflection_screen.dart     # Mood selector + text input + save
│   │   │   ├── journal_history_screen.dart # Pill tabs + card list
│   │   │   └── journal_detail_screen.dart # Full entry with stats
│   │   └── widgets/
│   │       ├── journal_card.dart          # Entry preview with gradient header
│   │       └── mood_selector.dart         # 4-option animated mood picker
│   └── settings/
│       └── settings_screen.dart           # Haptic intensity + presets
└── shared/
    ├── theme/
    │   ├── app_theme.dart                 # Light + Dark ThemeData (Material 3)
    │   ├── colors.dart                    # 30+ semantic color tokens
    │   └── theme_provider.dart            # StateNotifier dark/light toggle
    ├── providers/
    │   └── haptic_settings_provider.dart  # Intensity manager + vibration engine
    ├── utils/
    │   └── time_formatter.dart            # MM:SS, "X min", "X MIN", "X Minutes"
    └── widgets/
        ├── primary_button.dart            # Gradient CTA with shadow + loading
        ├── empty_state.dart               # Icon + message + optional action
        └── frosted_glass.dart             # Reusable glassmorphism container
```

### State Management — Riverpod

| Provider | Type | Purpose |
|---|---|---|
| `ambiencesProvider` | `FutureProvider` | Loads 6 ambiences from `ambiences.json` |
| `filteredAmbiencesProvider` | `Provider` | Applies real-time search query + tag filter |
| `searchQueryProvider` | `StateProvider<String>` | Current search text |
| `selectedTagProvider` | `StateProvider<String?>` | Active tag filter (null = all) |
| `ambienceByIdProvider` | `FutureProvider.family` | Single ambience lookup by ID |
| `sessionControllerProvider` | `StateNotifierProvider` | Full session lifecycle: play, pause, seek, timer, persist |
| `reflectionControllerProvider` | `StateNotifierProvider` | Journal text + mood + save flow |
| `journalEntriesProvider` | `FutureProvider` | All persisted journal entries (sorted by date) |
| `recentEntriesProvider` | `FutureProvider` | Entries from last 7 days |
| `journalEntryByIdProvider` | `FutureProvider.family` | Single entry lookup |
| `journalTabProvider` | `StateProvider<int>` | Active journal tab index |
| `themeProvider` | `StateNotifierProvider` | Dark/light mode toggle |
| `hapticSettingsProvider` | `StateNotifierProvider` | Haptic intensity + vibration execution |

### Data Flow

```
assets/data/ambiences.json  ──→  AmbienceRepository (cache)  ──→  ambiencesProvider
                                                                        │
                                                              filteredAmbiencesProvider
                                                              (search + tag filter)
                                                                        │
                                                                   HomeScreen UI
                                                                        │
                                                              SessionController
                                                              (play, timer, persist)
                                                                        │
                                                                  ┌─────┴──────┐
                                                            AudioHandler    Hive Box
                                                            (just_audio)   (session_state)
                                                                  │
                                                            SessionPlayerScreen
                                                                  │
                                                            ReflectionController
                                                            (mood + text + save)
                                                                  │
                                                            JournalRepository
                                                            (Hive: journal_entries)
                                                                  │
                                                            JournalHistoryScreen
```

---

## Navigation (GoRouter)

| Route | Screen | Nav Bar |
|---|---|---|
| `/` | HomeScreen | ✅ Home |
| `/sessions` | SessionsLibraryScreen | ✅ Sessions |
| `/journal` | JournalHistoryScreen | ✅ Journal |
| `/ambience/:id` | AmbienceDetailsScreen | ❌ |
| `/player` | SessionPlayerScreen | ❌ |
| `/reflection/:ambienceId` | ReflectionScreen | ❌ |
| `/journal/:id` | JournalDetailScreen | ❌ |
| `/settings` | SettingsScreen | ❌ |

- **ShellRoute** wraps the 3 main tabs with persistent bottom nav
- **NoTransitionPage** used for tab switches (instant, no animation)
- Standard `CupertinoPageTransitionsBuilder` for push/pop routes

### Custom Bottom Navigation Bar
- Pill-style nav items with animated container expansion
- Active tab shows orange-tinted pill + label text
- Inactive tabs show only icon in muted color
- Haptic feedback on every tap
- Drop shadow + border blur for frosted glass effect
- Fully adaptive dark/light styling

---

## UI Design System

### Design Language
- **Glassmorphism** — Frosted glass cards with gradient fills and translucent borders
- **Material 3** — `useMaterial3: true` with InkSparkle ripple
- **Typography** — Google Fonts Inter (8 weight variants, -0.5 letter spacing for headings)
- **Border Radius** — 16px (nav pills), 20px (buttons), 24px (cards), 28px (search bar)
- **Shadows** — Colored shadows matching tag colors for depth perception

### Color Palette (30+ tokens)

| Token | Light | Dark | Usage |
|---|---|---|---|
| Primary | `#E8652B` | `#E8652B` | Buttons, accents, active states |
| Primary Light | `#F4845F` | `#F4845F` | Gradients, secondary accents |
| Background | `#F5F6F0` | `#1A1D21` | Scaffold background |
| Surface | `#FFFFFF` | `#252830` | Cards, inputs |
| Card | `#FFFFFF` | `#2C2F38` | Card backgrounds |
| Text Primary | `#1C2526` | `#F1F1F1` | Headings, body text |
| Text Secondary | `#6B7280` | `#9CA3AF` | Subtitles, captions |
| Focus Tag | `#E8652B` | — | Focus sessions |
| Calm Tag | `#6B8E7B` | — | Calm sessions |
| Sleep Tag | `#5B6AAF` | — | Sleep sessions |
| Reset Tag | `#D4A017` | — | Reset sessions |
| Player BG | `#DFE5DA` | `#1E2220` | Player screen background |

### Animations
- **Breathing orb** — 6s ease-in-out loop (0.85x → 1.0x scale) on player screen
- **Press scale** — 120ms ease-out-back (→0.92x–0.96x) on all cards, chips, and buttons
- **Theme toggle** — 300ms rotation transition on icon swap
- **Tab selection** — 250ms animated container (color, padding, border)
- **Play/Pause** — 200ms AnimatedSwitcher with crossfade
- **Filter chips** — 280ms gradient + border + shadow animation
- **Mood selector** — 250ms gradient fill + border width animation
- **Page dots** — AnimatedContainer (active dot stretches 6px → 20px)
- **Nav items** — 250ms padding + background pill expansion

---

## Technology Stack

### Framework & Language
| Technology | Version | Purpose |
|---|---|---|
| **Flutter** | ≥ 3.10.4 | Cross-platform UI framework |
| **Dart** | ≥ 3.10.4 | Programming language |
| **Material 3** | Built-in | Design system |

### Dependencies (12 packages)

| Package | Version | Purpose |
|---|---|---|
| **flutter_riverpod** | ^2.6.1 | State management — compile-safe providers, auto-dispose, reactive rebuilds |
| **riverpod_annotation** | ^2.6.1 | Code generation annotations for Riverpod |
| **just_audio** | ^0.9.42 | Audio engine — asset loading, seek, loop, position tracking |
| **audio_service** | ^0.18.15 | Background audio — system notification, media controls, foreground service |
| **audio_session** | ^0.1.21 | Audio focus — interruption handling, session category management |
| **vibration** | ^2.0.0 | Haptic engine — custom duration, amplitude, and pattern vibrations |
| **hive** | ^2.2.3 | Local database — fast NoSQL key-value store, no native deps |
| **hive_flutter** | ^1.1.0 | Hive Flutter integration — path provider, box management |
| **go_router** | ^14.8.1 | Navigation — declarative routing, ShellRoute, deep linking, path params |
| **google_fonts** | ^6.2.1 | Typography — Inter font family loaded on demand |
| **intl** | ^0.20.2 | Date formatting — "MMM d", "MMMM d, y • h:mm a" patterns |
| **uuid** | ^4.5.1 | UUID v4 generation for journal entry IDs |
| **json_annotation** | ^4.9.0 | JSON serialization annotations |
| **cupertino_icons** | ^1.0.8 | iOS-style icon set |

### Dev Dependencies

| Package | Version | Purpose |
|---|---|---|
| **flutter_test** | SDK | Widget and unit testing |
| **flutter_lints** | ^6.0.0 | Static analysis rules |

---

## Data Models

### AmbienceModel (Hive TypeId: 0)
```
id: String              # Unique slug (e.g., "forest_focus")
title: String           # Display name
tag: String             # Category: Focus, Calm, Sleep, Reset
duration: int           # Duration in seconds
description: String     # Full description text
image: String           # Asset path (placeholder)
audio: String           # Audio asset path (e.g., "assets/audio/forest.mp3")
recipe: List<String>    # Sensory recipe ingredients
```

### JournalEntryModel (Hive TypeId: 1)
```
id: String                    # UUID v4
ambienceId: String            # Linked ambience
ambienceTitle: String         # Denormalized title
ambienceImage: String         # Denormalized image path
ambienceTag: String           # Denormalized tag
mood: String                  # Calm, Grounded, Energized, Sleepy
reflectionText: String        # User journal text
createdAt: DateTime           # Timestamp
sessionDurationSeconds: int   # Actual session length
```

---

## Persistence (Hive Boxes)

| Box Name | Type | Contents |
|---|---|---|
| `journal_entries` | `Box<JournalEntryModel>` | All saved reflections, keyed by UUID |
| `session_state` | `Box<dynamic>` | Active session: ambienceId, elapsedSeconds, isPlaying, savedAt |

- Journal entries persist across app restarts
- Active session state saved every 5 seconds and restored on cold start
- Session auto-cleared when completed

---

## Platforms Supported

| Platform | Status |
|---|---|
| Android | ✅ Primary target |
| iOS | ✅ Configured |
| Web | ✅ Shell configured |
| macOS | ✅ Shell configured |
| Windows | ✅ Shell configured |
| Linux | ✅ Shell configured |

---

## Build & Analyze

```bash
# Run static analysis (should pass with 0 issues)
flutter analyze

# Run tests
flutter test

# Build release APK
flutter build apk --release

# Build iOS
flutter build ios --release
```
