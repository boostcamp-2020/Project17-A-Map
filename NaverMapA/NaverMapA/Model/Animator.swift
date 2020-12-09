//
//  Animator.swift
//  NaverMapA
//
//  Created by 홍경표 on 2020/12/08.
//

import UIKit
import NMapsMap

protocol Animatorable: Operation {
    func markerAnimation()
}

final class AppearAnimator: Operation, Animatorable {
    
    var mapView: NMFMapView
    var animationLayer: CALayer
    var clusters: [Cluster]
    var handler: (Cluster) -> Void
    
    init(mapView: NMFMapView, animationLayer: CALayer, clusters: [Cluster], handler: @escaping (Cluster) -> Void) {
        self.mapView = mapView
        self.animationLayer = animationLayer
        self.clusters = clusters
        self.handler = handler
    }
    
    override func main() {
        if !isCancelled {
            markerAnimation()
        }
    }
    
    func markerAnimation() {
        for cluster in clusters where !isCancelled {
            let point = mapView.projection.point(from: NMGLatLng(lat: cluster.latitude, lng: cluster.longitude))
            let markerColor = (cluster.places.count > 1) ? UIColor.systemRed : UIColor.systemGreen
            startMarkerAnimation(point: point, markerColor: markerColor, cluster: cluster)
        }
    }

    private func startMarkerAnimation(point: CGPoint, markerColor: UIColor, cluster: Cluster) {
        let marker = NMFMarker()
        marker.iconTintColor = markerColor
        let markerView = makeMarkerView(with: marker)
        animationLayer.addSublayer(markerView.layer)
        markerView.layer.position = point
        markerView.layer.anchorPoint = CGPoint(x: 0.5, y: 1)
        DispatchQueue.global().async {
            CATransaction.begin()
            let scaleUpAnimation = CABasicAnimation(keyPath: "transform.scale")
            scaleUpAnimation.fromValue = 0
            scaleUpAnimation.toValue = 1
            scaleUpAnimation.duration = 0.4
            CATransaction.setCompletionBlock {
                markerView.layer.removeFromSuperlayer()
                self.handler(cluster)
            }
            markerView.layer.add(scaleUpAnimation, forKey: "transform.scale")
            CATransaction.commit()
        }
    }
    
    func makeMarkerView(with overlay: NMFOverlay) -> UIView {
        let markerOverlay = overlay as? NMFMarker
        let markerView = UIImageView(frame: CGRect(x: 0, y: 0, width: markerOverlay?.iconImage.imageWidth ?? 0, height: markerOverlay?.iconImage.imageHeight ?? 0))
        markerView.image = markerOverlay?.iconImage.image.withTintColor(markerOverlay?.iconTintColor ?? .green)
        return markerView
    }
    
}

final class MoveAnimator: Operation, Animatorable {
    
    var mapView: NMFMapView
    var animationLayer: CALayer
    var beforeClusters: [Cluster]
    var afterClusters: [Cluster]
    var handler: (Cluster) -> Void
    
    init(mapView: NMFMapView, animationLayer: CALayer, beforeClusters: [Cluster], afterClusters: [Cluster], handler: @escaping (Cluster) -> Void) {
        self.mapView = mapView
        self.animationLayer = animationLayer
        self.beforeClusters = beforeClusters
        self.afterClusters = afterClusters
        self.handler = handler
    }
    
    override func main() {
        if !isCancelled {
            markerAnimation()
        }
    }
    
    func markerAnimation() {
        for beforeCluster in beforeClusters where !isCancelled {
            for afterCluster in afterClusters where !isCancelled {
                for beforePlace in beforeCluster.places where !isCancelled {
                    guard afterCluster.placesDictionary[Point(latitude: beforePlace.latitude, longitude: beforePlace.longitude)] != nil else { continue }
                    let startPoint = mapView.projection.point(from: NMGLatLng(lat: beforeCluster.latitude, lng: beforeCluster.longitude))
                    let endPoint = mapView.projection.point(from: NMGLatLng(lat: afterCluster.latitude, lng: afterCluster.longitude))
                    let markerColor = (beforeClusters.count > 1) ? UIColor.systemRed : UIColor.systemGreen
                    if startPoint == endPoint {
                        handler(afterCluster)
                    } else {
                        startMarkerAnimation(startPoint: startPoint, endPoint: endPoint, markerColor: markerColor, afterCluster: afterCluster)
                    }
                    break
                }
            }
        }
    }

    private func startMarkerAnimation(startPoint: CGPoint, endPoint: CGPoint, markerColor: UIColor, afterCluster: Cluster) {
        let marker = NMFMarker()
        marker.iconTintColor = markerColor
        let markerView = self.view(with: marker)
        markerView.frame.origin = CGPoint(x: -100, y: -100) // 0,0 좌표에 마커 잔상을 없애주기 위함
        animationLayer.addSublayer(markerView.layer)
        markerView.layer.anchorPoint = CGPoint(x: 0.5, y: 1)
        DispatchQueue.global().async {
            CATransaction.begin()
            let markerAnimation = CABasicAnimation(keyPath: "position")
            markerAnimation.duration = 0.4
            markerAnimation.fromValue = CGPoint(x: startPoint.x, y: startPoint.y)
            markerAnimation.toValue = CGPoint(x: endPoint.x, y: endPoint.y)
            CATransaction.setCompletionBlock {
                markerView.layer.removeFromSuperlayer()
                self.handler(afterCluster)
            }
            markerView.layer.add(markerAnimation, forKey: "position")
            CATransaction.commit()
        }
    }
    
    func view(with overlay: NMFOverlay) -> UIView {
        let markerOverlay = overlay as? NMFMarker
        let markerView = UIImageView(frame: CGRect(x: 0, y: 0, width: markerOverlay?.iconImage.imageWidth ?? 0, height: markerOverlay?.iconImage.imageHeight ?? 0))
        markerView.image = markerOverlay?.iconImage.image.withTintColor(markerOverlay?.iconTintColor ?? .green)
        return markerView
    }
    
}
