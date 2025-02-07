//
//  AddBlockButton.swift
//  WatchWorkoutSync
//
//  Created by Calvin Korver on 1/30/25.
//
import SwiftUI

struct AddBlockButton: View {
    let blockType: Block.Type
    let action: () -> Void
    
    private var buttonTitle: String {
        switch blockType {
        case is WarmupBlock.Type:
            return "Warmup"
        case is CooldownBlock.Type:
            return "Cooldown"
        case is WorkBlock.Type:
            return "Work"
        default:
            return "Add Block"
        }
    }
    
    var body: some View {
        SectionCard {
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
}

#Preview {
    VStack(spacing: 20) {
        AddBlockButton(blockType: WarmupBlock.self) {}
        AddBlockButton(blockType: CooldownBlock.self) {}
        AddBlockButton(blockType: WorkBlock.self) {}
    }
    .padding()
}
