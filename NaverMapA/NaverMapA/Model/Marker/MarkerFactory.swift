//
//  MarkerFactory.swift
//  NaverMapA
//
//  Created by 박태희 on 2020/12/03.
//

import UIKit
import NMapsMap

class MarkerFactory {
    
    let colorSet = [
        [
            UIColor(named: "gradient1-1")?.cgColor,
            UIColor(named: "gradient1-2")?.cgColor,
            UIColor(named: "gradient1-3")?.cgColor
        ],
        [
            UIColor(named: "gradient2-1")?.cgColor,
            UIColor(named: "gradient2-2")?.cgColor,
            UIColor(named: "gradient2-3")?.cgColor
        ],
        [
            UIColor(named: "gradient3-1")?.cgColor,
            UIColor(named: "gradient3-2")?.cgColor,
            UIColor(named: "gradient3-3")?.cgColor
        ]
    ]

    func basicMarkerView(frame: CGRect, color: UIColor, text: String = "", isShawdow: Bool = false) -> UIView {
        let mRect = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        let mlayer = basicMarkerLayer(rect: mRect, color: color, text: text, isShawdow: isShawdow)
        let mView = UIView(frame: frame)
        mView.layer.addSublayer(mlayer)
        return mView
    }
    
    func basicMarkerLayer(rect: CGRect, color: UIColor, text: String = "", isShawdow: Bool = false) -> CALayer {
        let centerX = rect.midX
        let centerY = rect.midY
        let radius = rect.width / 3
        let path = UIBezierPath(arcCenter: CGPoint(x: centerX, y: centerY),
                                radius: radius,
                                startAngle: (30 * .pi) / 180,
                                endAngle: (150 * .pi) / 180,
                                clockwise: false)
        path.addArc(withCenter: CGPoint(x: centerX, y: centerY + radius * 1.2),
                    radius: radius * 0.4,
                    startAngle: (150 * .pi) / 180,
                    endAngle: (30 * .pi) / 180,
                    clockwise: false)

        let markerLayer = CAShapeLayer()
        markerLayer.path = path.cgPath
        markerLayer.fillColor = color.cgColor

        let circleLayer = CALayer()
        circleLayer.frame = CGRect(x: centerX - radius * 0.7, y: centerY - radius * 0.7, width: radius * 1.4, height: radius * 1.4)
        circleLayer.cornerRadius = radius * 0.7
        circleLayer.backgroundColor = UIColor.white.cgColor
        if isShawdow {
            markerLayer.shadowOffset = CGSize(width: 2, height: 2)
            markerLayer.shadowColor = UIColor.black.cgColor
            markerLayer.shadowOpacity = 0.4
            circleLayer.shadowColor = UIColor.black.cgColor
            circleLayer.shadowOpacity = 0.4
            circleLayer.shadowOffset = CGSize(width: 2, height: 2)
        }
        
        let tempFrame = CGRect(x: centerX - radius * 0.5, y: centerY - radius * 0.5, width: radius, height: radius)
        let textLayer = VHCTextLayer(frame: tempFrame, text: text)
        
        markerLayer.addSublayer(circleLayer)
        markerLayer.addSublayer(textLayer)
        return markerLayer
    }
    
    func starMarkerView(frame: CGRect, color: UIColor, text: String = "", isShawdow: Bool = false) -> UIView {
        let mRect = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        let mlayer = starMarkerLayer(rect: mRect, color: color, text: text, isShawdow: isShawdow)
        let mView = UIView(frame: frame)
        mView.layer.addSublayer(mlayer)
        return mView
    }
    
    func starMarkerLayer(rect: CGRect, color: UIColor, text: String = "", isShawdow: Bool = false) -> CALayer {
        let starShape = CAShapeLayer()
        starShape.path = PathMaker().starRounded(width: rect.width, height: rect.height).cgPath
    
        let newLayer = CAGradientLayer()
        newLayer.frame = rect
        newLayer.colors = colorSet[Int.random(in: 0..<colorSet.count)] as [Any]
        newLayer.locations = [0, 0.5, 1]
        newLayer.startPoint = CGPoint(x: 0, y: 0)
        newLayer.endPoint = CGPoint(x: 1, y: 1)
        newLayer.mask = starShape    
        return newLayer
    }
}
