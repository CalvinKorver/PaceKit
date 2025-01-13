//
//  MetricType.swift
//  Landmarks
//
//  Created by Calvin Korver on 1/8/25.
//  Copyright © 2025 Apple. All rights reserved.
//


enum MetricType: String, CaseIterable {
    case distance = "Distance"
    case time = "Time"
}

enum DistanceUnit: String, Hashable, Codable, CaseIterable {
    case miles, meters, kilometers
}
