//
//  Animator.swift
//  NaverMapA
//
//  Created by 채훈기 on 2020/12/10.
//

import UIKit
import NMapsMap

class BasicAnimator: AnimatorManagable {
    
    var queue = DispatchQueue(label: "animator", attributes: .concurrent)
    var group = DispatchGroup()
    var isAnimating = false
    var mapView: NMFMapView
    var animationLayer: CALayer
    var markerFactory: MarkerFactory
    let markerInfo: MarkerInfo
    weak var delegate: AnimatorDelegate?
    let animationMaker: AnimationMaker

    init(mapView: NaverMapView,
         markerInfo: MarkerInfo,
         animationMaker: AnimationMaker) {
        self.mapView = mapView.mapView
        self.animationLayer = mapView.animationLayer
        self.markerFactory = MarkerFactory()
        self.markerInfo = markerInfo
        self.animationMaker = animationMaker
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
                        delegate?.animator(self, didAppeared: afterCluster, color: markerInfo.color)
                    } else {
                        movingAnimation(startPoint: startPoint, endPoint: endPoint, beforeCluster: beforeCluster, afterClusters: after)
                    }
                    break
                }
            }
        }
        group.notify(queue: .main) {
            if self.isAnimating {
                self.isAnimating = false
                self.delegate?.animator(self, didMoved: after, color: self.markerInfo.color)
            }
        }
    }
    
    func animateAllAppear(after: [Cluster]) {
        for cluster in after {
            let point = mapView.projection.point(from: NMGLatLng(lat: cluster.latitude, lng: cluster.longitude))
            appearAnimation(startPoint: point, cluster: cluster)
        }
    }
    
    func appearAnimation(startPoint: CGPoint, cluster: Cluster) {
        let lframe = CGRect(x: -100, y: -100, width: markerInfo.width, height: markerInfo.height)
        let markerView = markerFactory.basicMarkerView(frame: lframe, color: markerInfo.color, text: "\(cluster.places.count)")
        let markerLayer = markerView.layer
        let animation = self.animationMaker.scaleY()

        animationLayer.addSublayer(markerLayer)
        markerLayer.position = startPoint
        markerLayer.anchorPoint = CGPoint(x: 0.5, y: 1)
        
        queue.async {
            CATransaction.begin()
            CATransaction.setCompletionBlock {

                markerLayer.removeFromSuperlayer()
                self.delegate?.animator(self, didAppeared: cluster, color: self.markerInfo.color)
            }
            markerLayer.add(animation, forKey: nil)
            CATransaction.commit()
        }
    }
        
    func movingAnimation(startPoint: CGPoint, endPoint: CGPoint, beforeCluster: Cluster, afterClusters: [Cluster]) {
        let lframe = CGRect(x: -100, y: -100, width: markerInfo.width, height: markerInfo.height)
        let markerView = markerFactory.basicMarkerView(frame: lframe, color: markerInfo.color, text: "\(beforeCluster.places.count)")
        let markerLayer = markerView.layer
        let animation = animationMaker.position(start: startPoint, end: endPoint)
        
        animationLayer.addSublayer(markerLayer)
        markerLayer.anchorPoint = CGPoint(x: 0.5, y: 1)
        isAnimating = true
        self.group.enter()
        queue.async {
            CATransaction.begin()
            CATransaction.setCompletionBlock {
                self.group.leave()
                markerLayer.removeFromSuperlayer()
            }
            markerLayer.add(animation, forKey: nil)
            CATransaction.commit()

        }
    }
}
