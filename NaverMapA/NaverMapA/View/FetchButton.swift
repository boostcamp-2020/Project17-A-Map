//
//  FetchButton.swift
//  NaverMapA
//
//  Created by 채훈기 on 2020/12/10.
//

import UIKit

class FetchButton: UIButton {
    
    let temp: VHCTextLayer = {
        let t = VHCTextLayer(frame: CGRect(x: 0, y: 0, width: 160, height: 40), text: "Search", fontSize: 17)
        t.foregroundColor = UIColor.white.cgColor
        t.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        t.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        return t
    }()
    
    let temp1: VHCTextLayer = {
        let t = VHCTextLayer(frame: CGRect(x: 0, y: 40, width: 160, height: 40), text: "Searching...", fontSize: 17)
        t.foregroundColor = UIColor.white.cgColor
        t.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        t.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        return t
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit(frame: .zero)
    }
    
    func commonInit(frame: CGRect) {
        layer.cornerRadius = 20
        backgroundColor = .systemBlue
        layer.addSublayer(temp1)
        layer.addSublayer(temp)
        self.clipsToBounds = true
    }
    
    func animation() {

        let animator = CABasicAnimation.transform(fromValue: 0, toValue: -140, valueFunctionName: .translateY, duration: 2)
        animator.timingFunction = CAMediaTimingFunction(name: .easeOut)

        let animator1 = CABasicAnimation.transform(fromValue: 0, toValue: -40, valueFunctionName: .translateY, duration: 0.4)
        animator1.timingFunction = CAMediaTimingFunction(name: .easeOut)
        animator1.beginTime = CACurrentMediaTime() + 0.1
        
        let animator2 = CABasicAnimation.transform(fromValue: 1, toValue: 0, valueFunctionName: .scaleX, duration: 0.4)
        animator2.timingFunction = CAMediaTimingFunction(name: .easeOut)
        animator2.beginTime = CACurrentMediaTime() + 1
        
        CATransaction.begin()
        temp.add(animator, forKey: "d")
        temp1.add(animator1, forKey: "d")
        layer.add(animator2, forKey: "2")

        CATransaction.commit()
    }
    
    func prepareAnimation() {
//        self.temp.frame = CGRect(x: 0, y: 0, width: 160, height: 40)
//        self.temp1.frame = CGRect(x: 0, y: 40, width: 160, height: 40)
    }
}
