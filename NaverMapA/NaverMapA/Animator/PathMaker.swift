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
    
    func star(width: CGFloat, height: CGFloat) -> UIBezierPath {
        let path = UIBezierPath()
        let starExtrusion: CGFloat = width / 4
        let center = CGPoint(x: width / 2.0, y: height / 2.0)
        let pointsOnStar = 5
        var angle: CGFloat = -CGFloat(Double.pi / 2.0)
        let angleIncrement = CGFloat(Double.pi * 2.0 / Double(pointsOnStar))
        let radius = width / 2.0
        var firstPoint = true

        for _ in 1...pointsOnStar {
            let point = pointFrom(angle, radius: radius, offset: center)
            let nextPoint = pointFrom(angle + angleIncrement, radius: radius, offset: center)
            let midPoint = pointFrom(angle + angleIncrement / 2.0, radius: starExtrusion, offset: center)
            if firstPoint {
                firstPoint = false
                path.move(to: point)
            }
            path.addLine(to: midPoint)
            path.addLine(to: nextPoint)
            angle += angleIncrement
        }
        path.close()

        return path
    }
    
    func starRounded(width: CGFloat, height: CGFloat) -> UIBezierPath {
        let center = CGPoint(x: width / 2.0, y: height / 2.0)
        let radius = width / 2
        let pointsOnStar = 5
        var angle: CGFloat = -CGFloat(Double.pi / 2.0)
        let angleIncrement = CGFloat(Double.pi * 2.0 / Double(pointsOnStar))
        let pointAngle: CGFloat = (.pi - angleIncrement) / 2
        let starExtrusion: CGFloat = width / 4

        let edgeRadiusPoint = pointFrom(angle, radius: radius * 0.9, offset: center)
        let path = UIBezierPath(arcCenter: edgeRadiusPoint,
                                radius: radius * 0.1,
                                startAngle: angle - pointAngle,
                                endAngle: angle + pointAngle,
                                clockwise: true)
        for _ in 1..<pointsOnStar {
            let midPoint = pointFrom(angle + angleIncrement / 2.0, radius: starExtrusion, offset: center)
            let edgeRadiusPoint = pointFrom(angle + angleIncrement, radius: radius * 0.9, offset: center)
            path.addLine(to: midPoint)
            path.addArc(withCenter: edgeRadiusPoint, radius: radius * 0.1, startAngle: angle + angleIncrement - pointAngle, endAngle: angle + angleIncrement + pointAngle, clockwise: true)
            angle += angleIncrement
            
        }
        let midPoint = pointFrom(angle + angleIncrement / 2.0, radius: starExtrusion, offset: center)
        path.addLine(to: midPoint)
        path.close()
        
        return path

    }
    
    private func pointFrom(_ angle: CGFloat, radius: CGFloat, offset: CGPoint) -> CGPoint {
        return CGPoint(x: radius * cos(angle) + offset.x,
                       y: radius * sin(angle) + offset.y)
    }
}
