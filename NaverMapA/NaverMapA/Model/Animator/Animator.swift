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
    var completionHandler: (Cluster) -> Void { get }
    func animatingView(with overlay: NMFOverlay) -> UIView
    func animateOneView(startPoint: CGPoint, markerColor: UIColor, cluster: Cluster)
    func animateOneView(startPoint: CGPoint, endPoint: CGPoint, markerColor: UIColor, afterCluster: Cluster)
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
    var completionHandler: (Cluster) -> Void
    @Atomic(value: 0) var count
    
    init(mapView: NaverMapView, completionHandler: @escaping (Cluster) -> Void) {
        self.mapView = mapView.mapView
        self.animationLayer = mapView.animationLayer
        self.completionHandler = completionHandler
    }
    
    func animate(before: [Cluster], after: [Cluster], type: AnimationType) {
        guard count == 0 else { return }
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
                        completionHandler(afterCluster)
                    } else {
                        animateOneView(startPoint: startPoint, endPoint: endPoint, markerColor: markerColor, afterCluster: afterCluster)
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
    
    func animatingView(with overlay: NMFOverlay) -> UIView {
        let markerOverlay = overlay as? NMFMarker
        let markerView = UIImageView(frame: CGRect(x: 0, y: 0, width: markerOverlay?.iconImage.imageWidth ?? 0, height: markerOverlay?.iconImage.imageHeight ?? 0))
        markerView.image = markerOverlay?.iconImage.image.withTintColor(markerOverlay?.iconTintColor ?? .green)
        return markerView
    }
    
    func animateOneView(startPoint: CGPoint, markerColor: UIColor, cluster: Cluster) {
        let marker = NMFMarker()
        marker.iconTintColor = markerColor
        let markerView = animatingView(with: marker)
        animationLayer.addSublayer(markerView.layer)
        markerView.layer.position = startPoint
        markerView.layer.anchorPoint = CGPoint(x: 0.5, y: 1)
        count += 1
        queue.async {
            CATransaction.begin()
            let scaleUpAnimation = CABasicAnimation(keyPath: "transform.scale")
            scaleUpAnimation.fromValue = 0
            scaleUpAnimation.toValue = 1
            scaleUpAnimation.duration = 0.4
            CATransaction.setCompletionBlock {
                self.count -= 1
                markerView.layer.removeFromSuperlayer()
                self.completionHandler(cluster)
            }
            markerView.layer.add(scaleUpAnimation, forKey: "transform.scale")
            CATransaction.commit()
        }
    }
        
    func animateOneView(startPoint: CGPoint, endPoint: CGPoint, markerColor: UIColor, afterCluster: Cluster) {
        let marker = NMFMarker()
        marker.iconTintColor = markerColor
        let markerView = animatingView(with: marker)
        markerView.frame.origin = CGPoint(x: -100, y: -100)
        animationLayer.addSublayer(markerView.layer)
        markerView.layer.anchorPoint = CGPoint(x: 0.5, y: 1)
        count += 1
        queue.async {
            CATransaction.begin()
            let markerAnimation = CABasicAnimation(keyPath: "position")
            markerAnimation.duration = 0.4
            markerAnimation.fromValue = CGPoint(x: startPoint.x, y: startPoint.y)
            markerAnimation.toValue = CGPoint(x: endPoint.x, y: endPoint.y)
            CATransaction.setCompletionBlock {
                self.count -= 1
                markerView.layer.removeFromSuperlayer()
                self.completionHandler(afterCluster)
            }
            markerView.layer.add(markerAnimation, forKey: "position")
            CATransaction.commit()
        }
    }

}
