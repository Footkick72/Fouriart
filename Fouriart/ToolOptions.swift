//
//  ToolOptions.swift
//  Fouriart
//
//  Created by Daniel Long on 10/10/21.
//

import Foundation
import SwiftUI
import PencilKit

var toolOptions = ToolOptions()
fileprivate let inks: [PKInk.InkType] = [.pen, .pencil, .marker]

class ToolOptions: Equatable {
    var ink: PKInk.InkType = .pen
    var color: UIColor = UIColor(cgColor: CGColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0))
    var size: CGFloat = 10
    var canvas: PKCanvasView? = nil
    
    static func == (lhs: ToolOptions, rhs: ToolOptions) -> Bool {
        return (lhs.ink == rhs.ink && lhs.color == rhs.color && lhs.size == rhs.size)
    }
    
    func save() {
        canvas!.tool = getTool()
        UserDefaults.standard.set(color.cgColor.components!, forKey: "drawingColor")
        UserDefaults.standard.set(size, forKey: "drawingThickness")
        UserDefaults.standard.set(inks.firstIndex(of: ink)!, forKey: "inkType")
    }
    
    func load() {
        if UserDefaults.standard.object(forKey: "drawingColor") != nil {
            let values = UserDefaults.standard.object(forKey: "drawingColor") as! [CGFloat]
            color = UIColor(cgColor: CGColor(red: values[0], green: values[1], blue: values[2], alpha: values[3]))
        }
        if UserDefaults.standard.value(forKey: "drawingThickness") != nil {
            size = UserDefaults.standard.value(forKey: "drawingThickness") as! CGFloat
        }
        if UserDefaults.standard.value(forKey: "inkType") != nil {
            ink = inks[UserDefaults.standard.integer(forKey: "inkType")]
        }
    }
    
    func getTool() -> PKInkingTool {
        return PKInkingTool(ink, color: color, width: size)
    }
}
