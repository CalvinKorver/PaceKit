//
//  BlockEditView.swift
//  Landmarks
//
//  Created by Calvin Korver on 1/4/25.
//  Copyright © 2025 Apple. All rights reserved.
//
import SwiftUI

struct BlockView: View {
    let viewModel: BlockViewModel
    
    init(block: Block) {
        self.viewModel = BlockViewModel(block: block)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(viewModel.name)
                .font(.headline)
            
            if let distanceText = viewModel.distanceText {
                Text(distanceText)
            }
            
            if let durationText = viewModel.durationText {
                Text(durationText)
                    .font(.subheadline)
            }
            
            if let paceText = viewModel.paceText {
                Text(paceText)
                    .font(.subheadline)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.white))
                .stroke(viewModel.isMainBlock ? Color.green : Color.gray.opacity(0.3),
                       lineWidth: 2)
        )
        .padding(.horizontal)
    }
}

#Preview {
    ContentView()
        .environment(ModelData())
}
