//
//  MenuView.swift
//  Fouriart
//
//  Created by Daniel Long on 9/24/21.
//

import Foundation
import SwiftUI

struct MenuView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var data = curveData
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            let columns = [ GridItem(.flexible(minimum: 0, maximum: 360), spacing: 10),
                            GridItem(.flexible(minimum: 0, maximum: 360), spacing: 10),
                            GridItem(.flexible(minimum: 0, maximum: 360), spacing: 10),
                            GridItem(.flexible(minimum: 0, maximum: 360), spacing: 10),]
            LazyVGrid(columns: columns, alignment: .center, spacing: 10) {
                ForEach(0..<data.data.count, id: \.self) { curve_i in
                    ZStack {
                        RoundedRectangle(cornerRadius: 10.0)
                            .padding(-1)
                        RoundedRectangle(cornerRadius: 10.0)
                            .aspectRatio(1.0, contentMode: .fill)
                            .foregroundColor(.white)
                        Image(uiImage: data.data[curve_i].getPreviewImage())
                            .resizable()
                            .aspectRatio(1.0, contentMode: .fit)
                        GeometryReader { geometry in
                            Button(action: {
                                data.deleteDrawing(curve_i)
                            }) {
                                Image(systemName: "xmark.circle")
                                    .foregroundColor(.red)
                                    .font(.title2)
                                    .background(
                                        Circle()
                                            .foregroundColor(colorScheme == .light ? .white : Color(.sRGB, red: 27.0/255.0, green: 27.0/255.0, blue: 28.0/255.0, opacity: 1.0))
                                    )
                            }
                            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .topTrailing)
                            .offset(x: 5, y: -5)
                        }
                    }
                    .onTapGesture {
                        data.selectDrawing(curve_i)
                    }
                }
                VStack(spacing: 12.5) {
                    Text("Create")
                        .foregroundColor(.blue)
                        .font(.subheadline)
                    Button(action: {
                        data.createNewDrawing()
                    }) {
                        Image(systemName: "plus")
                            .font(.largeTitle)
                    }
                }
            }
            .padding()
        }
    }
}
