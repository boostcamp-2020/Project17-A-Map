//
//  StarAnimator.swift
//  NaverMapA
//
//  Created by 채훈기 on 2020/12/12.
//

import UIKit
import NMapsMap

class StarAnimation: MoveAnimator1 {

    override func animateOneView(startPoint: CGPoint, endPoint: CGPoint, beforeCluster: Cluster, afterClusters: [Cluster]) {
        let layerWidth = NMFMarker().iconImage.imageWidth
        let layerHeight = NMFMarker().iconImage.imageHeight
        let animation = makePathScaleAnimation(start: startPoint, end: endPoint, duration: 0.6, repeatCount: 1, delay: 0)
        let markerLayer = markerFactory.makeStarLayer(rect: CGRect(x: -100, y: -100, width: layerWidth, height: layerHeight), color: markerColor)
        markerLayer.anchorPoint = CGPoint(x: 0.5, y: 1)
        animationLayer.addSublayer(markerLayer)
        isAnimating = true
        count += 1
        queue.async {
            CATransaction.begin()
            CATransaction.setCompletionBlock {
                self.count -= 1
                markerLayer.removeFromSuperlayer()

                if self.count == 0 && self.isAnimating {
                    self.isAnimating = false
                    self.moveCompletionHandler(afterClusters, self.markerColor)
                }
            }
            markerLayer.add(animation, forKey: "")
            CATransaction.commit()
        }
    }
    
    func makePathScaleAnimation(start: CGPoint, end: CGPoint, duration: CFTimeInterval, repeatCount: Float, delay: Double) -> CAAnimationGroup {
        let bpath = makeParabolaPath(start: start, end: end)
        let pathAnimation = CAKeyframeAnimation.position(path: bpath, duration: duration, repeatCount: repeatCount)

        let from = CATransform3DMakeAffineTransform(CGAffineTransform(scaleX: 0.8, y: 0.8))
        let to = CATransform3DMakeAffineTransform(CGAffineTransform(scaleX: 0.4, y: 0.4))
        let rotate = CAKeyframeAnimation.transfrom(from: from, to: to, duration: duration, repeatCount: repeatCount)

        let groupAnimation = CAAnimationGroup()
        groupAnimation.animations = [rotate, pathAnimation]
        groupAnimation.duration = duration * Double(repeatCount)
        groupAnimation.beginTime = CACurrentMediaTime() + delay * 1
        
        return groupAnimation
    }
    
    func makeParabolaPath(start: CGPoint, end: CGPoint) -> UIBezierPath {
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

    func makeLinearPath(start: CGPoint, end: CGPoint) -> UIBezierPath {
        let bpath = UIBezierPath()
        bpath.move(to: start)
        bpath.addLine(to: end)
        return bpath
    }
}
