//
//  LaunchViewController.swift
//  NaverMapA
//
//  Created by 박태희 on 2020/12/14.
//

import UIKit

class LaunchViewController: UIViewController {
    
    var height: CGFloat = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        startSplash()
    }
    
    func startSplash() {
        self.view.backgroundColor = .white
        let marker1 = drawMarker(color: UIColor.systemPurple.cgColor)
        let marker2 = drawMarker(color: UIColor.systemTeal.cgColor)
        let plusX = self.view.frame.width / 8
        marker1.position = CGPoint(x: self.view.layer.bounds.midX + plusX, y: self.view.layer.bounds.midY + (self.height / 2))
        marker2.position = CGPoint(x: self.view.layer.bounds.midX + plusX, y: self.view.layer.bounds.midY + (self.height / 2))
        marker1.zPosition = 1
        marker2.transform = CATransform3DMakeRotation(-(2/8) * .pi, 0, 0, 1)
        
        marker1.shadowOpacity = 1
        marker2.shadowOpacity = 1
        marker1.shadowColor = UIColor.systemGray3.cgColor
        marker2.shadowColor = UIColor.systemGray.cgColor
        
        let group = CAAnimationGroup()
        let group2 = CAAnimationGroup()
        
        let scaleDownAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleDownAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        scaleDownAnimation.isRemovedOnCompletion = false
        scaleDownAnimation.fillMode = .backwards
        scaleDownAnimation.beginTime = 0.3
        scaleDownAnimation.fromValue = 1
        scaleDownAnimation.toValue = 0.9
        scaleDownAnimation.duration = 0.3
        
        let scaleDownAnimation2 = CABasicAnimation(keyPath: "transform.scale")
        scaleDownAnimation2.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        scaleDownAnimation2.isRemovedOnCompletion = false
        scaleDownAnimation2.fillMode = .backwards
        scaleDownAnimation2.beginTime = 0.3
        scaleDownAnimation2.fromValue = 1
        scaleDownAnimation2.toValue = 0.9
        scaleDownAnimation2.duration = 0.3
       
        let scaleUpAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleUpAnimation.isRemovedOnCompletion = false
        scaleUpAnimation.fillMode = .forwards
        scaleUpAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        scaleUpAnimation.beginTime = 0.6
        scaleUpAnimation.fromValue = 1
        scaleUpAnimation.toValue = 14
        scaleUpAnimation.duration = 0.3
        
        let positionAnimation = CABasicAnimation(keyPath: "position")
        positionAnimation.isRemovedOnCompletion = false
        positionAnimation.fillMode = .forwards
        positionAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        positionAnimation.beginTime = 0.6
        positionAnimation.fromValue = CGPoint(x: marker1.position.x, y: marker1.position.y)
        positionAnimation.toValue = CGPoint(x: marker1.position.x, y: marker1.position.y * 5)
        positionAnimation.duration = 0.3
        
        let scaleUpAnimation2 = CABasicAnimation(keyPath: "transform.scale")
        scaleUpAnimation2.isRemovedOnCompletion = false
        scaleUpAnimation2.fillMode = .forwards
        scaleUpAnimation2.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        scaleUpAnimation2.beginTime = 0.6
        scaleUpAnimation2.fromValue = 1
        scaleUpAnimation2.toValue = 14
        scaleUpAnimation2.duration = 0.3
        
        let positionAnimation2 = CABasicAnimation(keyPath: "position")
        positionAnimation2.isRemovedOnCompletion = false
        positionAnimation2.fillMode = .forwards
        positionAnimation2.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        positionAnimation2.beginTime = 0.6
        positionAnimation2.fromValue = CGPoint(x: marker2.position.x, y: marker2.position.y)
        positionAnimation2.toValue = CGPoint(x: marker2.position.x, y: marker2.position.y * 5)
        positionAnimation2.duration = 0.3
        
        group.animations = [
            scaleDownAnimation,
            scaleUpAnimation,
            positionAnimation
        ]
        group.duration = 0.9
        group.isRemovedOnCompletion = false
        group.fillMode = .forwards
        
        group2.animations = [
            scaleDownAnimation2,
            scaleUpAnimation2,
            positionAnimation2
        ]
        group2.duration = 0.9
        group2.isRemovedOnCompletion = false
        group2.fillMode = .forwards
        
        CATransaction.begin()
        CATransaction.setCompletionBlock({
            marker1.removeFromSuperlayer()
            marker2.removeFromSuperlayer()
            self.changeScene()
        })
        marker1.add(group, forKey: nil)
        marker2.add(group2, forKey: nil)
        CATransaction.commit()
    }
    
    func drawMarker(color: CGColor) -> CAShapeLayer {
        let center: CGPoint = .zero
        let radius: CGFloat = self.view.frame.width / 4
        let radius2: CGFloat = self.view.frame.width / 12
        let height = radius * 1.5
        self.height = height
        let bezierPath = UIBezierPath()
        bezierPath.move(to: center)
        bezierPath.addArc(
            withCenter: center,
            radius: radius2,
            startAngle: (1/8 * .pi),
            endAngle: (7/8 * .pi),
            clockwise: true
        )
        let center2 = CGPoint(x: center.x, y: center.y - height)
        bezierPath.addArc(
            withCenter: center2,
            radius: radius,
            startAngle: .pi * (7/8),
            endAngle: (1/8) * .pi,
            clockwise: true
        )
        bezierPath.addLine(to: CGPoint(x: center.x + radius2 * cos(.pi * (1/8)),
                                       y: center.y + radius2 * sin(.pi * (1/8))))
        bezierPath.close()
        let circle = CAShapeLayer()
        circle.path = bezierPath.cgPath
        circle.fillColor = color
        self.view.layer.addSublayer(circle)
        let innerCircle = configureInnerCircle(center: center2)
        circle.addSublayer(innerCircle)
        innerCircle.shadowOpacity = 1
        innerCircle.shadowColor = UIColor.systemGray.cgColor
        return circle
    }

    func configureInnerCircle(center: CGPoint) -> CAShapeLayer {
        let radius: CGFloat = self.view.frame.width / 8
        let bezierPath = UIBezierPath()
        bezierPath.move(to: center)
        bezierPath.addArc(
            withCenter: center,
            radius: radius,
            startAngle: 0,
            endAngle: 2 * .pi,
            clockwise: true
        )
        bezierPath.close()
        let innerCircle = CAShapeLayer()
        innerCircle.path = bezierPath.cgPath
        innerCircle.fillColor = UIColor.white.cgColor
        return innerCircle
    }
    
    func changeScene() {
        let MainViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainScene")
        MainViewController.modalPresentationStyle = .fullScreen
        let window = self.view.window
        self.dismiss(animated: false) {
            window?.rootViewController = MainViewController
            window?.makeKeyAndVisible()
        }
    }
}
