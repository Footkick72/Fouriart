//
//  MenuView.swift
//  Fouriart
//
//  Created by Daniel Long on 9/24/21.
//

import Foundation
import SwiftUI

struct MenuView: View {
   
    @ScaledMetric var itemWidth: CGFloat = 150
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            let columns = [ GridItem(.flexible(minimum: itemWidth, maximum: 360), spacing: 10),
                            GridItem(.flexible(minimum: itemWidth, maximum: 360), spacing: 10),
                            GridItem(.flexible(minimum: itemWidth, maximum: 360), spacing: 10),
                            GridItem(.flexible(minimum: itemWidth, maximum: 360), spacing: 10),]
            LazyVGrid(columns: columns, alignment: .center, spacing: 10) {
                ForEach(0..<curveData.data.count) { curve_i in
                    ZStack {
                        RoundedRectangle(cornerRadius: 10.0)
                            .padding(-1)
                        RoundedRectangle(cornerRadius: 10.0)
                            .aspectRatio(1.0, contentMode: .fill)
                            .foregroundColor(.white)
                        Image(uiImage: curveData.data[curve_i].getPreviewImage())
                            .resizable()
                            .aspectRatio(1.0, contentMode: .fit)
                    }
                    .onTapGesture {
                        curveData.selectDrawing(curve_i)
                    }
                }
                VStack(spacing: 12.5) {
                    Text("Create")
                        .foregroundColor(.blue)
                        .font(.subheadline)
                    Button(action: {
                        curveData.createNewDrawing()
                    }) {
                        Image(systemName: "plus")
                            .resizable()
                            .frame(width: 50, height: 50)
                    }
                }
            }
            .padding()
        }
    }
}
