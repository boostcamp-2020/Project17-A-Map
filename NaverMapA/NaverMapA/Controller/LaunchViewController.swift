//
//  LaunchViewController.swift
//  NaverMapA
//
//  Created by 박태희 on 2020/12/14.
//

import UIKit

class LaunchViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        let circle1 = drawSemiCircle(color: UIColor.systemPurple.cgColor)
        let circle2 = drawSemiCircle(color: UIColor.systemTeal.cgColor)
        circle1.position = CGPoint(x: self.view.layer.bounds.midX + 40, y: self.view.layer.bounds.midY + 100)
        circle2.position = CGPoint(x: self.view.layer.bounds.midX + 40, y: self.view.layer.bounds.midY + 100)
        circle1.zPosition = 1
        circle2.transform = CATransform3DMakeRotation(-(2/8) * .pi, 0, 0, 1)
        
        let scaleDownAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleDownAnimation.repeatCount = 1
        scaleDownAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        scaleDownAnimation.fromValue = 1
        scaleDownAnimation.toValue = 0.9
        scaleDownAnimation.duration = 0.3
        
        let scaleDownAnimation2 = CABasicAnimation(keyPath: "transform.scale")
        scaleDownAnimation2.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        scaleDownAnimation2.fromValue = 1
        scaleDownAnimation2.toValue = 0.9
        scaleDownAnimation2.duration = 0.3
       
        let scaleUpAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleUpAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        scaleUpAnimation.fromValue = 1
        scaleUpAnimation.toValue = 8
        scaleUpAnimation.duration = 0.3
        
        let positionAnimation = CABasicAnimation(keyPath: "position")
        positionAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        positionAnimation.fromValue = CGPoint(x: circle1.position.x, y: circle1.position.y)
        positionAnimation.toValue = CGPoint(x: circle1.position.x, y: circle1.position.y + 1200)
        positionAnimation.duration = 0.3
        
        let scaleUpAnimation2 = CABasicAnimation(keyPath: "transform.scale")
        scaleUpAnimation2.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        scaleUpAnimation2.fromValue = 1
        scaleUpAnimation2.toValue = 8
        scaleUpAnimation2.duration = 0.3
        
        let positionAnimation2 = CABasicAnimation(keyPath: "position")
        positionAnimation2.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        positionAnimation2.fromValue = CGPoint(x: circle2.position.x, y: circle2.position.y)
        positionAnimation2.toValue = CGPoint(x: circle2.position.x, y: circle2.position.y + 1200)
        positionAnimation2.duration = 0.3
        
        CATransaction.begin()
        CATransaction.setCompletionBlock({
            CATransaction.begin()
            CATransaction.setCompletionBlock({
                circle1.removeFromSuperlayer()
                circle2.removeFromSuperlayer()
                self.changeScene()
            })
            circle1.add(scaleUpAnimation, forKey: "transform.scale")
            circle2.add(scaleUpAnimation2, forKey: "transform.scale")
            circle1.add(positionAnimation, forKey: "position")
            circle2.add(positionAnimation2, forKey: "position")
            CATransaction.commit()
        })
        circle1.add(scaleDownAnimation, forKey: "transform.scale")
        circle2.add(scaleDownAnimation2, forKey: "transform.scale")
        CATransaction.commit()
    }
    
    func drawSemiCircle(color: CGColor) -> CAShapeLayer {
        let center: CGPoint = .zero
        let radius: CGFloat = 100
        let bezierPath = UIBezierPath()
        bezierPath.move(to: center)
        bezierPath.addArc(
            withCenter: center,
            radius: 20,
            startAngle: (1/8 * .pi),
            endAngle: (7/8 * .pi),
            clockwise: true
        )
        let center2 = CGPoint(x: center.x, y: center.y - 170)
        bezierPath.addArc(
            withCenter: center2,
            radius: radius,
            startAngle: .pi * (7/8),
            endAngle: (1/8) * .pi,
            clockwise: true
        )
        bezierPath.addLine(to: CGPoint(x: center.x + 20 * cos(.pi * (1/8)),
                                       y: center.y + 20 * sin(.pi * (1/8))))
        bezierPath.close()
        let circle = CAShapeLayer()
        circle.path = bezierPath.cgPath
        circle.fillColor = color
        self.view.layer.addSublayer(circle)
        let innerCircle = configureInnerCircle(center: center2)
        circle.addSublayer(innerCircle)
        return circle
    }
    
    func configureInnerCircle(center: CGPoint) -> CAShapeLayer {
        let radius: CGFloat = self.view.frame.width / 10
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
        //MainViewController.modalTransitionStyle = .crossDissolve
        let window = self.view.window
        self.dismiss(animated: true) {
            window?.rootViewController = MainViewController
            window?.makeKeyAndVisible()
        }
    }
}
