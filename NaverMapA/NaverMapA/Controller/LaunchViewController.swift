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
}
