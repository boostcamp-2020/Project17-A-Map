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
    var appearCompletionHandler: (Cluster) -> Void { get }
    var moveCompletionHandler: ([Cluster]) -> Void { get }
    func animateOneView(startPoint: CGPoint, markerColor: UIColor, cluster: Cluster)
    func animateOneView(startPoint: CGPoint, endPoint: CGPoint, markerColor: UIColor, beforeCluster: Cluster, afterClusters: [Cluster])
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
    var appearCompletionHandler: (Cluster) -> Void
    var moveCompletionHandler: ([Cluster]) -> Void
    var naverMapView: NaverMapView
    var animationCount: Int = 0
    var width = NMFMarker().iconImage.imageWidth * 1.2
    var height = NMFMarker().iconImage.imageHeight * 1.2
    var markerFactory: MarkerFactory
    @Atomic(value: 0) var count
    
    init(mapView: NaverMapView, appearCompletionHandler: @escaping (Cluster) -> Void, moveCompletionHandler: @escaping ([Cluster]) -> Void) {
        self.mapView = mapView.mapView
        self.animationLayer = mapView.animationLayer
        self.appearCompletionHandler = appearCompletionHandler
        self.moveCompletionHandler = moveCompletionHandler
        self.naverMapView = mapView
        self.markerFactory = MarkerFactory()
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
                    let markerColor = (before.count > 1) ? UIColor.systemRed : UIColor.systemGreen
                    if startPoint == endPoint {
                        appearCompletionHandler(afterCluster)
                    } else {
                        animateOneView(startPoint: startPoint, endPoint: endPoint, markerColor: markerColor, beforeCluster: beforeCluster, afterClusters: after)
                    }
                    break
                }
            }
        }
    }
    
    func animateAllAppear(after: [Cluster]) {
        for cluster in after {
            let point = mapView.projection.point(from: NMGLatLng(lat: cluster.latitude, lng: cluster.longitude))
            let markerColor = (cluster.places.count > 1) ? UIColor.systemRed : UIColor.systemGreen
            animateOneView(startPoint: point, markerColor: markerColor, cluster: cluster)
        }

    }
    
    func animateOneView(startPoint: CGPoint, markerColor: UIColor, cluster: Cluster) {
        let markerLayer = markerFactory.makeCmarkerView(frame: CGRect(x: -100, y: -100, width: width, height: height), color: .systemTeal, text: "\(cluster.places.count)")
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
                self.appearCompletionHandler(cluster)
            }
            markerLayer.layer.add(scaleUpAnimation, forKey: "transform.scale.y")
            CATransaction.commit()
        }
    }
        
    func animateOneView(startPoint: CGPoint, endPoint: CGPoint, markerColor: UIColor, beforeCluster: Cluster, afterClusters: [Cluster]) {
        let markerLayer = markerFactory.makeCmarkerView(frame: CGRect(x: -100, y: -100, width: width, height: height), color: .systemTeal, text: "\(beforeCluster.places.count)")
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
                    self.moveCompletionHandler(afterClusters)
                }
            }
            markerLayer.layer.add(markerAnimation, forKey: "position")
            CATransaction.commit()
        }
    }

}
