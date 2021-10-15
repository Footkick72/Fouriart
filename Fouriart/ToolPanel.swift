//
//  ToolPanel.swift
//  Fouriart
//
//  Created by Daniel Long on 10/10/21.
//

import Foundation
import SwiftUI
import PencilKit

struct ToolPanel: View {
    var tools: [PKInkingTool] = [PKInkingTool(.pen), PKInkingTool(.pencil), PKInkingTool(.marker)]
    var icons: [String] = ["paintbrush.pointed", "pencil.circle", "paintbrush"]
    
    var body: some View {
        VStack(spacing: 50) {
            ForEach(0..<tools.count, id: \.self) { i in
                let tool: PKInkingTool = tools[i]
                ToolButton(tool: tool, icon: icons[i])
            }
            DrawingThicknessSlider()
            DrawingColorSelector()
        }
        .frame(width: 100)
    }
}
