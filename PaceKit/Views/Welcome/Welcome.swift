//
//  Welcome.swift
//  PaceKit
//
//  Created by Calvin Korver on 2/23/25.
//

import SwiftUI

struct Welcome: View {
    var body: some View {
        VStack {
            Text("Welcome to PaceKit!")
                .font(.title)
            Text("This is the start of a new project.")
                .font(.subheadline)
        }
    }
}

#Preview {
    Welcome()
}
