//
//  ContentView.swift
//  Fouriart
//
//  Created by Daniel Long on 9/12/21.
//

import SwiftUI


struct ContentView: View {
    @ObservedObject var curves = curveData
    
    var body: some View {
        if curves.currentDrawing != nil {
            CanvasView()
        }
        else {
            MenuView()
        }
    }
}
