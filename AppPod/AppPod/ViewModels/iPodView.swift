//
//  iPodView.swift
//  AppPod
//
//  Created by Daniel Buzlea on 5/13/26.
//

import SwiftUI
import MusicKit
import CoreMotion
import OSLog

private let logger = Logger(subsystem: "com.apppod", category: "iPodView")

// MARK: - iPodView
//
// Root container that assembles the complete iPod interface. It owns all navigation
// and selection state, delegates gesture interpretation to ClickWheelView, and
// composes the visual layers (body gradient, screen, glass overlay, click wheel,
// hold switch). Key responsibilities:
//
// Navigation state
//   `currentScreen` — the active iPodScreen enum case
//   `navigationStack` — history stack for the back button
//   `selectionMemory` — [iPodScreen: SelectionState] for O(1) cursor save/restore
//
// Backlight management
//   Any click wheel interaction calls `resetBacklightTimer()`, which restarts a
//   Timer that fades the screen dark after the configured BacklightDuration. The
//   timer is cancelled when the duration is set to "Always On".
//
// Cover Flow
//   Landscape orientation triggers `handleOrientationChange()`, which locks the
//   interface orientation to landscape and presents CoverFlowView as a fullScreenCover.
//   Returning to portrait dismisses Cover Flow and navigates to Now Playing.
//
// Shake to Shuffle
//   ShakeDetector (UIViewControllerRepresentable) delivers shake events to
//   `handleShake()`, which shuffles all songs and starts playback if hold is off.
//
// Glass screen effects
//   ScreenParallaxWrapper shifts the screen content slightly opposite to device tilt
//   (CoreMotion roll/pitch), simulating depth between the display and the glass.
//   ScreenGlassView (isolated in its own @Observable MotionManager) renders the
//   glass surface effects at 60 fps without causing the parent view to re-render.

// MARK: - Motion Manager

@Observable
private final class MotionManager {
    private let manager = CMMotionManager()
    var roll:  Double = 0
    var pitch: Double = 0

    func start() {
        guard manager.isDeviceMotionAvailable else { return }
        manager.deviceMotionUpdateInterval = 1.0 / 60.0
        manager.startDeviceMotionUpdates(to: .main) { [weak self] motion, _ in
            guard let m = motion else { return }
            self?.roll  = m.attitude.roll
            self?.pitch = m.attitude.pitch
        }
    }

    func stop() { manager.stopDeviceMotionUpdates() }
}

// Simple LCG — deterministic noise without importing GameplayKit
private struct SeededRNG {
    private var state: UInt64
    init(seed: UInt64) { state = seed }
    mutating func next() -> Double {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return Double(state >> 33) / Double(UInt32.max)
    }
}

// MARK: - Glass Overlay (isolated so only this view re-renders at 60 fps)

private struct ScreenGlassView: View {
    @State private var motion       = MotionManager()
    @State private var shimmerPhase: CGFloat = 0.02  // animated 0.02 → 0.98

    var body: some View {
        let roll     = motion.roll
        let pitch    = motion.pitch
        // Anti-reflective coating produces a characteristic blue-green tint in reflected light
        let arTint   = Color(red: 0.82, green: 0.93, blue: 1.0)

        // Primary caustic (top-left, tracks tilt)
        let causticX  = min(max(0.08 + roll  * 0.25, 0.0),  0.55)
        let causticY  = min(max(0.05 - pitch * 0.15, 0.0),  0.40)
        // Counter-caustic (bottom-right, moves opposite to primary)
        let caustic2X = min(max(0.92 - roll  * 0.20, 0.50), 1.00)
        let caustic2Y = min(max(0.92 + pitch * 0.12, 0.60), 1.00)
        // Per-edge convex vignette
        let topV      = min(max(0.22 + pitch * 0.12, 0.05), 0.40)
        let botV      = min(max(0.18 - pitch * 0.12, 0.05), 0.35)
        let leftV     = min(max(0.18 - roll  * 0.12, 0.05), 0.35)
        let rightV    = min(max(0.18 + roll  * 0.12, 0.05), 0.35)
        // Top specular
        let topSpec   = min(max(0.55 - pitch * 0.28, 0.05), 0.85)
        let topSpec2  = min(max(0.28 - pitch * 0.14, 0.02), 0.45)
        // Glare stripe
        let glareX0   = min(max(0.0  - roll  * 0.4, -0.3),  0.4)
        let glareX1   = min(max(1.0  - roll  * 0.4,  0.6),  1.4)
        let glareY1   = min(max(0.55 + pitch * 0.20,  0.3),  0.8)
        // Animated shimmer band — sweeps diagonally independent of tilt
        let shimmer   = max(0.02, min(0.98, shimmerPhase))
        let shimmerL  = max(0.001, shimmer - 0.11)
        let shimmerT  = min(0.999, shimmer + 0.11)
        // Tilt-responsive rim: light source angle tracks device attitude
        let rimAngle  = atan2(roll, -pitch)
        let rimSX     = 0.5 - 0.6 * sin(rimAngle)
        let rimSY     = 0.5 - 0.6 * cos(rimAngle)
        let rimEX     = 0.5 + 0.6 * sin(rimAngle)
        let rimEY     = 0.5 + 0.6 * cos(rimAngle)
        // Tilt-responsive chromatic fringing: split scales with viewing angle
        let chromaX   = min(max(CGFloat(roll  *  1.2), -1.5), 1.5)
        let chromaY   = min(max(CGFloat(-pitch * 0.8), -1.2), 1.2)
        // Corner subsurface glow: warm scatter, each corner brightens when facing light
        let cornerTint = Color(red: 1.0, green: 0.97, blue: 0.88)
        let tlGlow    = min(max(0.05 + (-roll  + -pitch) * 0.04, 0.01), 0.10)
        let trGlow    = min(max(0.05 + ( roll  + -pitch) * 0.04, 0.01), 0.10)
        let blGlow    = min(max(0.05 + (-roll  +  pitch) * 0.04, 0.01), 0.10)
        let brGlow    = min(max(0.05 + ( roll  +  pitch) * 0.04, 0.01), 0.10)

        return ZStack {
            // ── Convex vignette ──────────────────────────────────────────
            LinearGradient(stops: [.init(color: .black.opacity(topV),   location: 0), .init(color: .clear, location: 0.30)], startPoint: .top,      endPoint: .bottom)
            LinearGradient(stops: [.init(color: .black.opacity(botV),   location: 0), .init(color: .clear, location: 0.28)], startPoint: .bottom,   endPoint: .top)
            LinearGradient(stops: [.init(color: .black.opacity(leftV),  location: 0), .init(color: .clear, location: 0.20)], startPoint: .leading,  endPoint: .trailing)
            LinearGradient(stops: [.init(color: .black.opacity(rightV), location: 0), .init(color: .clear, location: 0.20)], startPoint: .trailing, endPoint: .leading)

            // ── Top specular band (AR-tinted) ─────────────────────────────
            LinearGradient(
                stops: [
                    .init(color: arTint.opacity(topSpec),  location: 0),
                    .init(color: arTint.opacity(topSpec2), location: 0.05),
                    .init(color: arTint.opacity(0.06),     location: 0.20),
                    .init(color: .clear,                   location: 0.42)
                ],
                startPoint: .top, endPoint: .bottom
            )

            // ── Diagonal glare stripe (AR-tinted, gyroscope-driven) ───────
            LinearGradient(
                stops: [
                    .init(color: .clear,               location: 0),
                    .init(color: arTint.opacity(0.09), location: 0.38),
                    .init(color: arTint.opacity(0.14), location: 0.47),
                    .init(color: arTint.opacity(0.09), location: 0.56),
                    .init(color: .clear,               location: 1.0)
                ],
                startPoint: UnitPoint(x: glareX0, y: 0.0),
                endPoint:   UnitPoint(x: glareX1, y: glareY1)
            )

            // ── Primary corner caustic (AR-tinted, gyroscope-driven) ──────
            RadialGradient(
                stops: [
                    .init(color: arTint.opacity(0.48), location: 0),
                    .init(color: arTint.opacity(0.12), location: 0.4),
                    .init(color: .clear,               location: 1)
                ],
                center: UnitPoint(x: causticX, y: causticY),
                startRadius: 0, endRadius: 60
            )

            // ── Counter-caustic — bottom-right, counter-moves with tilt ──
            RadialGradient(
                stops: [
                    .init(color: arTint.opacity(0.18), location: 0),
                    .init(color: arTint.opacity(0.04), location: 0.5),
                    .init(color: .clear,               location: 1)
                ],
                center: UnitPoint(x: caustic2X, y: caustic2Y),
                startRadius: 0, endRadius: 50
            )

            // ── Slow ambient shimmer — sweeps NW→SE every 8 seconds ───────
            LinearGradient(
                stops: [
                    .init(color: .clear,               location: 0),
                    .init(color: .clear,               location: shimmerL),
                    .init(color: arTint.opacity(0.13), location: shimmer),
                    .init(color: .clear,               location: shimmerT),
                    .init(color: .clear,               location: 1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // ── Bottom reflection (AR-tinted) ─────────────────────────────
            LinearGradient(
                stops: [.init(color: .clear, location: 0.82), .init(color: arTint.opacity(0.06), location: 1.0)],
                startPoint: .top, endPoint: .bottom
            )

            // ── Corner subsurface glow — warm scatter through glass corners ──
            RadialGradient(stops: [.init(color: cornerTint.opacity(tlGlow), location: 0), .init(color: .clear, location: 1)], center: .topLeading,     startRadius: 0, endRadius: 35)
            RadialGradient(stops: [.init(color: cornerTint.opacity(trGlow), location: 0), .init(color: .clear, location: 1)], center: .topTrailing,    startRadius: 0, endRadius: 35)
            RadialGradient(stops: [.init(color: cornerTint.opacity(blGlow), location: 0), .init(color: .clear, location: 1)], center: .bottomLeading,  startRadius: 0, endRadius: 35)
            RadialGradient(stops: [.init(color: cornerTint.opacity(brGlow), location: 0), .init(color: .clear, location: 1)], center: .bottomTrailing, startRadius: 0, endRadius: 35)

            // ── Micro-texture grain — seeded so dots are static, not flickering ──
            Canvas { context, size in
                var rng = SeededRNG(seed: 42)
                for _ in 0..<320 {
                    let x = CGFloat(rng.next()) * size.width
                    let y = CGFloat(rng.next()) * size.height
                    let r = CGFloat(rng.next()) * 0.55 + 0.25
                    let a = 0.03 + CGFloat(rng.next()) * 0.055
                    context.fill(
                        Path(ellipseIn: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2)),
                        with: .color(.white.opacity(a))
                    )
                }
            }
            .blendMode(.overlay)
            .allowsHitTesting(false)

            // ── Chromatic fringing — split direction and magnitude track tilt ──
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.red.opacity(0.07),  lineWidth: 2.0)
                .offset(x: -0.4 - chromaX, y: -0.4 - chromaY)
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.cyan.opacity(0.07), lineWidth: 2.0)
                .offset(x:  0.4 + chromaX, y:  0.4 + chromaY)

            // ── Glass slab rim — highlight hotspot orbits with light source ─
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black.opacity(0.22), lineWidth: 6)
                .blur(radius: 4)
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    LinearGradient(
                        stops: [
                            .init(color: arTint.opacity(0.90), location: 0.00),
                            .init(color: arTint.opacity(0.65), location: 0.25),
                            .init(color: .white.opacity(0.45), location: 0.50),
                            .init(color: .white.opacity(0.30), location: 0.75),
                            .init(color: .white.opacity(0.45), location: 0.88),
                            .init(color: arTint.opacity(0.90), location: 1.00)
                        ],
                        startPoint: UnitPoint(x: CGFloat(rimSX), y: CGFloat(rimSY)),
                        endPoint:   UnitPoint(x: CGFloat(rimEX), y: CGFloat(rimEY))
                    ),
                    lineWidth: 2.5
                )
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .allowsHitTesting(false)
        .onAppear {
            motion.start()
            withAnimation(.linear(duration: 8.0).repeatForever(autoreverses: false)) {
                shimmerPhase = 0.98
            }
        }
        .onDisappear { motion.stop() }
    }
}

// MARK: - Parallax Wrapper (content shifts opposite glass highlights, selling the depth gap)

private struct ScreenParallaxWrapper<Content: View>: View {
    @State private var motion = MotionManager()
    let content: Content

    init(@ViewBuilder _ content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            // Content moves opposite to the glass reflection: when you tilt right
            // the highlights shift right but the "deeper" display appears to drift left.
            .offset(
                x: CGFloat(-motion.roll  * 7.0),
                y: CGFloat(-motion.pitch * 5.0)
            )
            // Perspective warp simulates looking through curved glass edges —
            // near edge appears slightly larger, far edge smaller, like a convex lens.
            .rotation3DEffect(.degrees(motion.pitch * 2.0), axis: (1, 0, 0), perspective: 0.5)
            .rotation3DEffect(.degrees(-motion.roll  * 1.5), axis: (0, 1, 0), perspective: 0.5)
            .onAppear    { motion.start() }
            .onDisappear { motion.stop()  }
    }
}

// MARK: - Shake Detection

private struct ShakeDetector: UIViewControllerRepresentable {
    let onShake: () -> Void

    func makeUIViewController(context: Context) -> ShakeViewController {
        let vc = ShakeViewController()
        vc.onShake = onShake
        return vc
    }

    func updateUIViewController(_ uiViewController: ShakeViewController, context: Context) {
        uiViewController.onShake = onShake
    }
}

private final class ShakeViewController: UIViewController {
    var onShake: (() -> Void)?

    override var canBecomeFirstResponder: Bool { true }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        becomeFirstResponder()
    }

    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake { onShake?() }
    }
}

struct iPodView: View {
    @ObservedObject var musicService: MusicService
    @State private var themeSettings = ThemeSettings()
    @State private var currentScreen: iPodScreen = .menu
    @State private var navigationStack: [iPodScreen] = []
    @State private var selectionMemory: [iPodScreen: SelectionState] = [:]
    @State private var menuSelection: Int = 0
    @State private var songSelection: Int = 0
    @State private var detailSelection: Int = 0
    @State private var rotation: Double = 0
    @State private var isHoldEnabled = false
    @State private var isBacklightOn = true
    @State private var backlightTimer: Timer?
    @State private var showCoverFlow = false
    @State private var coverFlowMode: CoverFlowMode = .albums
    // Tracks the index selected in Cover Flow independently of menu navigation
    @State private var coverFlowIndex: Int = 0
    @State private var playlistCoverFlowIndex: Int = 0
    @State private var podcastCoverFlowIndex: Int = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                bodyGradient
                    .ignoresSafeArea()

                iPodControls
                    .scaleEffect(layoutScale(for: geometry.size), anchor: .top)
                    .frame(
                        width: geometry.size.width,
                        height: geometry.size.height,
                        alignment: .top
                    )
            }
        }
        .background(ShakeDetector { handleShake() })
        .ignoresSafeArea()
        .onAppear {
            resetBacklightTimer()
            UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        }
        .onDisappear {
            UIDevice.current.endGeneratingDeviceOrientationNotifications()
        }
        .onReceive(
            NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
        ) { _ in
            handleOrientationChange()
        }
        .fullScreenCover(isPresented: $showCoverFlow) {
            switch coverFlowMode {
            case .albums:
                CoverFlowView(
                    content: .albums(musicService.albums),
                    musicService: musicService,
                    selectedIndex: $coverFlowIndex,
                    onDismiss: { forcePortrait(); showCoverFlow = false }
                )
            case .playlists:
                CoverFlowView(
                    content: .playlists(Array(musicService.playlists)),
                    musicService: musicService,
                    selectedIndex: $playlistCoverFlowIndex,
                    onDismiss: { forcePortrait(); showCoverFlow = false }
                )
            case .podcasts:
                CoverFlowView(
                    content: .podcasts(musicService.podcastShows),
                    musicService: musicService,
                    selectedIndex: $podcastCoverFlowIndex,
                    onDismiss: { forcePortrait(); showCoverFlow = false }
                )
            }
        }
    }

    private var iPodControls: some View {
        VStack(spacing: 12) {
            // Top section with hold switch
            HStack {
                HoldSwitchView(isEnabled: $isHoldEnabled)
                    .padding(.leading, 20)
                Spacer()
            }
            .padding(.top, 52)

            // Screen
            VStack {
                ScreenParallaxWrapper {
                    iPodScreenView(
                        currentScreen: currentScreen,
                        musicService: musicService,
                        themeSettings: themeSettings,
                        menuSelection: $menuSelection,
                        songSelection: $songSelection,
                        detailSelection: $detailSelection,
                        isBacklightOn: isBacklightOn
                    )
                }
                .frame(width: themeSettings.screenSize.dimensions.width,
                       height: themeSettings.screenSize.dimensions.height)
                .background(screenGradient)
                .cornerRadius(12)
                .overlay { screenGlassOverlay }
                .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
                .padding(.horizontal, 30)
                .animation(.easeInOut(duration: 0.3), value: themeSettings.screenSize)
                .animation(.easeInOut(duration: 0.5), value: isBacklightOn)
            }

            Spacer()

            // Click wheel
            ClickWheelView(
                rotation: $rotation,
                musicService: musicService,
                themeSettings: themeSettings,
                currentScreen: $currentScreen,
                navigationStack: $navigationStack,
                selectionMemory: $selectionMemory,
                menuSelection: $menuSelection,
                songSelection: $songSelection,
                detailSelection: $detailSelection,
                isHoldEnabled: isHoldEnabled,
                onInteraction: resetBacklightTimer
            )
            .frame(width: themeSettings.screenSize.wheelSize,
                   height: themeSettings.screenSize.wheelSize)
            .animation(.easeInOut(duration: 0.3), value: themeSettings.screenSize)
            .padding(.bottom, 40)
        }
    }

    private var bodyGradient: some View {
        LinearGradient(
            colors: [
                themeSettings.currentTheme.bodyGradientStart,
                themeSettings.currentTheme.bodyGradientEnd
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var screenGradient: some View {
        LinearGradient(
            colors: isBacklightOn ?
                themeSettings.currentTheme.screenBackgroundLight :
                themeSettings.currentTheme.screenBackgroundDark,
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private var screenGlassOverlay: some View { ScreenGlassView() }

    private func layoutScale(for size: CGSize) -> CGFloat {
        let estimatedHoldSwitchHeight: CGFloat = 28
        let fixedVerticalSpacing: CGFloat = 12 + 12 + 52 + 40
        let contentHeight = estimatedHoldSwitchHeight +
            themeSettings.screenSize.dimensions.height +
            themeSettings.screenSize.wheelSize +
            fixedVerticalSpacing

        guard contentHeight > size.height else { return 1 }
        return max(0.78, size.height / contentHeight)
    }

    // MARK: - Orientation Handling

    private func handleOrientationChange() {
        let orientation = UIDevice.current.orientation
        // Ignore ambiguous orientations (face up/down/unknown)
        guard orientation != .faceUp,
              orientation != .faceDown,
              orientation != .unknown else { return }

        if orientation.isLandscape && !showCoverFlow {
            AppDelegate.orientationLock = .landscape
            switch currentScreen {
            case .playlists, .playlistDetail:
                coverFlowMode = .playlists
            case .podcasts, .podcastDetail:
                coverFlowMode = .podcasts
            case .nowPlaying:
                break // preserve last coverFlowMode when returning from cover flow
            default:
                coverFlowMode = .albums
            }
            switch coverFlowMode {
            case .albums:
                if let track = musicService.currentTrack,
                   let idx = musicService.albums.firstIndex(where: { $0.title == track.albumTitle }) {
                    coverFlowIndex = idx
                }
            case .playlists:
                if let playlistID = musicService.currentPlaylistID,
                   let idx = musicService.playlists.firstIndex(where: { $0.id == playlistID }) {
                    playlistCoverFlowIndex = idx
                }
            case .podcasts:
                if let showTitle = musicService.currentPodcastShowTitle,
                   let idx = musicService.podcastShows.firstIndex(where: { $0.title == showTitle }) {
                    podcastCoverFlowIndex = idx
                }
            }
            logger.info("Cover Flow opened: \(String(describing: coverFlowMode))")
            showCoverFlow = true
        } else if orientation.isPortrait && showCoverFlow {
            logger.info("Cover Flow dismissed, returning to now playing")
            showCoverFlow = false
            AppDelegate.orientationLock = .portrait
            navigateTo(.nowPlaying)
        }
    }

    private func forcePortrait() {
        AppDelegate.orientationLock = .portrait
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            scene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
            scene.keyWindow?.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
        }
    }

    // MARK: - Navigation Helpers

    private func saveCurrentSelectionState() {
        let state = SelectionState(
            menuSelection: menuSelection,
            songSelection: songSelection,
            detailSelection: detailSelection
        )
        selectionMemory[currentScreen] = state
    }

    private func restoreSelectionState(for screen: iPodScreen) {
        if let savedState = selectionMemory[screen] {
            menuSelection = savedState.menuSelection
            songSelection = savedState.songSelection
            detailSelection = savedState.detailSelection
        } else {
            menuSelection = 0
            songSelection = 0
            detailSelection = 0
        }
    }

    private func navigateTo(_ screen: iPodScreen) {
        logger.debug("Navigate: \(String(describing: currentScreen)) → \(String(describing: screen))")
        saveCurrentSelectionState()
        navigationStack.append(currentScreen)
        currentScreen = screen
        restoreSelectionState(for: screen)
    }

    private func navigateBack() {
        guard !navigationStack.isEmpty else { return }
        let destination = navigationStack.last ?? .menu
        logger.debug("Navigate back: \(String(describing: currentScreen)) → \(String(describing: destination))")
        saveCurrentSelectionState()
        currentScreen = navigationStack.removeLast()
        restoreSelectionState(for: currentScreen)
    }

    // MARK: - Backlight Management

    private func resetBacklightTimer() {
        isBacklightOn = true
        backlightTimer?.invalidate()

        guard let interval = themeSettings.backlightDuration.interval else { return }
        backlightTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { _ in
            DispatchQueue.main.async {
                withAnimation(.easeOut(duration: 0.5)) {
                    isBacklightOn = false
                }
            }
        }
    }

    // MARK: - Shake to Shuffle

    private func handleShake() {
        guard !isHoldEnabled, !musicService.songs.isEmpty else { return }
        resetBacklightTimer()
        let shuffled = musicService.songs.shuffled()
        Task {
            await musicService.play(tracks: shuffled, startingAt: 0)
            await MainActor.run {
                saveCurrentSelectionState()
                navigationStack.append(currentScreen)
                withAnimation(.easeInOut(duration: 0.15)) {
                    currentScreen = .nowPlaying
                }
            }
        }
    }
}

private enum CoverFlowMode {
    case albums, playlists, podcasts
}

// MARK: - Preview

#Preview {
    @Previewable @State var musicService = MusicService()
    iPodView(musicService: musicService)
}
