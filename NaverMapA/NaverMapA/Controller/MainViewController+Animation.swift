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
                    startMarkerAnimation(startPoint: startPoint, endPoint: endPoint, markerColor: markerColor, afterClusters: afterClusters)
                    break
                }
            }
        }
    }
    
    private func startMarkerAnimation(startPoint: CGPoint, endPoint: CGPoint, markerColor: UIColor, afterClusters: [Cluster]) {
        let marker = NMFMarker()
        marker.iconTintColor = markerColor
        let markerView = self.view(with: marker)
        markerView.frame.origin = CGPoint(x: -100, y: -100)
        mapView.addSubview(markerView)
        let markerViewLayer = markerView.layer
        markerViewLayer.anchorPoint = CGPoint(x: 0.5, y: 1)
        DispatchQueue.global().async {
            CATransaction.begin()
            let markerAnimation = CABasicAnimation(keyPath: "position")
            markerAnimation.duration = 0.4
            markerAnimation.fromValue = CGPoint(x: startPoint.x, y: startPoint.y)
            markerAnimation.toValue = CGPoint(x: endPoint.x, y: endPoint.y)
            CATransaction.setCompletionBlock({
                markerView.removeFromSuperview()
                self.configureNewMarkers(afterClusters: afterClusters)
            })
            markerViewLayer.add(markerAnimation, forKey: "position")
            CATransaction.commit()
        }
    }
}
