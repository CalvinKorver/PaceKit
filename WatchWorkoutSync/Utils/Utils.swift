//
//  Utils.swift
//  Landmarks
//
//  Created by Calvin Korver on 1/8/25.
//  Copyright © 2025 Apple. All rights reserved.
//

import SwiftUI

func getMins(minSecs: Int) -> String  {
    return String(minSecs/60);
}

func getSecs(minSecs: Int) -> String {
    let secs = minSecs % 60
    if (secs < 10) {
        return "0" + String(secs)
    }
    return String(secs)
}
