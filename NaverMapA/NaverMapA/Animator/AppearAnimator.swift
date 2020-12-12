//
//  AppearAnimator.swift
//  NaverMapA
//
//  Created by 홍경표 on 2020/12/09.
//

import UIKit
import NMapsMap

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
