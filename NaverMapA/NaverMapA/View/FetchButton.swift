//
//  FetchButton.swift
//  NaverMapA
//
//  Created by 채훈기 on 2020/12/10.
//

import UIKit

class FetchButton: UIButton {
    
    var search: VHCTextLayer!
    var searching: AniTextLayer!
    var searching2: AniTextLayer!
    var success: VHCTextLayer!
    var isAnimating = false
    let containerLayer = CALayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit(frame: .zero)
    }
    
    func commonInit(frame: CGRect) {
        let w = frame.width
        let h = frame.height
        containerLayer.frame = CGRect(x: 0, y: 0, width: w, height: h)
        containerLayer.cornerRadius = 20
        layer.cornerRadius = 20
        backgroundColor = .systemBlue
        setupLabels(frame: frame)
        
        containerLayer.addSublayer(search)
        containerLayer.addSublayer(searching)
        containerLayer.addSublayer(searching2)
        containerLayer.addSublayer(success)
        containerLayer.masksToBounds = true
        layer.addSublayer(containerLayer)
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.6
        layer.shadowOffset = CGSize(width: 0, height: 2)
    }
    
    func setupLabels(frame: CGRect) {
        let w = frame.width
        let h = frame.height
        let tfont = UIFont.systemFont(ofSize: 17, weight: .semibold)
        let currentFrame = CGRect(x: 0, y: 0, width: w, height: h)
        let belowFrame = CGRect(x: 0, y: 40, width: w, height: h)
        
        search = VHCTextLayer(frame: currentFrame, text: "Search", fontSize: 17)
        search.foregroundColor = UIColor.white.cgColor
        search.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        search.font = tfont
        
        searching = AniTextLayer(frame: belowFrame, text: "Searching...", charFont: tfont)
        searching.foregroundColor = UIColor.white.cgColor
        searching.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        searching2 = AniTextLayer(frame: currentFrame, text: "Searching...", charFont: tfont)
        searching2.foregroundColor = UIColor.white.cgColor
        searching2.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        searching2.isHidden = true
        
        success = VHCTextLayer(frame: belowFrame, text: "Success😄", fontSize: 17)
        success.foregroundColor = UIColor.white.cgColor
        success.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        success.font = tfont
    }
    
    private func slideUp(from: Double, to: Double, duration: Double = 0.3, delay: Double) -> CAAnimation {
        let ani = CABasicAnimation.transform(fromValue: from, toValue: to, valueFunctionName: .translateY, duration: duration)
        ani.timingFunction = CAMediaTimingFunction(name: .easeOut)
        ani.beginTime = CACurrentMediaTime() + delay
        ani.isRemovedOnCompletion = false
        ani.fillMode = .forwards
        return ani
    }
    
    func animation() {
        guard !isAnimating else { return }
        isAnimating = true
        let slideAnimation = slideUp(from: 0, to: -40, delay: 0)
        search.add(slideAnimation, forKey: nil)
        searching.add(slideAnimation, forKey: nil)
        self.searching.animating(delay: 1)
    }
    
    func endAnimation() {
        guard isAnimating else { return }

        searching.cancelAnimation()
        searching2.isHidden = false
        searching.removeFromSuperlayer()
        
        let searchUp = slideUp(from: 0, to: -40, delay: 0.5)
        let searchingUp = slideUp(from: 0, to: -40, delay: 0.5)

        let colorAnimation = CABasicAnimation()
        colorAnimation.keyPath = AnimationKeyPath.backgroundColor.rawValue
        colorAnimation.fromValue = UIColor.systemBlue.cgColor
        colorAnimation.toValue = UIColor.systemGreen.cgColor
        colorAnimation.duration = 0.2
        colorAnimation.beginTime = CACurrentMediaTime() + 0.9
        colorAnimation.isRemovedOnCompletion = false
        colorAnimation.fillMode = .forwards
        
        let btnUpAnimation = CAKeyframeAnimation()
        btnUpAnimation.keyPath = AnimationKeyPath.transform.rawValue
        btnUpAnimation.valueFunction = CAValueFunction(name: .translateY)
        btnUpAnimation.keyTimes = [0, 0.2, 1]
        btnUpAnimation.values = [0, 20, -100]
        btnUpAnimation.duration = 0.2
        btnUpAnimation.timingFunctions = [CAMediaTimingFunction(name: .easeOut)]
        btnUpAnimation.beginTime = CACurrentMediaTime() + 1.4
        btnUpAnimation.isRemovedOnCompletion = false
        btnUpAnimation.fillMode = .forwards
        btnUpAnimation.delegate = self
        
        searching2.add(searchUp, forKey: "")
        success.add(searchingUp, forKey: "")
        layer.add(colorAnimation, forKey: "")
        layer.add(btnUpAnimation, forKey: "")
    }
}

extension FetchButton: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        isAnimating = false
    }
}
