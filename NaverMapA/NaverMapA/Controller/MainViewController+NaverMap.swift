//
//  MainViewController+NMFOverlayImageDataSource.swift
//  NaverMapA
//
//  Created by 박태희 on 2020/11/26.
//

import Foundation
import NMapsMap

extension MainViewController: NMFOverlayImageDataSource {
    
    func view(with overlay: NMFOverlay) -> UIView {
        let markerOverlay = overlay as? NMFMarker
        let markerView = UIImageView(frame: CGRect(x: 0, y: 0, width: markerOverlay?.iconImage.imageWidth ?? 0, height: markerOverlay?.iconImage.imageHeight ?? 0))
        markerView.image = markerOverlay?.iconImage.image.withTintColor(markerOverlay?.iconTintColor ?? .green)
        return markerView
    }
}

extension MainViewController: NMFMapViewCameraDelegate {
    
    func mapView(_ mapView: NMFMapView, cameraDidChangeByReason reason: Int, animated: Bool) {
        DispatchQueue.main.async {
            let coordBounds = self.mapView.projection.latlngBounds(fromViewBounds: UIScreen.main.bounds)
            let bounds = CoordinateBounds(southWestLng: coordBounds.southWestLng,
                                          northEastLng: coordBounds.northEastLng,
                                          southWestLat: coordBounds.southWestLat,
                                          northEastLat: coordBounds.northEastLat)
//            let places = self.dataProvider.fetch(bounds: bounds)
            guard let viewModel = self.viewModel else { return }
            self.zoomLevelCheck = mapView.zoomLevel
            self.naverMapView.prevZoomLevel = mapView.zoomLevel
            if self.$zoomLevelCheck {
                //애니메이팅
                viewModel.updatePlacesAndAnimation(places: self.places, bounds: bounds)
            }
        }
    }
    
//    func mapViewCameraIdle(_ mapView: NMFMapView) {
//        //updateMapView()
//        DispatchQueue.main.async {
//            let coordBounds = self.mapView.projection.latlngBounds(fromViewBounds: UIScreen.main.bounds)
//            let bounds = CoordinateBounds(southWestLng: coordBounds.southWestLng,
//                                          northEastLng: coordBounds.northEastLng,
//                                          southWestLat: coordBounds.southWestLat,
//                                          northEastLat: coordBounds.northEastLat)
////            let places = self.dataProvider.fetch(bounds: bounds)
//            guard let viewModel = self.viewModel else { return }
//            if self.naverMapView.prevZoomLevel == mapView.zoomLevel {
//                viewModel.updatePlaces(places: self.places, bounds: bounds)
//            }
//        }
//        
//    }
    
    func updateMapView() {
        DispatchQueue.main.async {
            let coordBounds = self.mapView.projection.latlngBounds(fromViewBounds: UIScreen.main.bounds)
            let bounds = CoordinateBounds(southWestLng: coordBounds.southWestLng,
                                          northEastLng: coordBounds.northEastLng,
                                          southWestLat: coordBounds.southWestLat,
                                          northEastLat: coordBounds.northEastLat)
            guard let viewModel = self.viewModel else { return }
            if self.naverMapView.prevZoomLevel != self.mapView.zoomLevel { // 애니메이션
                self.naverMapView.prevZoomLevel = self.mapView.zoomLevel
                viewModel.updatePlacesAndAnimation(places: self.places, bounds: bounds)
            } else {
                viewModel.updatePlaces(places: self.places, bounds: bounds)
            }
        }
    }
}
