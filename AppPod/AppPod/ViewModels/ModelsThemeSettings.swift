//
//  ThemeSettings.swift
//  AppPod
//
//  Created by Daniel Buzlea on 5/14/26.
//

import SwiftUI

enum BacklightDuration: String, CaseIterable {
    case fiveSeconds   = "5 Seconds"
    case tenSeconds    = "10 Seconds"
    case thirtySeconds = "30 Seconds"
    case alwaysOn      = "Always On"

    var interval: TimeInterval? {
        switch self {
        case .fiveSeconds:   return 5
        case .tenSeconds:    return 10
        case .thirtySeconds: return 30
        case .alwaysOn:      return nil
        }
    }
}

enum ScrollSensitivity: String, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"

    var scrollThreshold: Double {
        switch self {
        case .low: return 25.0   // original pre-acceleration threshold
        case .medium: return 35.0
        case .high: return 22.0
        }
    }

    var velocityStepThresholds: (t1: Double, t2: Double, t3: Double) {
        switch self {
        case .low:    return (600, 1100, 1800)  // acceleration only at extreme spin speeds
        case .medium: return (180, 380, 600)
        case .high:   return (120, 280, 480)
        }
    }
}

@Observable
class ThemeSettings {
    var themeStyle: iPodThemeStyle {
        didSet {
            UserDefaults.standard.set(themeStyle.rawValue, forKey: "iPodThemeStyle")
            // Update screen size to match the new theme's default if using auto
            if useAutoScreenSize {
                screenSize = themeStyle.defaultScreenSize
            }
        }
    }
    
    var customHighlightColor: Color {
        didSet {
            if let colorData = try? JSONEncoder().encode(customHighlightColor.toStorableColor()) {
                UserDefaults.standard.set(colorData, forKey: "iPodCustomHighlightColor")
            }
        }
    }
    
    var useCustomHighlight: Bool {
        didSet {
            UserDefaults.standard.set(useCustomHighlight, forKey: "iPodUseCustomHighlight")
        }
    }
    
    var screenSize: ScreenSize {
        didSet {
            UserDefaults.standard.set(screenSize.rawValue, forKey: "iPodScreenSize")
        }
    }
    
    var useAutoScreenSize: Bool {
        didSet {
            UserDefaults.standard.set(useAutoScreenSize, forKey: "iPodUseAutoScreenSize")
            // If switching to auto, update screen size to match current theme
            if useAutoScreenSize {
                screenSize = themeStyle.defaultScreenSize
            }
        }
    }

    var scrollSensitivity: ScrollSensitivity {
        didSet {
            UserDefaults.standard.set(scrollSensitivity.rawValue, forKey: "iPodScrollSensitivity")
        }
    }

    var clickSoundEnabled: Bool {
        didSet {
            UserDefaults.standard.set(clickSoundEnabled, forKey: "iPodClickSoundEnabled")
        }
    }

    var backlightDuration: BacklightDuration {
        didSet {
            UserDefaults.standard.set(backlightDuration.rawValue, forKey: "iPodBacklightDuration")
        }
    }

    var currentTheme: iPodTheme {
        iPodTheme.theme(
            for: themeStyle,
            highlightColor: useCustomHighlight ? customHighlightColor : nil
        )
    }
    
    init() {
        // Load theme style first
        let loadedThemeStyle: iPodThemeStyle
        if let savedStyle = UserDefaults.standard.string(forKey: "iPodThemeStyle"),
           let style = iPodThemeStyle(rawValue: savedStyle) {
            loadedThemeStyle = style
        } else {
            loadedThemeStyle = .classic
        }
        
        // Load custom highlight color
        if let colorData = UserDefaults.standard.data(forKey: "iPodCustomHighlightColor"),
           let storableColor = try? JSONDecoder().decode(StorableColor.self, from: colorData) {
            self.customHighlightColor = storableColor.toColor()
        } else {
            self.customHighlightColor = .blue
        }
        
        // Load use custom highlight flag
        self.useCustomHighlight = UserDefaults.standard.bool(forKey: "iPodUseCustomHighlight")
        
        // Load auto screen size flag
        self.useAutoScreenSize = UserDefaults.standard.bool(forKey: "iPodUseAutoScreenSize")
        
        // Load screen size using the loaded theme style
        if let savedSize = UserDefaults.standard.string(forKey: "iPodScreenSize"),
           let size = ScreenSize(rawValue: savedSize) {
            self.screenSize = size
        } else {
            // Default to theme's default screen size
            self.screenSize = loadedThemeStyle.defaultScreenSize
        }
        
        // Load scroll sensitivity
        if let savedSensitivity = UserDefaults.standard.string(forKey: "iPodScrollSensitivity"),
           let sensitivity = ScrollSensitivity(rawValue: savedSensitivity) {
            self.scrollSensitivity = sensitivity
        } else {
            self.scrollSensitivity = .medium
        }

        // Load click sound enabled (defaults to true)
        if UserDefaults.standard.object(forKey: "iPodClickSoundEnabled") != nil {
            self.clickSoundEnabled = UserDefaults.standard.bool(forKey: "iPodClickSoundEnabled")
        } else {
            self.clickSoundEnabled = true
        }

        // Load backlight duration (defaults to 10 seconds)
        if let savedDuration = UserDefaults.standard.string(forKey: "iPodBacklightDuration"),
           let duration = BacklightDuration(rawValue: savedDuration) {
            self.backlightDuration = duration
        } else {
            self.backlightDuration = .tenSeconds
        }

        // Finally, set the theme style
        self.themeStyle = loadedThemeStyle
    }
}
