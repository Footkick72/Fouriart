//
//  CurveData.swift
//  Fouriart
//
//  Created by Daniel Long on 9/27/21.
//

import Foundation
import SwiftUI

var curveData = CurveData()

class CurveData: Codable, ObservableObject {
    var data: [FFTDrawing] = []
    var currentDrawing: Int? = nil
    
    func selectDrawing(_ i:Int) {
        currentDrawing = i
        objectWillChange.send()
    }
    
    func createNewDrawing() {
        data.append(FFTDrawing())
        currentDrawing = data.count - 1
        objectWillChange.send()
    }
    
    func unselectDrawing() {
        currentDrawing = nil
        objectWillChange.send()
    }
}
