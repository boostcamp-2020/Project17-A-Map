//
//  CABasicAnimation+.swift
//  NaverMapA
//
//  Created by 채훈기 on 2020/12/10.
//

import UIKit

extension CABasicAnimation {
    
    // MARK: Fade In Out
    
    static func fadeOut(duration: Double) -> CABasicAnimation {
        return fadeWithOpacity(fromValue: 1, toValue: 0, duration: duration)
    }
    
    static func fadeIn(duration: Double) -> CABasicAnimation {
        return fadeWithOpacity(fromValue: 0, toValue: 1, duration: duration)
    }
    
    static func fadeWithOpacity(fromValue: Double, toValue: Double, duration: Double) -> CABasicAnimation {
        let animation = CABasicAnimation()
        animation.keyPath = AnimationKeyPath.opacity.rawValue
        animation.fromValue = fromValue
        animation.toValue = toValue
        animation.duration = duration
        return animation
    }
    
    // MARK: BackgroundColor
    
    static func backgroundColor(fromValue: UIColor, toValue: UIColor, duration: Double) -> CABasicAnimation {
        let animation = CABasicAnimation()
        animation.keyPath = AnimationKeyPath.backgroundColor.rawValue
        animation.fromValue = fromValue.cgColor
        animation.toValue = toValue.cgColor
        animation.duration = duration
        return animation
    }
    
    // MARK: Position
    
    static func position(fromValue: (Double, Double), toValue: (Double, Double), duration: Double) -> CABasicAnimation {
        let animation = CABasicAnimation()
        animation.keyPath = AnimationKeyPath.position.rawValue
        animation.fromValue = [fromValue.0, fromValue.1]
        animation.toValue = [toValue.0, toValue.1]
        animation.duration = duration
        return animation
    }
    
    static func position(fromValue: CGPoint, toValue: CGPoint, duration: Double) -> CABasicAnimation {
        let animation = CABasicAnimation()
        animation.keyPath = AnimationKeyPath.position.rawValue
        animation.fromValue = fromValue
        animation.toValue = toValue
        animation.duration = duration
        return animation
    }

    // MARK: Transfrom

    static func transform(fromValue: Double, toValue: Double, valueFunctionName: CAValueFunctionName, duration: Double) -> CABasicAnimation {
        let animation = CABasicAnimation()
        animation.keyPath = AnimationKeyPath.transform.rawValue
        animation.valueFunction = CAValueFunction(name: valueFunctionName)
        animation.fromValue = fromValue
        animation.toValue = toValue
        animation.duration = duration
        return animation
    }

    static func transform(fromValue: CATransform3D, toValue: CATransform3D, duration: Double) -> CABasicAnimation {
        let animation = CABasicAnimation()
        animation.keyPath = AnimationKeyPath.transform.rawValue
        animation.fromValue = fromValue
        animation.toValue = toValue
        animation.duration = duration
        return animation
    }
}
