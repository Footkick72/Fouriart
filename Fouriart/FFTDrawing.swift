//
//  FFTDrawing.swift
//  Fouriart
//
//  Created by Daniel Long on 9/27/21.
//

import Foundation
import SwiftUI
import PencilKit
import Photos

struct FFTDrawing: Codable {
    var paths: [FFTPath] = []
    
    func getPreviewImage() -> UIImage {
        var drawing = PKDrawing()
        for path in paths {
            drawing.strokes.append(path.getDrawablePath())
        }
        return drawing.image(from: drawing.bounds, scale: 1.0)
    }
    
    func getFullImage(rect: CGRect) -> UIImage {
        var drawing = PKDrawing()
        for path in paths {
            drawing.strokes.append(path.getDrawablePath())
        }
        return drawing.image(from: rect, scale: 1.0)
    }
    
    func saveToPhotos(rect: CGRect) {
        UIImageWriteToSavedPhotosAlbum(getFullImage(rect: rect), nil, nil, nil);
    }
    
    mutating func addPath(_ path: FFTPath) {
        paths.append(path)
    }
    
    mutating func deletePath(at: Int) {
        paths.remove(at: at)
    }
}
