//
//  FFTPath.swift
//  Fouriart
//
//  Created by Daniel Long on 9/21/21.
//

import Foundation
import SwiftUI
import Accelerate
import PencilKit

struct FFTPath: Codable {
    var data: [CGPoint] = []
    var precision: Float = 0.0
    var fftCoeffsReal: [Float] = []
    var fftCoeffsImag: [Float] = []
    var setupSize = 1
    var beginNotDrawIndex: Int = 0
    var original: PKDrawing = PKDrawing()
    var pointOriginality: [Bool] = []
    
    init(original: PKStroke) {
        fftPrecomp(PKDrawing(strokes:[original]))
    }
    
    func getCoeffsToDelete() -> Float {
        return precision * Float(data.count) + 2
    }
    
    func getDrawablePath() -> PKStroke {
        var points = ifft()
        
        let toDraw = points.dropLast(points.count - beginNotDrawIndex - 1)
        
        var newPoints: [PKStrokePoint] = []
        var lastOriginal: PKStrokePoint = original.strokes[0].path.first!
        var lastOriginalIndex = 0
        for drawIndex in 0..<toDraw.count {
            if pointOriginality[drawIndex] {
                lastOriginalIndex += 1
                lastOriginal = original.strokes[0].path[lastOriginalIndex]
            }
            newPoints.append(PKStrokePoint(location: toDraw[drawIndex],
                                           timeOffset: lastOriginal.timeOffset,
                                           size: lastOriginal.size,
                                           opacity: lastOriginal.opacity,
                                           force: lastOriginal.force,
                                           azimuth: lastOriginal.azimuth,
                                           altitude: lastOriginal.altitude))
        }
        var stroke = PKStroke(ink: original.strokes[0].ink, path: PKStrokePath(controlPoints: newPoints, creationDate: Date()))
        stroke.transform = original.strokes[0].transform
        return stroke
    }
    
    mutating func fftPrecomp(_ original: PKDrawing) {
        self.original = original
        
        var points: [CGPoint] = []
        for point in original.strokes[0].path {
            points.append(point.location)
        }
        points.append(points[0])
        
        var padded = FFT_pad(points: points)
        let beginNotDraw = padded.popLast()!.0
        for i in 0..<padded.count {
            if padded[i].0 == beginNotDraw {
                beginNotDrawIndex = i
                break
            }
        }
        var p: [CGPoint] = []
        for point in padded {
            p.append(point.0)
            pointOriginality.append(point.1)
        }
        data = p
        precision = 1.0
        
        var setup = vDSP_create_fftsetup(1, FFTRadix(kFFTRadix2))!
        
        let size = Int(log2(Float(padded.count)))
        if setupSize < size {
            setupSize = size
            setup = vDSP_create_fftsetup(vDSP_Length(size), FFTRadix(kFFTRadix2))!
        }
        
        for point in data {
            fftCoeffsReal.append(Float(point.x))
            fftCoeffsImag.append(Float(point.y))
        }
        
        var splitComplex: DSPSplitComplex = DSPSplitComplex(realp: UnsafeMutablePointer(mutating: fftCoeffsReal), imagp: UnsafeMutablePointer(mutating: fftCoeffsImag))
        vDSP_fft_zip(setup, &splitComplex, 1, vDSP_Length(log2(Float(data.count))), FFTDirection(kFFTDirection_Forward))
        
        fftCoeffsReal = Array(UnsafeBufferPointer(start: splitComplex.realp, count: data.count))
        fftCoeffsImag = Array(UnsafeBufferPointer(start: splitComplex.imagp, count: data.count))
    }
    
    func ifft() -> [CGPoint] {
        var real = fftCoeffsReal
        var imag = fftCoeffsImag
        var count = 0
        let indicies: [Int] = Array(0..<real.count)
        for i in indicies.sorted(by: {a,b in
            return sqrt(pow(real[a],2) + pow(imag[a],2)) < sqrt(pow(real[b],2) + pow(imag[b],2))
        }) {
            if count + 1 >= real.count - Int(getCoeffsToDelete()) {
                let r = getCoeffsToDelete()
                real[i] *= r - floor(r)
                imag[i] *= r - floor(r)
                break
            }
            real[i] = 0
            imag[i] = 0
            count += 1
        }
        
        var setup = vDSP_create_fftsetup(vDSP_Length(setupSize), FFTRadix(kFFTRadix2))!
        var splitComplex = DSPSplitComplex(realp: UnsafeMutablePointer(mutating: real), imagp: UnsafeMutablePointer(mutating: imag))
        vDSP_fft_zip(setup, &splitComplex, 1, vDSP_Length(log2(Float(data.count))), FFTDirection(kFFTDirection_Inverse))
        
        real = Array(UnsafeBufferPointer(start: splitComplex.realp, count: data.count))
        imag = Array(UnsafeBufferPointer(start: splitComplex.imagp, count: data.count))
        
        var points: [CGPoint] = []
        for i in 0..<real.count {
            points.append(CGPoint(x: Double(real[i]/Float(data.count)), y: Double(imag[i]/Float(data.count))))
        }
        return points
    }
}
