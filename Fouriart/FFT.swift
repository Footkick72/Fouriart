//
//  FFT.swift
//  Fouriart
//
//  Created by Daniel Long on 9/14/21.
//
//
import Foundation
import SwiftUI
import PencilKit

func FFT_pad(points: [CGPoint]) -> [(CGPoint, Bool)] {
    var newPoints: [(CGPoint, Bool)] = []
    for i in 0..<points.count {
        newPoints.append((points[i], true))
    }
    
    var ideal_length = 1
    while ideal_length < points.count {
        ideal_length *= 2
    }
    if ideal_length == points.count {
        return newPoints + [(points[points.count - 2], true)]
    }
    while newPoints.count < ideal_length {
        var largest: [Double] = [0.0, 0.0]
        for i in 0..<newPoints.count - 1 {
            if Double(dist(newPoints[i].0, newPoints[i+1].0)) > largest[0] {
                largest = [Double(dist(newPoints[i].0, newPoints[i+1].0)), Double(i)]
            }
        }
        let p1: CGPoint = newPoints[Int(largest[1])].0
        let p2: CGPoint = newPoints[Int(largest[1] + 1)].0
        let midpoint: CGPoint = CGPoint(x: 0.5 * (p1.x + p2.x), y: 0.5 * (p1.y + p2.y))
        newPoints.insert((midpoint, false), at: Int(largest[1] + 1))
    }
    return newPoints + [(points[points.count - 2], true)]
    }


func dist(_ p1: CGPoint, _ p2: CGPoint) -> Float {
    return Float(sqrt(pow(p1.x - p2.x, 2) + pow(p1.y - p2.y, 2)))
}
