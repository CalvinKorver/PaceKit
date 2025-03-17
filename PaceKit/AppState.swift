//
//  AppState.swift
//  PaceKit
//
//  Created by Calvin Korver on 3/6/25.
//


import SwiftUI

@Observable
class AppState: ObservableObject {
    var currentUser: String?
    var colorScheme: ColorScheme = .light
    
    // Dynamic colors based on color scheme
    var cardBackgroundColor: Color {
        colorScheme == .dark ? Color(.systemGray6) : .white
    }
    
    var restBackgroundColor: Color {
        colorScheme == .dark ? Color(.systemGray5) : Color(.systemGray6).opacity(0.5)
    }
    
    // Add any other app-wide state or computed properties here
    
    // Method to update color scheme (can be called when app detects system changes)
    func updateColorScheme(_ newScheme: ColorScheme) {
        colorScheme = newScheme
    }
}
