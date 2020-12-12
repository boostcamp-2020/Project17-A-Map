//
//  CAKeyframeAnimation+.swift
//  NaverMapA
//
//  Created by 채훈기 on 2020/12/12.
//

import UIKit

extension CAKeyframeAnimation {
    
    static func position(path: UIBezierPath, duration: Double, repeatCount: Float) -> CAKeyframeAnimation {
        let animation = CAKeyframeAnimation()
        animation.keyPath = AnimationKeyPath.position.rawValue // "position"
        animation.path = path.cgPath
        animation.duration = duration
        animation.timingFunctions = [CAMediaTimingFunction(name: .easeOut)]
        animation.repeatCount = repeatCount
        return animation
    }
    
    static func transfrom(from: CATransform3D, to: CATransform3D, duration: Double, repeatCount: Float) -> CAKeyframeAnimation {
        let animation = CAKeyframeAnimation()
        animation.keyPath = AnimationKeyPath.transform.rawValue
        animation.values = [from, to]
        animation.keyTimes = [0, 1]
        animation.duration = duration
        animation.repeatCount = repeatCount
        return animation
    }
}
