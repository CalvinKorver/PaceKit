//
//  MetricDisplay.swift
//  PaceKit
//
//  Created by Calvin Korver on 2/16/25.
//


// SharedBlockComponents.swift

import SwiftUI

// Shared view for displaying metric value and unit
struct MetricDisplay: View {
    let value: String
    let unit: String
    let textColor: Color
    
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(value)
                .font(.system(size: 58, weight: .bold))
                .foregroundStyle(textColor)
                .frame(maxWidth: 152)
            
            Text(unit)
                .font(.system(size: 26, weight: .light))
                .foregroundColor(.secondary)
        }
    }
}

// Shared card style
struct BlockCard<Content: View>: View {
    let content: Content
    let isMainBlock: Bool
    
    init(isMainBlock: Bool = false, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.isMainBlock = isMainBlock
    }
    
    var body: some View {
        VStack(spacing: 24) {
            content
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .stroke(isMainBlock ? Color.green : Color.gray.opacity(0.3),
                       lineWidth: 2)
        )
        .padding(.horizontal)
    }
}


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

