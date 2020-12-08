//
//  MainViewController+Animation.swift
//  NaverMapA
//
//  Created by 박태희 on 2020/12/02.
//

import UIKit
import NMapsMap

extension MainViewController {
    func markerAnimation(beforeClusters: [Cluster], afterClusters: [Cluster]) {
        beforeClusters.forEach { beforeCluster in
            afterClusters.forEach { afterCluster in
                for beforePlace in beforeCluster.places {
                    if afterCluster.placesDictionary[Point(latitude: beforePlace.latitude, longitude: beforePlace.longitude)] == nil {
                        continue
                    }
                    let startPoint = mapView.projection.point(from: NMGLatLng(lat: beforeCluster.latitude, lng: beforeCluster.longitude))
                    let endPoint = mapView.projection.point(from: NMGLatLng(lat: afterCluster.latitude, lng: afterCluster.longitude))
                    let markerColor = (beforeClusters.count > 1) ? UIColor.red : UIColor.green
                    startMarkerAnimation(startPoint: startPoint, endPoint: endPoint, markerColor: markerColor, afterCluster: afterCluster)
                    break
                }
            }
        }
    }
    
    private func startMarkerAnimation(startPoint: CGPoint, endPoint: CGPoint, markerColor: UIColor, afterCluster: Cluster) {
        if startPoint == endPoint { // 같은 위치이면 애니메이션 x
            self.configureNewMarker(afterCluster: afterCluster)
            return
        }
        let marker = NMFMarker()
        marker.iconTintColor = markerColor
        let markerView = self.view(with: marker)
        markerView.frame.origin = CGPoint(x: -100, y: -100) // 0,0 좌표에 마커 잔상을 없애주기 위함
        view.layer.addSublayer(markerView.layer)
        markerView.layer.anchorPoint = CGPoint(x: 0.5, y: 1)
        DispatchQueue.global().async {
            CATransaction.begin()
            let markerAnimation = CABasicAnimation(keyPath: "position")
            markerAnimation.duration = 0.4
            markerAnimation.fromValue = CGPoint(x: startPoint.x, y: startPoint.y)
            markerAnimation.toValue = CGPoint(x: endPoint.x, y: endPoint.y)
            CATransaction.setCompletionBlock({
                markerView.layer.removeFromSuperlayer()
                self.configureNewMarker(afterCluster: afterCluster)
            })
            markerView.layer.add(markerAnimation, forKey: "position")
            CATransaction.commit()
        }
    }
    
    func markerAppearAnimation(clusters: [Cluster]) {
        clusters.forEach { cluster in
            let point = mapView.projection.point(from: NMGLatLng(lat: cluster.latitude, lng: cluster.longitude))
            let markerColor = (cluster.places.count > 1) ? UIColor.red : UIColor.green
            startMarkerAppearAnimation(point: point, markerColor: markerColor, cluster: cluster)
        }
    }
    
    private func startMarkerAppearAnimation(point: CGPoint, markerColor: UIColor, cluster: Cluster) {
        let marker = NMFMarker()
        marker.iconTintColor = markerColor
        let markerView = self.view(with: marker)
        view.layer.addSublayer(markerView.layer)
        markerView.layer.position = point
        markerView.layer.anchorPoint = CGPoint(x: 0.5, y: 1)
        DispatchQueue.global().async {
            CATransaction.begin()
            let scaleUpAnimation = CABasicAnimation(keyPath: "transform.scale")
            scaleUpAnimation.fromValue = 0
            scaleUpAnimation.toValue = 1
            scaleUpAnimation.duration = 0.5
            CATransaction.setCompletionBlock({
                markerView.layer.removeFromSuperlayer()
                self.configureNewMarker(afterCluster: cluster)
            })
            markerView.layer.add(scaleUpAnimation, forKey: "transform.scale")
            CATransaction.commit()
        }
    }
}
