//
//  iPodScreen.swift
//  AppPod
//

// MARK: - iPodScreen
//
// Enumerates every view the app can show. Serves as the element type for both
// `currentScreen` and the `navigationStack` array in iPodView, so the entire
// navigation state lives in a single [iPodScreen] array — no separate view-stack
// manager is needed.
//
// Associated values on detail cases (.albumDetail, .artistDetail, etc.) carry the
// item being drilled into, making each screen transition fully data-driven.
//
// Hashable conformance lets the enum be used as Dictionary keys in `selectionMemory`,
// giving O(1) save/restore of each screen's scroll position when navigating back.
enum iPodScreen: Equatable, Hashable {
    case menu
    case nowPlaying
    case songs
    case albums
    case artists
    case playlists
    case albumDetail(AppAlbum)
    case playlistDetail(AppPlaylist)
    case artistDetail(AppArtist)
    case podcasts
    case podcastDetail(PodcastShow)
    case settings
    case themeSelection
    case screenSizeSelection
    case highlightColorSelection
    case scrollSensitivitySelection
    case clickSoundSelection
    case backlightDurationSelection
    case recentlyAdded
    case recentlyPlayed
    case about
}
