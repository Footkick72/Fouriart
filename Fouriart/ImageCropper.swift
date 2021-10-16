//
//  ImageCropper.swift
//  Fouriart
//
//  Created by Daniel Long on 10/16/21.
//

import Foundation
import SwiftUI

struct ImageCropper: View {
    let forgroundDrawing: UIImage
    let onImagePicked: (CGFloat, CGSize, CGFloat, UIImage) -> Void
    
    @State var image: UIImage? = nil
    @State var imageScale: CGFloat = 1.0
    @State var lastImageScale: CGFloat = 1.0
    @State var imageOffset: CGSize = CGSize()
    @State var lastDragEndPos: CGSize = CGSize()
    @State var imageRotation: CGFloat = 0.0
    @State var lastImageRotation: CGFloat = 0.0
    
    var body: some View {
        if self.image != nil {
            Image(uiImage: forgroundDrawing)
                .resizable()
                .scaledToFit()
                .overlay(
                    Button("Ok") {
                        onImagePicked(imageScale, imageOffset, imageRotation, image!)
                    }
                    .frame(maxWidth: 10000, maxHeight: 10000, alignment: .topLeading)
                )
                .background(
                    Image(uiImage: self.image!)
                        .scaleEffect(imageScale)
                        .rotationEffect(Angle(degrees: imageRotation))
                        .offset(imageOffset)
                        .opacity(0.2)
                )
            .gesture(
                DragGesture()
                    .onChanged() { v in
                        imageOffset = CGSize(width: v.translation.width + lastDragEndPos.width, height: v.translation.height + lastDragEndPos.height)
                    }
                    .onEnded() { v in
                        lastDragEndPos = imageOffset
                    }
            )
            .simultaneousGesture(
                RotationGesture()
                    .onChanged() { v in
                        imageRotation = CGFloat(v.degrees) + lastImageRotation
                    }
                    .onEnded() { v in
                        lastImageRotation = imageRotation
                    }
            )
            .simultaneousGesture(
                MagnificationGesture()
                    .onChanged() { v in
                        imageScale = sqrt(v.magnitude) * lastImageScale
                    }
                    .onEnded() { v in
                        lastImageScale = imageScale
                    }
            )
        } else {
            ImagePicker(sourceType: .photoLibrary, onImagePicked: { i in self.image = i })
        }
    }
}
