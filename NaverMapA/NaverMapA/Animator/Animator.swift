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

protocol AnimatorManager {
    var queue: DispatchQueue { get }
    var group: DispatchGroup { get }
    var isAnimating: Bool { get set }
    var mapView: NMFMapView { get }
    var animationLayer: CALayer { get }
    func appearAnimation(startPoint: CGPoint, cluster: Cluster)
    func movingAnimation(startPoint: CGPoint, endPoint: CGPoint, beforeCluster: Cluster, afterClusters: [Cluster])
    func animateAllMove(before: [Cluster], after: [Cluster])
    func animateAllAppear(after: [Cluster])
    func animate(before: [Cluster], after: [Cluster], type: AnimationType)
}

protocol AnimatorDelegate: class {
    func animator(_ animator: AnimatorManager, didAppeared cluster: Cluster, color: UIColor)
    func animator(_ animator: AnimatorManager, didMoved clusters: [Cluster], color: UIColor)
}

class BasicAnimator: AnimatorManager {
    
    var queue = DispatchQueue(label: "animator", attributes: .concurrent)
    var group = DispatchGroup()
    var isAnimating = false
    var mapView: NMFMapView
    var animationLayer: CALayer
    var animationCount: Int = 0
    var markerWidth = NMFMarker().iconImage.imageWidth * 1.4
    var markerHeight = NMFMarker().iconImage.imageHeight * 1.4
    var markerFactory: MarkerFactory
    var markerColor: UIColor
    weak var delegate: AnimatorDelegate?
    let animationMaker: AnimationMaker
    @Atomic(value: 0) var count
    
    init(mapView: NaverMapView,
         markerColor: UIColor,
         animationMaker: AnimationMaker) {
        self.mapView = mapView.mapView
        self.animationLayer = mapView.animationLayer
        self.markerFactory = MarkerFactory()
        self.markerColor = markerColor
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
                        delegate?.animator(self, didAppeared: afterCluster, color: markerColor)
                    } else {
                        movingAnimation(startPoint: startPoint, endPoint: endPoint, beforeCluster: beforeCluster, afterClusters: after)
                    }
                    break
                }
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
        let lframe = CGRect(x: -100, y: -100, width: markerWidth, height: markerHeight)
        let markerView = markerFactory.basicMarkerView(frame: lframe, color: markerColor, text: "\(cluster.places.count)")
        let markerLayer = markerView.layer
        let animation = self.animationMaker.scaleY()

        animationLayer.addSublayer(markerLayer)
        markerLayer.position = startPoint
        markerLayer.anchorPoint = CGPoint(x: 0.5, y: 1)
        count += 1
        
        queue.async {
            CATransaction.begin()
            CATransaction.setCompletionBlock {
                self.count -= 1
                markerLayer.removeFromSuperlayer()
                self.delegate?.animator(self, didAppeared: cluster, color: self.markerColor)
            }
            markerLayer.add(animation, forKey: nil)
            CATransaction.commit()
        }
    }
        
    func movingAnimation(startPoint: CGPoint, endPoint: CGPoint, beforeCluster: Cluster, afterClusters: [Cluster]) {
        let lframe = CGRect(x: -100, y: -100, width: markerWidth, height: markerHeight)
        let markerView = markerFactory.basicMarkerView(frame: lframe, color: markerColor, text: "\(beforeCluster.places.count)")
        let markerLayer = markerView.layer
        let animation = animationMaker.position(start: startPoint, end: endPoint)
        
        animationLayer.addSublayer(markerLayer)
        markerLayer.anchorPoint = CGPoint(x: 0.5, y: 1)
        isAnimating = true
        count += 1
        
        queue.async {
            CATransaction.begin()
            CATransaction.setCompletionBlock {
                self.count -= 1
                markerLayer.removeFromSuperlayer()
                if self.count == 0 && self.isAnimating {
                    self.isAnimating = false
                    self.delegate?.animator(self, didMoved: afterClusters, color: self.markerColor)
                }
            }
            markerLayer.add(animation, forKey: nil)
            CATransaction.commit()
        }
    }
}
