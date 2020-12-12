//
//  Animator.swift
//  NaverMapA
//
//  Created by 채훈기 on 2020/12/10.
//

import UIKit
import NMapsMap

enum AnimationType {
    case move
    case appear
}

protocol Animator {
    var queue: DispatchQueue { get }
    var group: DispatchGroup { get }
    var isAnimating: Bool { get }
    var mapView: NMFMapView { get }
    var animationLayer: CALayer { get }
    var appearCompletionHandler: (Cluster, UIColor) -> Void { get }
    var moveCompletionHandler: ([Cluster], UIColor) -> Void { get }
    func animateOneView(startPoint: CGPoint, cluster: Cluster)
    func animateOneView(startPoint: CGPoint, endPoint: CGPoint, beforeCluster: Cluster, afterClusters: [Cluster])
    func animateAllMove(before: [Cluster], after: [Cluster])
    func animateAllAppear(after: [Cluster])
    func animate(before: [Cluster], after: [Cluster], type: AnimationType)
}

class MoveAnimator1: Animator {

    var queue = DispatchQueue(label: "animator", attributes: .concurrent)
    var group = DispatchGroup()
    var isAnimating = false
    var mapView: NMFMapView
    var animationLayer: CALayer
    var appearCompletionHandler: (Cluster, UIColor) -> Void
    var moveCompletionHandler: ([Cluster], UIColor) -> Void
    var naverMapView: NaverMapView
    var animationCount: Int = 0
    var width = NMFMarker().iconImage.imageWidth * 1.4
    var height = NMFMarker().iconImage.imageHeight * 1.4
    var markerFactory: MarkerFactory
    var markerColor: UIColor
    @Atomic(value: 0) var count
    
    init(mapView: NaverMapView, markerColor: UIColor, appearCompletionHandler: @escaping (Cluster, UIColor) -> Void, moveCompletionHandler: @escaping ([Cluster], UIColor) -> Void) {
        self.mapView = mapView.mapView
        self.animationLayer = mapView.animationLayer
        self.appearCompletionHandler = appearCompletionHandler
        self.moveCompletionHandler = moveCompletionHandler
        self.naverMapView = mapView
        self.markerFactory = MarkerFactory()
        self.markerColor = markerColor
    }
    
    func animate(before: [Cluster], after: [Cluster], type: AnimationType) {
        switch type {
        case .move:
            animateAllMove(before: before, after: after)
        case .appear:
            animateAllAppear(after: after)
        }
    }
    
    func animateAllMove(before: [Cluster], after: [Cluster]) {
        for beforeCluster in before {
            for afterCluster in after {
                for beforePlace in beforeCluster.places {
                    guard afterCluster.placesDictionary[Point(latitude: beforePlace.latitude, longitude: beforePlace.longitude)] != nil else { continue }
                    let startPoint = mapView.projection.point(from: NMGLatLng(lat: beforeCluster.latitude, lng: beforeCluster.longitude))
                    let endPoint = mapView.projection.point(from: NMGLatLng(lat: afterCluster.latitude, lng: afterCluster.longitude))
                    if startPoint == endPoint {
                        appearCompletionHandler(afterCluster, markerColor)
                    } else {
                        animateOneView(startPoint: startPoint, endPoint: endPoint, beforeCluster: beforeCluster, afterClusters: after)
                    }
                    break
                }
            }
        }
    }
    
    func animateAllAppear(after: [Cluster]) {
        for cluster in after {
            let point = mapView.projection.point(from: NMGLatLng(lat: cluster.latitude, lng: cluster.longitude))
            animateOneView(startPoint: point, cluster: cluster)
        }

    }
    
    func animateOneView(startPoint: CGPoint, cluster: Cluster) {
        let markerLayer = markerFactory.makeCmarkerView(frame: CGRect(x: -100, y: -100, width: width, height: height), color: markerColor, text: "\(cluster.places.count)")
        animationLayer.addSublayer(markerLayer.layer)
        markerLayer.layer.position = startPoint
        markerLayer.layer.anchorPoint = CGPoint(x: 0.5, y: 1)
        count += 1
        queue.async {
            CATransaction.begin()
            let scaleUpAnimation = CABasicAnimation(keyPath: "transform.scale.y")
            scaleUpAnimation.fromValue = 0
            scaleUpAnimation.toValue = 1
            scaleUpAnimation.duration = 0.4
            CATransaction.setCompletionBlock {
                self.count -= 1
                markerLayer.layer.removeFromSuperlayer()
                self.appearCompletionHandler(cluster, self.markerColor)
            }
            markerLayer.layer.add(scaleUpAnimation, forKey: "transform.scale.y")
            CATransaction.commit()
        }
    }
        
    func animateOneView(startPoint: CGPoint, endPoint: CGPoint, beforeCluster: Cluster, afterClusters: [Cluster]) {
        let markerLayer = markerFactory.makeCmarkerView(frame: CGRect(x: -100, y: -100, width: width, height: height), color: markerColor, text: "\(beforeCluster.places.count)")
        animationLayer.addSublayer(markerLayer.layer)
        markerLayer.layer.anchorPoint = CGPoint(x: 0.5, y: 1)
        isAnimating = true
        count += 1
        queue.async {
            CATransaction.begin()
            let markerAnimation = CABasicAnimation(keyPath: "position")
            markerAnimation.duration = 0.4
            markerAnimation.fromValue = CGPoint(x: startPoint.x, y: startPoint.y)
            markerAnimation.toValue = CGPoint(x: endPoint.x, y: endPoint.y)
            CATransaction.setCompletionBlock {
                self.count -= 1
                markerLayer.layer.removeFromSuperlayer()
                if self.count == 0 && self.isAnimating {
                    self.isAnimating = false
                    self.moveCompletionHandler(afterClusters, self.markerColor)
                }
            }
            markerLayer.layer.add(markerAnimation, forKey: "position")
            CATransaction.commit()
        }
    }

}
