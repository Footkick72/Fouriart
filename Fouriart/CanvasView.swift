//
//  CanvasView.swift
//  Fouriart
//
//  Created by Daniel Long on 9/12/21.
//

import Foundation
import SwiftUI
import PencilKit

struct CanvasView: View {
    @State var canvas = PKCanvasView()
//    @State var toolpicker = PKToolPicker()
    @State var selectedCurveResolution: CGFloat = 50
    @State var selectedCurveIndex: Int? = nil
    @State var selectionActive = false
    
    @State var curveData: [PKStroke] = []
    
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
        
        Canvas(canvasView: $canvas, onSaved: { // this entire logic chain depends on the fact that the PKCanvas never recieves any direct updates other than drawing strokes
            if curveData.count < canvas.drawing.strokes.count {
                curveData.append(canvas.drawing.strokes.last!)
                print(curveData)
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
