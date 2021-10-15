//
//  CurveData.swift
//  Fouriart
//
//  Created by Daniel Long on 9/27/21.
//

import Foundation
import SwiftUI

var curveData = CurveData()
fileprivate let savePath = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first!.appendingPathComponent("drawings")

class CurveData: Codable, ObservableObject {
    var data: [FFTDrawing] = []
    var currentDrawing: Int? = nil
    
    func selectDrawing(_ i:Int) {
        currentDrawing = i
        objectWillChange.send()
    }
    
    func createNewDrawing() {
        data.append(FFTDrawing())
        currentDrawing = data.count - 1
        save()
        objectWillChange.send()
    }
    
    func unselectDrawing() {
        currentDrawing = nil
        save()
        objectWillChange.send()
    }
    
    func deleteDrawing(_ i: Int) {
        data.remove(at: i)
        save()
        objectWillChange.send()
    }
    
    func save() {
        let data = try! JSONEncoder().encode(self)
        if !FileManager.default.fileExists(atPath: savePath.absoluteString) {
            FileManager.default.createFile(atPath: savePath.absoluteString, contents: Data())
        }
        try! data.write(to: savePath)
    }
    
    func load() {
        do {
            let data = try Data(contentsOf: savePath)
            let loaded = try! JSONDecoder().decode(CurveData.self, from: data)
            self.data = loaded.data
            self.currentDrawing = loaded.currentDrawing
        } catch {
            print(error)
            return // no saved data exists
        }
    }
}
