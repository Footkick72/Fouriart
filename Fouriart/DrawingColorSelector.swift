//
//  DrawingColorSelector.swift
//  Fouriart
//
//  Created by Daniel Long on 10/15/21.
//

import Foundation
import SwiftUI

struct DrawingColorSelector: View {
    @State var value : Color = Color(.sRGB, red: 0.0, green: 0.0, blue: 0.0)
    var body: some View {
        ColorPicker("Stroke Color", selection: $value)
            .onChange(of: value) { _ in
                toolOptions.color = UIColor(value)
                toolOptions.save()
            }
            .onAppear {
                value = Color(toolOptions.color)
            }
    }
}
