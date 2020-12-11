//
//  MyNaverMapView.swift
//  NaverMapA
//
//  Created by 채훈기 on 2020/12/09.
//

import UIKit
import NMapsMap

protocol NaverMapViewDelegate: class {
    func naverMapView(_ mapView: NaverMapView, markerDidSelected cluster: Cluster)
    func naverMapView(_ mapView: NaverMapView, markerWillAdded latlng: NMGLatLng)
    func naverMapView(_ mapView: NaverMapView, markerWillDeleted place: Place)
}

class NaverMapView: NMFNaverMapView {
    
    let defaultPosition = NMFCameraPosition(NMGLatLng(lat: 37.5656471, lng: 126.9908467), zoom: 18)
    var animationLayer: CALayer = CALayer()
    let markerFactory = MarkerFactory()
    var clusterMarkers = [NMFMarker]()
    var clusterObjects = [Cluster]()
    var prevZoomLevel: Double = 18
    weak var naverMapDelegate: NaverMapViewDelegate?
    lazy var handler = { (overlay: NMFOverlay?) -> Bool in
        if let marker = overlay as? NMFMarker {
            for cluster in self.clusterObjects {
                if cluster.latitude == marker.position.lat && cluster.longitude == marker.position.lng {
                    self.moveCamera(to: cluster)
                    self.naverMapDelegate?.naverMapView(self, markerDidSelected: cluster)
                    break
                }
            }
        }
        return true
    }
    var coordBounds: CoordinateBounds {
        let cbounds = mapView.projection.latlngBounds(fromViewBounds: UIScreen.main.bounds)
        let bounds = CoordinateBounds(southWestLng: cbounds.southWestLng,
                                      northEastLng: cbounds.northEastLng,
                                      southWestLat: cbounds.southWestLat,
                                      northEastLat: cbounds.northEastLat)
        return bounds
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
        let w = marker.iconImage.imageWidth * 1.2
        let h = marker.iconImage.imageHeight * 1.2
        let tframe = CGRect(x: 0, y: 0, width: w, height: h)
        let text = "\(afterCluster.places.count)"
        let tview = markerFactory.makeCmarkerView(frame: tframe, color: .systemTeal, text: text, isShawdow: true)
        marker.iconImage = NMFOverlayImage(image: tview.getImage())
        marker.zIndex = 1
        marker.mapView = self.mapView
        marker.touchHandler = self.handler
        self.clusterMarkers.append(marker)
    }
    
    func configureNewMarkers(afterClusters: [Cluster]) {
        afterClusters.forEach {afterCluster in
            let lat = afterCluster.latitude
            let lng = afterCluster.longitude
            let marker = NMFMarker(position: NMGLatLng(lat: lat, lng: lng))
            marker.iconImage = NMF_MARKER_IMAGE_BLACK
            let w = marker.iconImage.imageWidth * 1.2
            let h = marker.iconImage.imageHeight * 1.2
            let tframe = CGRect(x: 0, y: 0, width: w, height: h)
            let text = "\(afterCluster.places.count)"
            let tview = markerFactory.makeCmarkerView(frame: tframe, color: .systemTeal, text: text, isShawdow: true)
            marker.iconImage = NMFOverlayImage(image: tview.getImage())
            marker.zIndex = 1
            marker.mapView = self.mapView
            marker.touchHandler = self.handler
            self.clusterMarkers.append(marker)
        }
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
        naverMapDelegate?.naverMapView(self, markerWillAdded: latlng)
    }
    
    func deleteMarker(marker: NMFMarker) {
        for cluster in clusterObjects {
            if cluster.latitude == marker.position.lat && cluster.longitude == marker.position.lng && cluster.places.count == 1 {
                naverMapDelegate?.naverMapView(self, markerWillDeleted: cluster.places[0])
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