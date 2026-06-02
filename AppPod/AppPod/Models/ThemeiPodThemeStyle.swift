//
//  iPodThemeStyle.swift
//  AppPod
//
//  Created by Daniel Buzlea on 5/14/26.
//

import Foundation

enum iPodThemeStyle: String, CaseIterable, Identifiable {
    case classic = "Classic White"
    case nano = "iPod Nano"
    case blackWhite = "Black & White"
    case greenScreen = "Green Screen"
    case colorScreen = "Color Screen"
    case classicBlack = "Classic Black"
    case classicSilver = "Classic Silver"
    case u2BlackRed = "U2 Black & Red"
    case miniSilver = "iPod Mini Silver"
    case miniGold = "iPod Mini Gold"
    case miniBlue = "iPod Mini Blue"
    case miniPink = "iPod Mini Pink"
    case miniGreen = "iPod Mini Green"
    case nanoSilver = "Nano Silver"
    case nanoBlack = "Nano Black"
    case nanoSpaceGray = "Nano Space Gray"
    case nanoBlue = "Nano Blue"
    case nanoPink = "Nano Pink"
    case nanoPurple = "Nano Purple"
    case nanoGreen = "Nano Green"
    case nanoYellow = "Nano Yellow"
    case nanoOrange = "Nano Orange"
    case nanoRed = "Nano Red"
    case shuffleSilver = "Shuffle Silver"
    case shuffleBlue = "Shuffle Blue"
    case shufflePink = "Shuffle Pink"
    case shuffleGreen = "Shuffle Green"
    case shuffleOrange = "Shuffle Orange"
    case shufflePurple = "Shuffle Purple"
    case shuffleGold = "Shuffle Gold"
    
    var id: String { rawValue }
    
    /// Default screen size for this iPod model
    var defaultScreenSize: ScreenSize {
        switch self {
        case .classic, .classicBlack, .classicSilver, .u2BlackRed:
            return .standard
        case .nano,
             .nanoSilver,
             .nanoBlack,
             .nanoSpaceGray,
             .nanoBlue,
             .nanoPink,
             .nanoPurple,
             .nanoGreen,
             .nanoYellow,
             .nanoOrange,
             .nanoRed:
            return .nanoTall
        case .shuffleSilver,
             .shuffleBlue,
             .shufflePink,
             .shuffleGreen,
             .shuffleOrange,
             .shufflePurple,
             .shuffleGold:
            return .nano
        case .blackWhite,
             .miniSilver,
             .miniGold,
             .miniBlue,
             .miniPink,
             .miniGreen:
            return .standard
        case .greenScreen:
            return .retro
        case .colorScreen:
            return .large
        }
    }
}
