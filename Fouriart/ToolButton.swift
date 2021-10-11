//
//  ToolButton.swift
//  Fouriart
//
//  Created by Daniel Long on 10/10/21.
//

import Foundation
import SwiftUI
import PencilKit

struct ToolButton: View {
    var tool: PKInkingTool
    var icon: String
    
    var body: some View {
        Button(action: {
            toolOptions.ink = tool.inkType
            toolOptions.save()
        }) {
            Image(systemName: icon)
                .font(.largeTitle)
        }
    }
}
