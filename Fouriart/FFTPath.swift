//
//  FFTPath.swift
//  Fouriart
//
//  Created by Daniel Long on 9/21/21.
//

import Foundation
import SwiftUI

var curveData: [FFTPath] = []

struct FFTPath: Codable {
    var data: [CGPoint] = []
    var precision: Float = 0
    
    func getCoeffsToDelete() -> Float {
        return precision * Float(data.count) + 2
    }
}
