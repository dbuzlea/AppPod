# AppPod

A SwiftUI iOS app that recreates the authentic iPod Classic experience — touch-based click wheel, navigation stack with selection memory, 29 themes, and full Apple Music library integration.

## Features

### Core iPod Experience
- **Touch-Based Click Wheel** — Circular drag gesture for scrolling; tap zones for Menu, Play/Pause, Previous, Next, and center Select
- **Navigation Stack** — Menu button acts as a true back button, tracking full navigation history
- **Selection Memory** — Every screen remembers your scroll position when you return to it
- **Hold Switch** — Toggle at top-right of device; orange indicator locks all input
- **Configurable Backlight** — Auto-off timer selectable: 5s / 10s / 30s / Always On; any touch wakes it
- **Haptic Feedback** — Light ticks on scroll, medium on selection, heavy on center press, rigid on boundary hits
- **Shake to Shuffle** — Shake the device to instantly shuffle all songs and jump to Now Playing

### Visual Polish
- **Glass Screen Overlay** — Gyroscope-driven AR-tinted caustics, animated shimmer, micro-texture grain, and chromatic fringing simulate real glass
- **Screen Parallax** — Content shifts counter to device tilt via CoreMotion, reinforcing the depth gap between display and glass
- **Selection Bar Refraction** — Highlighted rows show glass-edge light refraction for a physical feel

### Playback
- **Apple Music Library** — Browse and play Songs, Albums, Artists, Playlists, and Podcasts via MusicKit + MPMediaPlayer
- **Track Scrubbing** — Rotate the wheel on Now Playing to seek ±5 seconds per tick; scrubbing indicator shown on the progress bar
- **Repeat Mode** — Off / All / One, toggled via Center button on the Repeat row in Now Playing
- **Shuffle Mode** — Off / Songs, toggled via Center button on the Shuffle row in Now Playing
- **Global Play/Pause** — Works from any screen, not just Now Playing
- **Cover Flow** — Rotate to landscape to browse Albums, Playlists, or Podcasts with cover art

### Themes — 29 Built-In
| Category | Themes |
|----------|--------|
| Classic | Classic White, Classic Black, Classic Silver, U2 Black & Red |
| Special | Black & White, Green Screen, Color Screen, iPod Nano |
| iPod Mini | Silver, Gold, Blue, Pink, Green |
| iPod Nano | Silver, Black, Space Gray, Blue, Pink, Purple, Green, Yellow, Orange, Red |
| iPod Shuffle | Silver, Blue, Pink, Green, Orange, Purple, Gold |

Each theme styles the iPod body gradient, screen background, text colors, highlight color, and click wheel.

### Settings
| Setting | Options |
|---------|---------|
| Theme | 29 built-in themes |
| Screen Size | Auto (match theme) + 6 manual presets (Tiny → Extra Large) |
| Highlight Color | Default or 16 custom finish colors |
| Scroll Sensitivity | Low / Medium / High |
| Click Sound | On / Off |
| Backlight | 5 Seconds / 10 Seconds / 30 Seconds / Always On |
| About | App version info |

---

## Requirements

- iOS 17.0+
- Xcode 16.0+
- Apple Developer account (for MusicKit capability)
- Physical iOS device (MusicKit requires a real device for full library access)
- Apple Music library (local or streamed)

---

## Setup

### 1. Add MusicKit Capability

1. Open `AppPod.xcodeproj` in Xcode
2. Select the **AppPod** target
3. Go to **Signing & Capabilities**
4. Click **+ Capability** and add **MusicKit**
5. Set your Team in Signing

### 2. Verify Info.plist Keys

The following usage description keys are required (already present in `Info.plist`):

```xml
<key>NSAppleMusicUsageDescription</key>
<string>AppPod needs access to your Apple Music library to display and play your music.</string>

<key>NSMicrophoneUsageDescription</key>
<string>...</string>
```

### 3. Build and Run

1. Select a physical iOS device as the run destination
2. Build and run (`⌘R`)
3. Grant Apple Music permission when prompted
4. Navigate with the click wheel

---

## How to Use

### Click Wheel

| Gesture / Button | Action |
|------------------|--------|
| Circular drag — clockwise | Scroll down |
| Circular drag — counter-clockwise | Scroll up |
| Tap top zone (MENU) | Go back |
| Tap bottom zone (PLAY) | Toggle Play/Pause |
| Tap left zone (PREV) | Restart track or skip to previous |
| Tap right zone (NEXT) | Skip to next track |
| Center circle (SELECT) | Select / confirm |

### Now Playing Screen

| Action | How |
|--------|-----|
| Seek forward | Clockwise wheel rotation |
| Seek backward | Counter-clockwise wheel rotation |
| Toggle Shuffle | Scroll to Shuffle row → press Center |
| Cycle Repeat | Scroll to Repeat row → press Center |

### Main Menu Structure

```
Menu
├── Now Playing
├── Songs
├── Albums
├── Artists
├── Playlists
├── Podcasts
└── Settings
    ├── Theme
    ├── Screen Size
    ├── Highlight Color
    ├── Scroll Sensitivity
    ├── Click Sound
    ├── Backlight
    └── About
```

### Cover Flow

Rotate the device to landscape while browsing Albums, Playlists, or Podcasts to enter Cover Flow mode. Swipe left/right to browse covers, tap to select.

### Shake to Shuffle

Shake the device from any screen (with Hold disabled) to immediately shuffle all songs and navigate to Now Playing.

---

## Architecture

```
AppPod/
├── Models/
│   ├── AppMusicModels.swift       # AppTrack, AppAlbum, AppArtist wrappers
│   ├── ModelsiPodScreen.swift     # iPodScreen enum (all navigation states)
│   ├── ModelsSelectionState.swift # SelectionState struct for memory
│   ├── ModelsRepeatMode.swift     # RepeatMode enum
│   ├── ModelsShuffleMode.swift    # ShuffleMode enum
│   ├── iPodTheme.swift            # Theme colors + factory
│   ├── ThemeiPodThemeStyle.swift  # 29 theme cases + defaultScreenSize
│   ├── ThemeScreenSize.swift      # 6 screen size presets
│   └── iPodColors.swift           # Finish color palette
├── Services/
│   ├── MusicService.swift         # MusicKit + MPMediaPlayer integration
│   ├── AppHelpers.swift           # Shared utilities (time formatting, etc.)
│   └── AppMetrics.swift           # MetricKit crash/hang/performance monitoring
└── ViewModels/
    ├── iPodView.swift             # Root view — state, layout, orientation, shake
    ├── ClickWheelView.swift       # Wheel gestures, button handlers, navigation logic
    ├── iPodScreenView.swift       # Screen content router
    ├── ModelsThemeSettings.swift  # ThemeSettings + BacklightDuration + ScrollSensitivity
    ├── SelectionHighlightModifier.swift  # Glass-edge refraction on selection bars
    ├── NowPlayingView.swift       # Now Playing screen
    ├── MainMenuView.swift         # Main menu
    ├── SongListView.swift         # Songs list
    ├── AlbumListView.swift        # Albums list
    ├── AlbumDetailView.swift      # Album track list
    ├── ArtistListView.swift       # Artists list
    ├── ArtistDetailView.swift     # Artist album list
    ├── PlaylistListView.swift     # Playlists list
    ├── PlaylistDetailView.swift   # Playlist track list
    ├── PodcastListView.swift      # Podcasts list
    ├── PodcastDetailView.swift    # Podcast episode list
    ├── SettingsView.swift         # All settings sub-screens
    ├── AlphabetScrubberView.swift # A–Z side scrubber for long lists
    ├── CoverFlowView.swift        # Landscape cover art browser
    └── HoldSwitchView.swift       # Hold switch toggle
```

### Key Design Decisions

- **No Combine** — All async work uses Swift async/await
- **MusicKit for catalog**, **MPMediaPlayer for local playback** — both are handled in `MusicService`
- **Navigation is a stack** (`[iPodScreen]`) managed in `iPodView`, operated by `ClickWheelView` via bindings
- **Selection memory** is a `[iPodScreen: SelectionState]` dictionary — O(1) save/restore on every screen transition
- **ThemeSettings** is a class stored in `@State` in `iPodView` and passed down as a reference — changes propagate immediately
- **Glass overlay** (`ScreenGlassView`) is isolated to its own view so only it re-renders at 60 fps on gyroscope updates
- **MetricKit** (`AppMetrics`) is registered on launch and logs crash/hang diagnostics to the unified log

---

## Adding a New Theme

See [`Docs/ADD-NEW-THEME-GUIDE.md`](Docs/ADD-NEW-THEME-GUIDE.md) for a step-by-step guide. The short version:

1. Add a case to `iPodThemeStyle` in `Models/ThemeiPodThemeStyle.swift`
2. Add a `case` in `iPodTheme.theme(for:)` in `Models/iPodTheme.swift`
3. Build — your theme appears in Settings → Theme automatically

---

## Troubleshooting

**"No songs in library"**
- Grant Apple Music permission in Settings → Privacy → Media & Apple Music
- Make sure your Apple Music library has songs (local files or iCloud Music Library)

**Click wheel not responding**
- Swipe in a circular arc around the outer ring, not the center button
- Adjust sensitivity in Settings → Scroll Sensitivity

**Playback doesn't start**
- MusicKit requires an active internet connection for streamed content
- Verify you're signed in to Apple Music in Settings

**Hold switch stuck**
- Tap the orange toggle at the top of the device to unlock

**Screen stays dim**
- Go to Settings → Backlight and increase the duration or set it to Always On

---

## Documentation

All feature docs are in [`AppPod/Docs/`](Docs/):

| File | Contents |
|------|----------|
| `CLASSIC-IPOD-BEHAVIORS.md` | Complete reference for all iPod behaviors |
| `QUICK-REFERENCE.md` | Controls cheat sheet |
| `ADD-NEW-THEME-GUIDE.md` | How to add a custom theme |
| `BUTTON-LAYOUT-REFERENCE.md` | Click wheel geometry and specs |
| `SELECTION-MEMORY-ARCHITECTURE.md` | How navigation memory works |

---

## License

This project is for educational and personal use. iPod, Apple Music, and MusicKit are trademarks of Apple Inc. This app is not affiliated with or endorsed by Apple.

## Credits

Built with SwiftUI, MusicKit, MediaPlayer, CoreMotion, and MetricKit.  
Classic iPod design inspired by Apple's iconic music player from 2001–2014.
