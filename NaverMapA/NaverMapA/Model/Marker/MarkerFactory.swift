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
         UIColor(red: 255/255, green: 151/255, blue: 96/255, alpha: 1).cgColor,
         UIColor(red: 255/255, green: 218/255, blue: 140/255, alpha: 1).cgColor,
         UIColor(red: 255/255, green: 159/255, blue: 195/255, alpha: 1).cgColor
         ],
         [
         UIColor(red: 140/255, green: 122/255, blue: 250/255, alpha: 1).cgColor,
         UIColor(red: 127/255, green: 164/255, blue: 250/255, alpha: 1).cgColor,
         UIColor(red: 109/255, green: 206/255, blue: 244/255, alpha: 1).cgColor
         ],
         [
         UIColor(red: 104/255, green: 186/255, blue: 197/255, alpha: 1).cgColor,
         UIColor(red: 140/255, green: 206/255, blue: 185/255, alpha: 1).cgColor,
         UIColor(red: 199/255, green: 237/255, blue: 173/255, alpha: 1).cgColor
         ]
    ]
    
    func setLayout(label: UILabel, markerImageView: UIImageView) {
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.cornerRadius = 10
        label.leadingAnchor.constraint(equalTo: markerImageView.leadingAnchor, constant: 8).isActive = true
        label.trailingAnchor.constraint(equalTo: markerImageView.trailingAnchor, constant: -8).isActive = true
        label.topAnchor.constraint(equalTo: markerImageView.topAnchor, constant: 8).isActive = true
        label.bottomAnchor.constraint(equalTo: markerImageView.bottomAnchor, constant: -18).isActive = true
    }
    
    func makeCmarkerView(frame: CGRect, color: UIColor, text: String = "", isShawdow: Bool = false) -> UIView {
        let mRect = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        let mlayer = makeCMarkerLayer(rect: mRect, color: color, text: text, isShawdow: isShawdow)
        let mView = UIView(frame: frame)
        mView.layer.addSublayer(mlayer)
        return mView
    }
    
    func makeCMarkerLayer(rect: CGRect, color: UIColor, text: String = "", isShawdow: Bool = false) -> CALayer {
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
    
    func makeStarView(frame: CGRect, color: UIColor, text: String = "", isShawdow: Bool = false) -> UIView {
        let mRect = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        let mlayer = makeStarLayer(rect: mRect, color: color, text: text, isShawdow: isShawdow)
        let mView = UIView(frame: frame)
        mView.layer.addSublayer(mlayer)
        return mView
    }
    
    func makeStarLayer(rect: CGRect, color: UIColor, text: String = "", isShawdow: Bool = false) -> CALayer {
        let starShape = CAShapeLayer()
        starShape.path = makeStarPathRadius(width: rect.width, height: rect.height).cgPath
    
        let newLayer = CAGradientLayer()
        newLayer.frame = rect
        newLayer.colors = colorSet[Int.random(in: 0..<colorSet.count)]
        newLayer.locations = [0, 0.5, 1]
        newLayer.startPoint = CGPoint(x: 0, y: 0)
        newLayer.endPoint = CGPoint(x: 1, y: 1)
        newLayer.mask = starShape    
        return newLayer
    }
    
    func makeStarPath(width: CGFloat, height: CGFloat) -> UIBezierPath {
        let path = UIBezierPath()
        let starExtrusion: CGFloat = width / 4
        let center = CGPoint(x: width / 2.0, y: height / 2.0)
        let pointsOnStar = 5
        var angle: CGFloat = -CGFloat(Double.pi / 2.0)
        let angleIncrement = CGFloat(Double.pi * 2.0 / Double(pointsOnStar))
        let radius = width / 2.0
        var firstPoint = true

        for _ in 1...pointsOnStar {
            let point = pointFrom(angle, radius: radius, offset: center)
            let nextPoint = pointFrom(angle + angleIncrement, radius: radius, offset: center)
            let midPoint = pointFrom(angle + angleIncrement / 2.0, radius: starExtrusion, offset: center)
            if firstPoint {
                firstPoint = false
                path.move(to: point)
            }
            path.addLine(to: midPoint)
            path.addLine(to: nextPoint)
            angle += angleIncrement
        }
        path.close()

        return path
    }
    
    func makeStarPathRadius(width: CGFloat, height: CGFloat) -> UIBezierPath {
        let center = CGPoint(x: width / 2.0, y: height / 2.0)
        let radius = width / 2
        let pointsOnStar = 5
        var angle: CGFloat = -CGFloat(Double.pi / 2.0)
        let angleIncrement = CGFloat(Double.pi * 2.0 / Double(pointsOnStar))
        let pointAngle: CGFloat = CGFloat(Double.pi * 30 / 180)
        let starExtrusion: CGFloat = width / 4

        let edgeRadiusPoint = pointFrom(angle, radius: radius * 0.8, offset: center)
        let path = UIBezierPath(arcCenter: edgeRadiusPoint,
                                radius: radius * 0.2,
                                startAngle: angle - pointAngle,
                                endAngle: angle + pointAngle,
                                clockwise: true)
        for _ in 1..<pointsOnStar {
            let midPoint = pointFrom(angle + angleIncrement / 2.0, radius: starExtrusion, offset: center)
            let edgeRadiusPoint = pointFrom(angle + angleIncrement, radius: radius * 0.8, offset: center)
            path.addLine(to: midPoint)
            path.addArc(withCenter: edgeRadiusPoint, radius: radius * 0.2, startAngle: angle + angleIncrement - pointAngle, endAngle: angle + angleIncrement + pointAngle, clockwise: true)
            angle += angleIncrement
            
        }
        let midPoint = pointFrom(angle + angleIncrement / 2.0, radius: starExtrusion, offset: center)
        path.addLine(to: midPoint)
        path.close()
        
        return path

    }
    
    func pointFrom(_ angle: CGFloat, radius: CGFloat, offset: CGPoint) -> CGPoint {
        return CGPoint(x: radius * cos(angle) + offset.x,
                       y: radius * sin(angle) + offset.y)
    }
}
