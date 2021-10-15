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
import Photos

struct CanvasView: View {
    @State var canvas = PKCanvasView()
    @State var selectedCurveResolution: CGFloat = 50
    @State var selectedCurveIndex: Int? = nil
    @State var selectedCurve: PKStroke? = nil
    @State var selectionActive = false
    
    @State var showingPhotosPermissionAlert = false

    var body: some View {
        HStack {
            Button("Close Drawing") {
                curveData.unselectDrawing()
            }
            .onAppear {
                for stroke in curveData.data[curveData.currentDrawing!].paths {
                    canvas.drawing.strokes.append(stroke.getDrawablePath())
                }
            }
            Button("Edit Curves") {
                if selectionActive {
                    selectionActive = false
                    selectedCurveIndex = nil
                    selectedCurve = nil
                }
                else {
                    selectionActive = true
                }
            }
            Button("Save to Photos") {
                PHPhotoLibrary.requestAuthorization(for: .readWrite, handler: { _ in return })
                if PHPhotoLibrary.checkPhotoSavePermission() {
                    curveData.data[curveData.currentDrawing!].saveToPhotos(rect: canvas.bounds)
                } else {
                    showingPhotosPermissionAlert = true
                }
            }
            Button("Delete Stroke") {
                curveData.data[curveData.currentDrawing!].deletePath(at: selectedCurveIndex!)
                canvas.drawing.strokes.remove(at: selectedCurveIndex!)
                selectionActive = false
                selectedCurveIndex = nil
                selectedCurve = nil
            }.disabled(selectedCurve == nil)
            .alert(isPresented: $showingPhotosPermissionAlert) {
                Alert(title: Text("Unable to Save"), message: Text("Fouriart does not have permission to save photos to the camera roll"), dismissButton: .default(Text("OK")))
            }
        }
        Slider(value: $selectedCurveResolution, in: 0...100)
            .frame(alignment: .top)
            .padding()
            .disabled(selectedCurveIndex == nil)
            .id(selectedCurveIndex == nil)
            .onChange(of: selectedCurveResolution) {_ in
                if let selectedCurveIndex = selectedCurveIndex {
                    curveData.data[curveData.currentDrawing!].paths[selectedCurveIndex].precision = Float(selectedCurveResolution)/100
                    canvas.drawing.strokes[selectedCurveIndex] = curveData.data[curveData.currentDrawing!].paths[selectedCurveIndex].getDrawablePath()
                    selectedCurve = canvas.drawing.strokes[selectedCurveIndex]
                }
            }
        HStack{
            ZStack {
                ReferenceImage()
                Canvas(canvasView: $canvas, onSaved: { // this entire logic chain depends on the fact that the PKCanvas never recieves any direct updates other than drawing strokes
                    if curveData.data[curveData.currentDrawing!].paths.count < canvas.drawing.strokes.count {
                        let original = canvas.drawing.strokes.last!
                        
                        curveData.data[curveData.currentDrawing!].addPath(FFTPath(original: original))
                        
                        canvas.drawing.strokes.removeLast()
                        canvas.drawing.strokes.append(curveData.data[curveData.currentDrawing!].paths.last!.getDrawablePath())
                    }
                })
                    .border(Color.black)
                    .onAppear {
                        toolOptions.canvas = canvas
                        canvas.isOpaque = false
                    }
                
                PathSelectionIndicator(path: $selectedCurve)
                    .opacity(selectedCurveIndex != nil ? 1.0 : 0.0)
                
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
                            selectedCurve = canvas.drawing.strokes[selectedCurveIndex!]
                            selectedCurveResolution = CGFloat(curveData.data[curveData.currentDrawing!].paths[selectedCurveIndex!].precision * 100)
                        } else {
                            selectedCurveIndex = nil
                            selectedCurve = nil
                        }
                    }))
            }
            ToolPanel()
        }
            
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
