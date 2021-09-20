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
            let outline = getOutline()
            Path{ p in
                p.move(to: outline.first!)
                for point in outline.dropFirst() {
                    p.addLine(to: point)
                }
            }
            .stroke(style: StrokeStyle(lineWidth: 2, dash: [10, 5]))
            .foregroundColor(.red)
            .hoverEffect()
        }
    }
    
    func getOutline() -> [CGPoint] {
        var result: [CGPoint] = []

        let outline_size: CGFloat = 20.0

        var angle = atan2(path!.path[0].location.y - path!.path[1].location.y, path!.path[0].location.x - path!.path[1].location.x)
        result.append(CGPoint(x: path!.path.first!.location.x + cos(angle) * outline_size,
                              y: path!.path.first!.location.y + sin(angle) * outline_size))

        for i in 0..<path!.path.count - 1 {
            angle = atan2(path!.path[i].location.y - path!.path[i + 1].location.y, path!.path[i].location.x - path!.path[i + 1].location.x)
            result.append(CGPoint(x: path!.path[i].location.x + cos(angle - CGFloat.pi/2) * outline_size,
                                  y: path!.path[i].location.y + sin(angle - CGFloat.pi/2) * outline_size))
        }

        angle = atan2(path!.path[path!.path.count - 1].location.y - path!.path[path!.path.count - 2].location.y, path!.path[path!.path.count - 1].location.x - path!.path[path!.path.count - 2].location.x)
        result.append(CGPoint(x: path!.path.last!.location.x + cos(angle) * outline_size,
                              y: path!.path.last!.location.y + sin(angle) * outline_size))

        for j in 0..<path!.path.count - 1 {
            let i = path!.path.count - j - 1
            angle = atan2(path!.path[i - 1].location.y - path!.path[i].location.y, path!.path[i - 1].location.x - path!.path[i].location.x)
            result.append(CGPoint(x: path!.path[i].location.x + cos(angle + CGFloat.pi/2) * outline_size,
                                  y: path!.path[i].location.y + sin(angle + CGFloat.pi/2) * outline_size))
        }

        angle = atan2(path!.path[0].location.y - path!.path[1].location.y, path!.path[0].location.x - path!.path[1].location.x)
        result.append(CGPoint(x: path!.path.first!.location.x + cos(angle) * outline_size,
                              y: path!.path.first!.location.y + sin(angle) * outline_size))
        
        let strength: CGFloat = 0.2
        for _ in 0..<50 {
            for j in 0..<result.count {
                let p1: CGPoint
                let p2: CGPoint
                if j == 0 {
                    p1 = result.last!
                } else {
                    p1 = result[j-1]
                }
                if j == result.count - 1 {
                    p2 = result.first!
                } else {
                    p2 = result[j+1]
                }
                let midpoint = CGPoint(x: 0.5 * (p1.x + p2.x),
                                       y: 0.5 * (p1.y + p2.y))
                result[j] = CGPoint(x: result[j].x * (1.0 - strength) + midpoint.x * strength,
                                    y: result[j].y * (1.0 - strength) + midpoint.y * strength)
            }
        }
        
        return result
    }
}
