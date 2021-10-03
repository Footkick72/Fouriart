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
                            GridItem(.flexible(minimum: itemWidth, maximum: 360), spacing: 10),]
            LazyVGrid(columns: columns, alignment: .center, spacing: 10) {
                ForEach(0..<curveData.data.count) { curve_i in
                    RoundedRectangle(cornerRadius: 10.0)
                        .onTapGesture {
                            curveData.selectDrawing(curve_i)
                        }
                }
//                ForEach(Array(DocType.defaults.keys).sorted(by: {a, b in
//                    return a.lastPathComponent < b.lastPathComponent
//                }), id: \.self) { key in
//                    if let set = DocType.defaults[key] {
//                        VStack {
//                            Text(verbatim: key.lastPathComponent.removeExtension(DocType.fileExtension))
//                                .font(.subheadline)
//                            Image(uiImage: set.getPreview())
//                                .resizable()
//                                .aspectRatio(contentMode: .fit)
//                                .frame(maxWidth: itemWidth)
//                                .border(Color.black, width: 1)
//                                .overlay(
//                                    Text(set.isCompleteFor(text: textToGenerate) ? "" : "Warning: Missing characters!")
//                                        .font(.callout)
//                                        .foregroundColor(.red)
//                                        .multilineTextAlignment(.center)
//                                        .padding(5)
//                                        .background(
//                                            RoundedRectangle(cornerRadius: 25.0, style: .continuous)
//                                                .foregroundColor(colorScheme == .light ? .white : Color(.sRGB, red: 27.0/255.0, green: 27.0/255.0, blue: 28.0/255.0, opacity: 1.0))
//                                                .opacity(set.isCompleteFor(text: textToGenerate) ? 0.0 : 1.0)
//                                        )
//                                )
//                        }
//                        .padding()
//                        .border(Color.black, width: objectCatalog.isSelectedDocument(path: key) ? 1 : 0)
//                        .onTapGesture() {
//                            objectCatalog.documentPath = key
//                            objectCatalog.save()
//                            showingSelector = false
//                        }
//                    }
//                }
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
        }
    }
}
