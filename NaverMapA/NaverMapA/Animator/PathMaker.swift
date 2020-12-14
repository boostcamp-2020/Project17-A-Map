//
//  PathMaker.swift
//  NaverMapA
//
//  Created by 채훈기 on 2020/12/14.
//

import UIKit

class PathMaker {
    
    func parabola(start: CGPoint, end: CGPoint) -> UIBezierPath {
        let bpath = UIBezierPath()
        let centerX = Double((start.x + end.x) / 2)
        let centerY = Double((start.y + end.y) / 2)
        let newEnd = CGPoint(x: Double(end.x) - centerX, y: Double(end.y) - centerY)
        var direction: Double = -1
        switch (start.x - end.x, start.y - end.y) {
        case let (x, y) where x > 0 && y >= 0:
            direction = 1
        case let (x, y) where x >= 0 && y < 0:
            direction = 1
        case let (x, y) where x < 0 && y <= 0:
            direction = -1
        default:
            direction = -1

        }
        let sinus = sin(90.0 * Double.pi * direction / 180)
        let cosinus = cos(90 * Double.pi * direction / 180)
        let rotatedX = cosinus * Double(newEnd.x) - sinus * Double(newEnd.y)
        let rotatedY = sinus * Double(newEnd.x) + cosinus * Double(newEnd.y)
        let controlPoint = CGPoint(x: rotatedX + centerX, y: rotatedY + centerY)
        
        bpath.move(to: start)
        bpath.addQuadCurve(to: end, controlPoint: controlPoint)
        
        return bpath
    }

    func linear(start: CGPoint, end: CGPoint) -> UIBezierPath {
        let bpath = UIBezierPath()
        bpath.move(to: start)
        bpath.addLine(to: end)
        return bpath
    }
}
