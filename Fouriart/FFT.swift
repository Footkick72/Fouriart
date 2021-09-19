////
////  FFT.swift
////  Fouriart
////
////  Created by Daniel Long on 9/14/21.
////
//
import Foundation
import SwiftUI
import PencilKit
//
//func FFT(curve: [CGPoint]) -> [CGPoint] { //ONLY WORKS ON LISTS OF LENGTH POWER OF 2
//    var resultCurve = curve
//    var n = curve.count
//    var omega = -2.0*Double.pi/Double(n)
//    var xk: CGPoint
//    var wk: CGVector
//    if n > 1 {
//        var even = []
//        var odd = []
//        for i in stride(from: 0, to: n, by: 2) {
//            even.append(curve[i])
//            odd.append(curve[i+1])
//        }
//        resultCurve = FFT(even) + FFT(odd)
//        for k in 0..<n/2 {
//            wk = CGVector(dx: cos(Double(k) * omega), dy: sin(Double(k) * omega))
//            xk = resultCurve[k]
//            resultCurve[k] = xk + cmult(wk, resultCurve[k+n/2])
//            resultCurve[k+n/2] = xk - cmult(wk, resultCurve[k+n/2])
//        }
//        for i in 0..<n {
//            resultCurve[i] = CGPoint(x: resultCurve[i].x/2, y: resultCurve[i].y/2)
//        }
//    }
//    return resultCurve
//}
//
//func IFFT(X) { //ONLY WORKS ON LISTS OF LENGTH POWER OF 2
//    var n = len(X)
//    var omega = 2*PI/n
//    var xk
//    var wk
//    if n > 1:
//        var even = []
//        var odd = []
//        for i in range(0,n,2):
//            even.append(X[i])
//            odd.append(X[i+1])
//        X = IFFT(even) + IFFT(odd)
//        for k in range(n/2):
//            wk = Vector2(cos(k * omega), sin(k * omega))
//            xk = X[k]
//            X[k] = xk + cmult(wk, X[k+n/2])
//            X[k+n/2] = xk - cmult(wk, X[k+n/2])
//    return X
//}
//
//func cmult(a: CGPoint, b: CGPoint) -> CGVector {
//    return CGVector(dx: a.x*b.x - a.y*b.y, dy: a.x*b.y + a.y*b.x)
//}
//
//func FFT_pad(points: [CGPoint]) {
//    var length = 0
//    for i in range(len(points) - 1):
//        length += dist(points[i], points[i + 1])
//    var ideal_len = 1
//    while ideal_len < len(points) * 4 - 1:
//        ideal_len *= 2
//    ideal_len = min(1024,ideal_len)
//    var ideal_dist = length / ideal_len
//    var new_points = [points[0]]
//    var pos = 0
//    var index = 0
//    var next_sample = ideal_dist
//    while true:
//        var p2 = points[index + 1]
//        var p1 = points[index]
//        var next_pos = pos + dist(p1, p2)
//        while next_sample <= next_pos:
//            var alpha = (next_sample - pos) / (next_pos - pos)
//            new_points.append((1-alpha) * p1 + alpha * p2)
//            if len(new_points) >= ideal_len:
//                new_points.append(points[0])
//                return new_points
//            next_sample += ideal_dist
//        pos = next_pos
//        index += 1
//}

//def resample(points,min_points):
//    n=len(points)
//    while min_points<n:
//        min_points*=2
//    if min_points==n:
//        return points
//    points_times=list(zip(points,range(n)))
//    points_times.append((points[0],n))
//    h=[]
//    for i in range(n):
//        ip1=i+1
//        start=points_times[i][0]
//        end=points_times[ip1][0]
//        h.append((-abs(end-start),i,ip1))
//    heapify(h)
//    while n<min_points:
//        _,i1,i2=heappop(h)
//        pi1,ti1=points_times[i1]
//        pi2,ti2=points_times[i2]
//        midp=0.5*(pi1+pi2)
//        midpi=len(points_times)
//        points_times.append((midp,0.5*(ti1+ti2)))
//        heappush(h,(-abs(midp-pi1),i1,midpi))
//        heappush(h,(-abs(pi2-midp),midpi,i2))
//        n+=1
//    return list(map(lambda x:x[0],sorted(points_times[1:],key=lambda x:x[1])))
func FFT_pad(points: [CGPoint]) -> [CGPoint] {
    var ideal_length = 1
    while ideal_length < points.count {
        ideal_length *= 2
    }
    if ideal_length == points.count {
        return points + [points[points.count - 2]]
    }
    var newPoints = points
    while newPoints.count < ideal_length {
        var largest: [Double] = [0.0, 0.0]
        for i in 0..<newPoints.count - 1 {
            if Double(dist(newPoints[i], newPoints[i+1])) > largest[0] {
                largest = [Double(dist(newPoints[i], newPoints[i+1])), Double(i)]
            }
        }
        let p1: CGPoint = newPoints[Int(largest[1])]
        let p2: CGPoint = newPoints[Int(largest[1] + 1)]
        let midpoint: CGPoint = CGPoint(x: 0.5 * (p1.x + p2.x), y: 0.5 * (p1.y + p2.y))
        newPoints.insert(midpoint, at: Int(largest[1] + 1))
    }
    return newPoints + [points[points.count - 2]]
    }
//func FFT_pad(points: [CGPoint]) -> [CGPoint] {
//    var length: Float = 0
//    for i in 0..<points.count - 1 {
//        length += dist(points[i], points[i+1])
//    }
//    var ideal_length = 1
//    while ideal_length < points.count * 4 - 1 {
//        ideal_length *= 2
//    }
////    ideal_length = min(1024, ideal_length) //deprecated maximum length
//    let ideal_distance = length / Float(ideal_length)
//    var new_points: [CGPoint] = []
//    var pos: Float = 0
//    var index = 0
//    var next_sample = ideal_distance
//    var added_points = 0
//    while true {
//        new_points.append(points[index])
//        let p2 = points[index + 1]
//        let p1 = points[index]
//        let next_pos = pos + dist(p1, p2)
//        while next_sample <= next_pos {
//            let alpha = CGFloat((next_sample - pos) / (next_pos - pos))
//            new_points.append(CGPoint(x: (1.0 - alpha) * p1.x + alpha * p2.x,
//                                      y: (1.0 - alpha) * p1.y + alpha * p2.y))
//            added_points += 1
//            if added_points + points.count >= ideal_length {
//                for i in index + 1 ..< points.count {
//                    new_points.append(points[i])
//                }
//                return new_points
//            }
//            next_sample += ideal_distance
//        }
//        pos = next_pos
//        index += 1
//    }
//}


func dist(_ p1: CGPoint, _ p2: CGPoint) -> Float {
    return Float(sqrt(pow(p1.x - p2.x, 2) + pow(p1.y - p2.y, 2)))
}
//
//func reduce(points, n_coeffs):
//    var transform
//    if fourier_transform:
//        transform = fourier_transform.duplicate()
//    else:
//        var points2 = Array(points)
//        points2.remove(len(points2) - 1)
//        transform = FFT(points2)
//        fourier_transform = transform.duplicate()
//    var transform_index = []
//    for i in range(len(transform)):
//        transform_index.append([transform[i],i])
//    transform_index.sort_custom(self, "FFT_comp")
//    for i in range(n_coeffs + 1,len(transform_index)):
//        if transform_index[i][1] != 0:
//            transform[transform_index[i][1]] = Vector2(0,0)
//    var result = IFFT(transform)
//    return result + [result[0]]
//
//func FFT_comp(a,b):
//    return a[0].length() > b[0].length()
