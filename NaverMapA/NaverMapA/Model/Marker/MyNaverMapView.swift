//
//  MyNaverMapView.swift
//  NaverMapA
//
//  Created by 채훈기 on 2020/12/09.
//

import UIKit
import NMapsMap

protocol MyNaverMapViewDelegate: class {
    func myNaverMapView(_ mapView: MyNaverMapView, markerDidSelected cluster: Cluster)
    func myNaverMapView(_ mapView: MyNaverMapView, markerWillAdded latlng: NMGLatLng)
    func myNaverMapView(_ mapView: MyNaverMapView, markerWillDeleted place: Place)
}

class MyNaverMapView: NMFNaverMapView {
    
    let defaultPosition = NMFCameraPosition(NMGLatLng(lat: 37.5656471, lng: 126.9908467), zoom: 18)
    var animationLayer: CALayer = CALayer()
    let markerFactory = MarkerFactory()
    var clusterMarkers = [NMFMarker]()
    var clusterObjects = [Cluster]()
    var prevZoomLevel: Double = 18
    weak var myMapdelegate: MyNaverMapViewDelegate?
    
    lazy var handler = { (overlay: NMFOverlay?) -> Bool in
        if let marker = overlay as? NMFMarker {
            for cluster in self.clusterObjects {
                if cluster.latitude == marker.position.lat && cluster.longitude == marker.position.lng {
                    self.moveCamera(to: cluster)
                    self.myMapdelegate?.myNaverMapView(self, markerDidSelected: cluster)
                    break
                }
            }
        }
        return true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commomInit(position: defaultPosition)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commomInit(position: defaultPosition)
    }
    
    convenience init(frame: CGRect, position: NMFCameraPosition) {
        self.init(frame: frame)
        commomInit(position: position)
    }
    
    func commomInit(position: NMFCameraPosition) {
        self.showZoomControls = true
        self.showCompass = false
        self.showLocationButton = false
        self.showScaleBar = false
        self.showIndoorLevelPicker = true
        self.mapView.moveCamera(NMFCameraUpdate(position: position))
        animationLayer.frame = CGRect(origin: .zero, size: frame.size)
        mapView.layer.addSublayer(animationLayer)
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressed))
        mapView.addGestureRecognizer(longPressGesture)
    }
    
    func moveCamera(to cluster: Cluster) {
        var minLatitude = Double.greatestFiniteMagnitude
        var maxLatitude = Double.leastNormalMagnitude
        var minLongitude = Double.greatestFiniteMagnitude
        var maxLongitude = Double.leastNormalMagnitude
        for place in cluster.places {
            if minLatitude > place.latitude {
                minLatitude = place.latitude
            }
            if maxLatitude < place.latitude {
                maxLatitude = place.latitude
            }
            if minLongitude > place.longitude {
                minLongitude = place.longitude
            }
            if maxLongitude < place.longitude {
                maxLongitude = place.longitude
            }
        }
        let camUpdate = NMFCameraUpdate(fit: NMGLatLngBounds(southWest: NMGLatLng(lat: minLatitude, lng: maxLongitude), northEast: NMGLatLng(lat: maxLatitude, lng: minLongitude)), padding: 50)
        camUpdate.animation = .fly
        camUpdate.animationDuration = 1
        mapView.moveCamera(camUpdate)
    }
    
    func configureNewMarker(afterCluster: Cluster) {
        let lat = afterCluster.latitude
        let lng = afterCluster.longitude
        let marker = NMFMarker(position: NMGLatLng(lat: lat, lng: lng))
        marker.iconImage = NMF_MARKER_IMAGE_BLACK
        if afterCluster.places.count == 1 {
            marker.iconTintColor = .systemGreen
        } else {
            marker.iconTintColor = .systemRed
        }
        marker.iconImage = markerFactory.makeMarker(markerOverlay: marker, mapView: mapView, placeCount: afterCluster.places.count)
        marker.zIndex = 1
        marker.mapView = self.mapView
        marker.touchHandler = self.handler
        self.clusterMarkers.append(marker)
    }
    
    @objc private func longPressed(sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizer.State.began {
            let currentPoint: CGPoint = sender.location(in: mapView)
            let latlng = mapView.projection.latlng(from: currentPoint)
            guard let marker = mapView.pick(currentPoint) as? NMFMarker else {
                addMarker(latlng: latlng)
                return
            }
            deleteMarker(marker: marker)
        }
    }
    
    func addMarker(latlng: NMGLatLng) {
        myMapdelegate?.myNaverMapView(self, markerWillAdded: latlng)
    }
    
    func deleteMarker(marker: NMFMarker) {
        for cluster in clusterObjects {
            if cluster.latitude == marker.position.lat && cluster.longitude == marker.position.lng && cluster.places.count == 1 {
                myMapdelegate?.myNaverMapView(self, markerWillDeleted: cluster.places[0])
                break
            }
        }
    }
    
    func deleteBeforeMarkers() {
        for clusterMarker in clusterMarkers {
            clusterMarker.mapView = nil
        }
        clusterMarkers.removeAll()
        clusterObjects.removeAll()
    }
    
}
