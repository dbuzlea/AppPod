//
//  iPodColors.swift
//  AppPod
//
//  Created by Daniel Buzlea on 5/13/26.
//

import SwiftUI

struct iPodColorOption: Identifiable {
    let name: String
    let color: Color
    
    var id: String { name }
}

// Classic iPod color schemes
struct iPodColors {
    // Screen colors (classic monochrome LCD)
    static let screenBackground = Color(white: 0.82)
    static let screenBacklight = LinearGradient(
        colors: [Color(white: 0.85), Color(white: 0.75)],
        startPoint: .top,
        endPoint: .bottom
    )
    static let screenText = Color.black
    static let screenTextSecondary = Color.black.opacity(0.6)
    static let selectionHighlight = Color.blue.opacity(0.5)
    
    // Body colors (classic white)
    static let bodyWhite = Color(red: 0.95, green: 0.95, blue: 0.97)
    static let bezelGray = Color.gray.opacity(0.3)
    
    // Click wheel (polished chrome effect)
    static let wheelChrome = RadialGradient(
        colors: [
            Color(white: 0.7),
            Color(white: 0.5),
            Color(white: 0.4)
        ],
        center: .center,
        startRadius: 70,
        endRadius: 140
    )
    
    static let wheelCenter = RadialGradient(
        colors: [Color(white: 0.8), Color(white: 0.65)],
        center: .center,
        startRadius: 0,
        endRadius: 60
    )
    
    static let buttonText = Color.black.opacity(0.7)
    static let buttonTextPressed = Color.black.opacity(0.9)
    
    // Wheel interaction feedback
    static let wheelHighlight = Color.white.opacity(0.15)
    
    // Physical iPod finish colors used by theme and highlight settings.
    static let finishColorOptions: [iPodColorOption] = [
        iPodColorOption(name: "Classic White", color: Color(red: 0.95, green: 0.95, blue: 0.97)),
        iPodColorOption(name: "Classic Black", color: Color(white: 0.08)),
        iPodColorOption(name: "Classic Silver", color: Color(white: 0.72)),
        iPodColorOption(name: "U2 Red", color: Color(red: 0.85, green: 0.05, blue: 0.05)),
        iPodColorOption(name: "Mini Silver", color: Color(white: 0.82)),
        iPodColorOption(name: "Mini Gold", color: Color(red: 0.85, green: 0.75, blue: 0.55)),
        iPodColorOption(name: "Mini Blue", color: Color(red: 0.4, green: 0.6, blue: 0.85)),
        iPodColorOption(name: "Mini Pink", color: Color(red: 0.95, green: 0.7, blue: 0.75)),
        iPodColorOption(name: "Mini Green", color: Color(red: 0.6, green: 0.85, blue: 0.6)),
        iPodColorOption(name: "Nano Silver", color: Color(red: 0.75, green: 0.75, blue: 0.8)),
        iPodColorOption(name: "Nano Black", color: Color(white: 0.12)),
        iPodColorOption(name: "Nano Space Gray", color: Color(red: 0.32, green: 0.33, blue: 0.35)),
        iPodColorOption(name: "Nano Blue", color: Color(red: 0.12, green: 0.46, blue: 0.82)),
        iPodColorOption(name: "Nano Pink", color: Color(red: 0.95, green: 0.35, blue: 0.56)),
        iPodColorOption(name: "Nano Purple", color: Color(red: 0.55, green: 0.34, blue: 0.78)),
        iPodColorOption(name: "Nano Green", color: Color(red: 0.34, green: 0.72, blue: 0.34)),
        iPodColorOption(name: "Nano Yellow", color: Color(red: 0.95, green: 0.82, blue: 0.20)),
        iPodColorOption(name: "Nano Orange", color: Color(red: 0.95, green: 0.45, blue: 0.16)),
        iPodColorOption(name: "Nano Red", color: Color(red: 0.82, green: 0.05, blue: 0.08)),
        iPodColorOption(name: "Shuffle Silver", color: Color(red: 0.78, green: 0.78, blue: 0.82)),
        iPodColorOption(name: "Shuffle Blue", color: Color(red: 0.24, green: 0.62, blue: 0.90)),
        iPodColorOption(name: "Shuffle Pink", color: Color(red: 0.95, green: 0.42, blue: 0.64)),
        iPodColorOption(name: "Shuffle Green", color: Color(red: 0.48, green: 0.76, blue: 0.28)),
        iPodColorOption(name: "Shuffle Orange", color: Color(red: 0.95, green: 0.50, blue: 0.18)),
        iPodColorOption(name: "Shuffle Purple", color: Color(red: 0.50, green: 0.38, blue: 0.75)),
        iPodColorOption(name: "Shuffle Gold", color: Color(red: 0.86, green: 0.72, blue: 0.43))
    ]
}

// Alternative color schemes for different iPod models

struct iPodMiniColors {
    static let bodyBlue = Color(red: 0.4, green: 0.6, blue: 0.85)
    static let bodyPink = Color(red: 0.95, green: 0.7, blue: 0.75)
    static let bodyGreen = Color(red: 0.6, green: 0.85, blue: 0.6)
    static let bodySilver = Color(white: 0.85)
    static let bodyGold = Color(red: 0.85, green: 0.75, blue: 0.55)
}

struct iPodU2Colors {
    static let bodyBlack = Color.black
    static let accentRed = Color.red
}

// Typography for authentic iPod look
extension Font {
    static let iPodTitle = Font.system(size: 16, weight: .bold, design: .default)
    static let iPodMenuItem = Font.system(size: 14, weight: .regular, design: .default)
    static let iPodMenuItemSelected = Font.system(size: 14, weight: .semibold, design: .default)
    static let iPodSongTitle = Font.system(size: 11, weight: .medium, design: .default)
    static let iPodSongArtist = Font.system(size: 9, weight: .regular, design: .default)
    static let iPodStatus = Font.system(size: 10, weight: .regular, design: .default)
    static let iPodButton = Font.system(size: 10, weight: .semibold, design: .default)
}
