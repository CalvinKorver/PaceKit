//
//  AddBlockButton.swift
//  WatchWorkoutSync
//
//  Created by Calvin Korver on 1/30/25.
//
import SwiftUI

struct AddBlockButton: View {
    let blockType: BlockType
    let action: () -> Void
    
    private var buttonTitle: String {
        switch blockType {
        case .warmup:
            return "Warmup"
        case .cooldown:
            return "Cooldown"
        case .work:
            return "Work"
        default:
            return "Add Block"
        }
    }
    
    var body: some View {
            Button(action: action) {
                HStack {
                    Image(systemName: "plus.circle")
                    Text(buttonTitle)
                }
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .foregroundStyle(.blue)
            }
        }
}

#Preview {
    VStack(spacing: 20) {
        AddBlockButton(blockType: .warmup) {}
        AddBlockButton(blockType: .cooldown) {}
        AddBlockButton(blockType: .work) {}
    }
    .padding()
}
