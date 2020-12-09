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
    
    func mapView(_ mapView: NMFMapView, cameraWillChangeByReason reason: Int, animated: Bool) {
        animationLayer.sublayers?.forEach {
            $0.removeFromSuperlayer()
        }
        viewModel?.queue.cancelAllOperations()
        viewModel?.animationQueue.cancelAllOperations()
    }
    
    func mapViewCameraIdle(_ mapView: NMFMapView) {
        updateMapView()
    }
    
    func updateMapView() {
        DispatchQueue.main.async {
            let coordBounds = self.mapView.projection.latlngBounds(fromViewBounds: UIScreen.main.bounds)
            let bounds = CoordinateBounds(southWestLng: coordBounds.southWestLng,
                                          northEastLng: coordBounds.northEastLng,
                                          southWestLat: coordBounds.southWestLat,
                                          northEastLat: coordBounds.northEastLat)
            let places = self.dataProvider.fetch(bounds: bounds)
            guard let viewModel = self.viewModel else { return }
            if self.prevZoomLevel != self.mapView.zoomLevel { // 애니메이션
                self.prevZoomLevel = self.mapView.zoomLevel
                viewModel.updatePlacesAndAnimation(places: places, bounds: bounds)
            } else {
                viewModel.updatePlaces(places: places, bounds: bounds)
            }
        }
    }
}
