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
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(modelData)
        }
    }
}
