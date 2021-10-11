//
//  DrawingThicknessSlider.swift
//  Fouriart
//
//  Created by Daniel Long on 10/10/21.
//

import Foundation
import SwiftUI

struct DrawingThicknessSlider: View {
    @State var value : Float = 0.0
    var body: some View {
        Slider(value: $value, in: 2...50, label: {Text("Stroke Weight")})
            .onChange(of: value) { _ in
                toolOptions.size = CGFloat(value)
                toolOptions.save()
            }
            .onAppear {
                value = Float(toolOptions.size)
            }
    }
}
