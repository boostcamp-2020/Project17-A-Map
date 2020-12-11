//
//  FlashAnimator.swift
//  NaverMapA
//
//  Created by 김병인 on 2020/12/12.
//

import UIKit
import NMapsMap

class FlashAnimator {
    var queue = DispatchQueue(label: "flashAnimator")
    var isAnimating = false
    var mapView: NMFMapView
    var naverMapView: NaverMapView
    var animationCount: Int = 0
    var width = NMFMarker().iconImage.imageWidth * 1.2
    var height = NMFMarker().iconImage.imageHeight * 1.2
    var markerFactory: MarkerFactory
    var markerColor: UIColor
    
    init(mapView: NaverMapView, markerColor: UIColor) {
        self.mapView = mapView.mapView
        self.naverMapView = mapView
        self.markerFactory = MarkerFactory()
        self.markerColor = markerColor
    }
    
    func run() {
        if naverMapView.selectedAnimationLayer != nil {
            stop()
        }
        naverMapView.selectedAnimationLayer = CALayer()
        naverMapView.selectedAnimationLayer?.frame = CGRect(origin: .zero, size: naverMapView.frame.size)
        mapView.layer.addSublayer(naverMapView.selectedAnimationLayer!)
        naverMapView.selectedAnimationStartCameraPosition = mapView.cameraPosition.target
        let point = mapView.projection.point(from: NMGLatLng(lat: naverMapView.selectedLeapMarker!.position.lat, lng: naverMapView.selectedLeapMarker!.position.lng))
        flash(startPoint: point)
    }
    func flash(startPoint: CGPoint) {
        let markerLayer = markerFactory.makeCmarkerView(frame: CGRect(x: -100, y: -100, width: width, height: height), color: markerColor)
        naverMapView.selectedAnimationLayer?.addSublayer(markerLayer.layer)
        markerLayer.layer.position = startPoint
        markerLayer.layer.anchorPoint = CGPoint(x: 0.5, y: 1)
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 1
        animation.toValue = 0.1
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        animation.repeatCount = .infinity
        animation.duration = 0.75
        animation.autoreverses = true
        naverMapView.selectedAnimationLayer?.add(animation, forKey: nil)
    }
    func stop() {
        naverMapView.selectedAnimationLayer?.removeAllAnimations()
        naverMapView.selectedAnimationLayer?.removeFromSuperlayer()
        naverMapView.selectedAnimationLayer = nil
    }
}
