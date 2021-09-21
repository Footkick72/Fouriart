//
//  PathSelectionIndicator.swift
//  Fouriart
//
//  Created by Daniel Long on 9/19/21.
//

import Foundation
import SwiftUI
import PencilKit

struct PathSelectionIndicator: View {
    @Binding var path: PKStroke?
    
    var body: some View {
        if path != nil {
            let bbox = getBBox()
            Path { p in
                p.move(to: bbox.origin)
                p.addLine(to: CGPoint(x: bbox.maxX, y: bbox.minY))
                p.addLine(to: CGPoint(x: bbox.maxX, y: bbox.maxY))
                p.addLine(to: CGPoint(x: bbox.minX, y: bbox.maxY))
                p.addLine(to: bbox.origin)
            }
            .stroke(style: StrokeStyle(lineWidth: 2, dash: [10, 5]))
            .foregroundColor(.red)
            
        }
    }
    
    func getBBox() -> CGRect {
        let drawing = PKDrawing(strokes: [path!])
        return drawing.bounds
    }
}
