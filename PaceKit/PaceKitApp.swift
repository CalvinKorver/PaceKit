//
//  WatchWorkoutSyncApp.swift
//  WatchWorkoutSync
//
//  Created by Calvin Korver on 1/11/25.
//

import SwiftUI

@main
struct PaceKitApp: App {
    @State private var modelData = ModelData()
    @State private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(modelData)
                .environment(appState)
                .onAppear {
                    // You can detect the initial system color scheme here if needed
                    // or leave it to the user's preference
                }
                .onChange(of: colorScheme) { oldValue, newValue in
                    appState.updateColorScheme(newValue)
                }
        }
    }
    
    @Environment(\.colorScheme) var colorScheme
}
