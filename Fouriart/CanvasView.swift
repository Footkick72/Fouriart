//
//  CanvasView.swift
//  Fouriart
//
//  Created by Daniel Long on 9/12/21.
//

import Foundation
import SwiftUI
import PencilKit
import Accelerate

struct CanvasView: View {
    @State var canvas = PKCanvasView()
//    @State var toolpicker = PKToolPicker()
    @State var selectedCurveResolution: CGFloat = 50
    @State var selectedCurveIndex: Int? = nil
    @State var selectionActive = false
    
    @State var curveData: [[CGPoint]] = []
    
    @State var setup = vDSP_create_fftsetup(1, FFTRadix(kFFTRadix2))!
    @State var setup_size = 1
    
    var body: some View {
        Button("Edit Curves") {
            if selectionActive {
                selectionActive = false
                selectedCurveIndex = nil
            }
            else {
                selectionActive = true
            }
        }
        Slider(value: $selectedCurveResolution, in: 0...100)
            .frame(alignment: .top)
            .padding()
            .disabled(selectedCurveIndex == nil)
            .id(selectedCurveIndex == nil)
            .onChange(of: selectedCurveResolution) {_ in
                if let selectedCurveIndex = selectedCurveIndex {
                    
                    var real: [Float] = []
                    var complex: [Float] = []
                    for point in curveData[selectedCurveIndex] {
                        real.append(Float(point.x))
                        complex.append(Float(point.y))
                    }
                    
                    var splitComplex: DSPSplitComplex = DSPSplitComplex(realp: UnsafeMutablePointer(mutating: real), imagp: UnsafeMutablePointer(mutating: complex))
                    vDSP_fft_zip(setup, &splitComplex, 1, vDSP_Length(log2(Float(curveData[selectedCurveIndex].count))), FFTDirection(kFFTDirection_Forward))
                    
                    real = Array(UnsafeBufferPointer(start: splitComplex.realp, count: curveData[selectedCurveIndex].count))
                    complex = Array(UnsafeBufferPointer(start: splitComplex.imagp, count: curveData[selectedCurveIndex].count))
                    
                    var rcount = 0
                    for r in real.sorted(by: {a, b in
                        return abs(a) < abs(b)
                    }) {
                        real[real.firstIndex(of: r)!] = 0
                        rcount += 1
                        if rcount >= real.count - Int(Float(selectedCurveResolution)/100 * Float(curveData[selectedCurveIndex].count)) {
                            break
                        }
                    }
                    
                    var ccount = 0
                    for c in complex.sorted(by: {a, b in
                        return abs(a) < abs(b)
                    }) {
                        complex[complex.firstIndex(of: c)!] = 0
                        ccount += 1
                        if ccount >= complex.count - Int(Float(selectedCurveResolution)/100 * Float(curveData[selectedCurveIndex].count)) {
                            break
                        }
                    }
                    
                    splitComplex = DSPSplitComplex(realp: UnsafeMutablePointer(mutating: real), imagp: UnsafeMutablePointer(mutating: complex))
                    vDSP_fft_zip(setup, &splitComplex, 1, vDSP_Length(log2(Float(curveData[selectedCurveIndex].count))), FFTDirection(kFFTDirection_Inverse))
                    
                    real = Array(UnsafeBufferPointer(start: splitComplex.realp, count: curveData[selectedCurveIndex].count))
                    complex = Array(UnsafeBufferPointer(start: splitComplex.imagp, count: curveData[selectedCurveIndex].count))
                    
                    var points: [CGPoint] = []
                    for i in 0..<real.count {
                        points.append(CGPoint(x: Double(real[i]/Float(curveData[selectedCurveIndex].count)), y: Double(complex[i]/Float(curveData[selectedCurveIndex].count))))
                    }
                    
                    var newPoints = [PKStrokePoint]()
                    for i in 0..<canvas.drawing.strokes[selectedCurveIndex].path.count {
                        let point = canvas.drawing.strokes[selectedCurveIndex].path[i]
                        let newPoint = PKStrokePoint(location: points[i],
                                                     timeOffset: point.timeOffset,
                                                     size: point.size,
                                                     opacity: point.opacity,
                                                     force: point.force,
                                                     azimuth: point.azimuth,
                                                     altitude: point.altitude)
                        newPoints.append(newPoint)
                    }
                    let newPath = PKStrokePath(controlPoints: newPoints, creationDate: Date())
                    var newStroke = PKStroke(ink: canvas.drawing.strokes[selectedCurveIndex].ink, path: newPath)
                    newStroke.transform = canvas.drawing.strokes[selectedCurveIndex].transform
                    
                    canvas.drawing.strokes[selectedCurveIndex] = newStroke
                }
            }
        
        Canvas(canvasView: $canvas, onSaved: { // this entire logic chain depends on the fact that the PKCanvas never recieves any direct updates other than drawing strokes
            if curveData.count < canvas.drawing.strokes.count {
                let original = canvas.drawing.strokes.last!
                
                var points: [CGPoint] = []
                for point in original.path {
                    points.append(point.location)
                }
                points.append(points[0])
                print(points.count)
                print(points)
                
                var padded = FFT_pad(points: points)
                let beginNotDraw = padded.popLast()!
                print(padded.count)
                print(padded)
                curveData.append(padded)
                
                let toDraw = padded.dropLast(padded.count - padded.firstIndex(of: beginNotDraw)! - 1)
                print(toDraw.count)
                print(toDraw)
                
                var newPoints: [PKStrokePoint] = []
                var lastOriginal: PKStrokePoint? = nil
                for i in 0..<toDraw.count {
                    if let originalIndex = original.path.firstIndex(where: {point in
                        toDraw.firstIndex(of: point.location) != nil && toDraw.firstIndex(of: point.location)! > i
                    }) {
                        lastOriginal = original.path[originalIndex]
                    }
                    newPoints.append(PKStrokePoint(location: padded[i],
                                                   timeOffset: lastOriginal!.timeOffset,
                                                   size: lastOriginal!.size,
                                                   opacity: lastOriginal!.opacity,
                                                   force: lastOriginal!.force,
                                                   azimuth: lastOriginal!.azimuth,
                                                   altitude: lastOriginal!.altitude))
                }
                let old = canvas.drawing.strokes.popLast()!
                canvas.drawing.strokes.append(PKStroke(ink: old.ink, path: PKStrokePath(controlPoints: newPoints, creationDate: Date())))
                
                let size = Int(log2(Float(padded.count)))
                if setup_size < size {
                    setup_size = size
                    setup = vDSP_create_fftsetup(vDSP_Length(size), FFTRadix(kFFTRadix2))!
                }
            }
        })
//            .onAppear() {
//                toolpicker.setVisible(true, forFirstResponder: canvas)
//                toolpicker.addObserver(canvas)
//                canvas.becomeFirstResponder()
//            }
            .border(Color.black)
            .overlay(
                Rectangle()
                    .opacity(selectionActive ? 0.001 : 0) // makes selection code active by setting opacity of rectangle overlay to nonzero value
                    .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
                                .onEnded({ data in
                                    var minDist: [CGFloat] = [1000000, -1]
                                    for (ci, curve) in canvas.drawing.strokes.enumerated() {
                                        for point in curve.path {
                                            let d: CGFloat = sqrt(pow(point.location.x - data.location.x, 2) + pow(point.location.y - data.location.y, 2))
                                            if d < minDist[0] {
                                                minDist = [d, CGFloat(ci)]
                                            }
                                        }
                                    }
                                    if minDist[1] != -1 {
                                        selectedCurveIndex = Int(minDist[1])
                                    } else {
                                        selectedCurveIndex = nil
                                    }
                                }))
            )
            
    }
}

class Coordinator: NSObject {
  var canvasView: Binding<PKCanvasView>
  let logNewStroke: () -> Void

  init(canvasView: Binding<PKCanvasView>, onSaved: @escaping () -> Void) {
    self.canvasView = canvasView
    self.logNewStroke = onSaved
  }
}

extension Coordinator: PKCanvasViewDelegate {
  func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
    logNewStroke()
  }
}

//canvas class modified from https://www.hackingwithswift.com/forums/swiftui/pencilkit-with-swiftui/59
struct Canvas: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    let onSaved: () -> Void

    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.isOpaque = false
        canvasView.drawingPolicy = .anyInput
        canvasView.tool = PKInkingTool(.pen, color: .black, width: 20)
        canvasView.drawingPolicy = .anyInput
        canvasView.delegate = context.coordinator
        return canvasView
    }

    func updateUIView(_ canvasView: PKCanvasView, context: Context) { }
    
    func makeCoordinator() -> Coordinator {
      Coordinator(canvasView: $canvasView, onSaved: onSaved)
    }
}
