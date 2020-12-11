//
//  MarkerFactory.swift
//  NaverMapA
//
//  Created by 박태희 on 2020/12/03.
//

import UIKit
import NMapsMap

class MarkerFactory {
    
    func setLayout(label: UILabel, markerImageView: UIImageView) {
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.cornerRadius = 10
        label.leadingAnchor.constraint(equalTo: markerImageView.leadingAnchor, constant: 8).isActive = true
        label.trailingAnchor.constraint(equalTo: markerImageView.trailingAnchor, constant: -8).isActive = true
        label.topAnchor.constraint(equalTo: markerImageView.topAnchor, constant: 8).isActive = true
        label.bottomAnchor.constraint(equalTo: markerImageView.bottomAnchor, constant: -18).isActive = true
    }
    
    func makeCmarkerView(frame: CGRect, color: UIColor, text: String = "8") -> UIView {
        let mRect = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        let mlayer = makeCMarkerLayer(rect: mRect, color: color, text: text)
        let mView = UIView(frame: frame)
        mView.layer.addSublayer(mlayer)
        return mView
    }
    
    func makeCMarkerLayer(rect: CGRect, color: UIColor, text: String = "8") -> CALayer {
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
//        markerLayer.shadowOffset = CGSize(width: 2, height: 2)
//        markerLayer.shadowColor = UIColor.black.cgColor
//        markerLayer.shadowOpacity = 0.4

        let circleLayer = CALayer()
        circleLayer.frame = CGRect(x: centerX - radius * 0.7, y: centerY - radius * 0.7, width: radius * 1.4, height: radius * 1.4)
        circleLayer.cornerRadius = radius * 0.7
        circleLayer.backgroundColor = UIColor.white.cgColor
//        circleLayer.shadowColor = UIColor.black.cgColor
//        circleLayer.shadowOpacity = 0.4
//        circleLayer.shadowOffset = CGSize(width: 2, height: 2)
//        
        markerLayer.addSublayer(circleLayer)
        
        let tempFrame = CGRect(x: centerX - radius * 0.5, y: centerY - radius * 0.5, width: radius, height: radius)
        let textLayer = VHCTextLayer(frame: tempFrame, text: text)
        
        markerLayer.addSublayer(textLayer)
        return markerLayer
    }
}
