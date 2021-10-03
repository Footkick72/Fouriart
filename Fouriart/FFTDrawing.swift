//
//  FFTDrawing.swift
//  Fouriart
//
//  Created by Daniel Long on 9/27/21.
//

import Foundation
import SwiftUI
import PencilKit

struct FFTDrawing: Codable {
    var paths: [FFTPath] = []
    
    func getPreviewImage() -> UIImage {
        var drawing = PKDrawing()
        for path in paths {
            drawing.strokes.append(path.getDrawablePath())
        }
        return drawing.image(from: drawing.bounds, scale: 1.0)
    }
}
