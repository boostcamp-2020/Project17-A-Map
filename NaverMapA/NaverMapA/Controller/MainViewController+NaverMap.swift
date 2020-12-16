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
            guard let viewModel = self.viewModel else { return }
            let coordBounds = self.naverMapView.coordBounds
            let filtedPlaces = viewModel.fetchedPlaces(with: coordBounds)
            self.naverMapView.zoomLevelCheck = mapView.zoomLevel
            if self.naverMapView.$zoomLevelCheck {
                viewModel.updatePlacesAndAnimation(places: filtedPlaces, bounds: self.naverMapView.coordBounds)
            }
        }
    }
    
    func updateMapView() {
        DispatchQueue.main.async {
            guard let viewModel = self.viewModel else { return }
            let coordBounds = self.naverMapView.coordBounds
            let filtedPlaces = viewModel.fetchedPlaces(with: coordBounds)
            viewModel.updatePlaces(places: filtedPlaces, bounds: coordBounds) {}
        }
    }
}
