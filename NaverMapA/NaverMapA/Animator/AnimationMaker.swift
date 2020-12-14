//
//  AnimationMaker.swift
//  NaverMapA
//
//  Created by 채훈기 on 2020/12/14.
//

import UIKit

class AnimationMaker {
    
    let pathMaker: PathMaker
    
    init(pathMaker: PathMaker) {
        self.pathMaker = pathMaker
    }
    
    func pathScale(start: CGPoint, end: CGPoint, duration: CFTimeInterval, repeatCount: Float, delay: Double) -> CAAnimationGroup {
        let bpath = pathMaker.parabola(start: start, end: end)
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
    
    func scaleY() -> CAAnimation {
        return CABasicAnimation.transform(fromValue: 0, toValue: 1, valueFunctionName: .scaleY, duration: 0.4)
    }
    
    func position(start: CGPoint, end: CGPoint) -> CAAnimation {
        return CABasicAnimation.position(fromValue: start, toValue: end, duration: 0.4)
    }
}
