//
//  AppPodApp.swift
//  AppPod
//
//  Created by Daniel Buzlea on 5/13/26.
//

import SwiftUI

@main
struct AppPodApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
