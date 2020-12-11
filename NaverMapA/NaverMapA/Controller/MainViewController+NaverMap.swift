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
    
    func mapView(_ mapView: NMFMapView, cameraIsChangingByReason reason: Int) {
        guard let selected = naverMapView.selectedLeapMarker else {
            flashAnimator.isAnimating = false
            return
        }
        let coordBounds = naverMapView.coordBounds
        if (selected.position.lat < coordBounds.southWestLat || selected.position.lng < coordBounds.southWestLng) || (selected.position.lat > coordBounds.northEastLat || selected.position.lng > coordBounds.northEastLng) {
            if flashAnimator.isAnimating {
                flashAnimator.isAnimating = false
                flashAnimator.stop()
            }
        } else {
            if !flashAnimator.isAnimating {
                flashAnimator.isAnimating = true
                flashAnimator.run()
            } else {
                naverMapView.selectedAnimationLayer?.position.x = naverMapView.mapView.layer.position.x - (mapView.projection.point(from: mapView.cameraPosition.target).x - mapView.projection.point(from: naverMapView.selectedAnimationStartCameraPosition).x)
                naverMapView.selectedAnimationLayer?.position.y = naverMapView.mapView.layer.position.y - (mapView.projection.point(from: mapView.cameraPosition.target).y - mapView.projection.point(from: naverMapView.selectedAnimationStartCameraPosition).y)
            }
        }
    }
    
    func mapView(_ mapView: NMFMapView, cameraDidChangeByReason reason: Int, animated: Bool) {
        DispatchQueue.main.async {
            guard let viewModel = self.viewModel else { return }
            let coordBounds = self.naverMapView.coordBounds
            let filtedPlaces = viewModel.fetchedPlaces(with: coordBounds)
            self.zoomLevelCheck = mapView.zoomLevel
            self.naverMapView.prevZoomLevel = mapView.zoomLevel
            if self.$zoomLevelCheck {
                viewModel.updatePlacesAndAnimation(places: filtedPlaces, bounds: self.naverMapView.coordBounds) { [weak self] in
                    guard let self = self, let viewModel = self.viewModel, self.naverMapView.selectedLeapMarker != nil else { return }
                    DispatchQueue.main.async {
                        var findLeap = false
                        for cluster in viewModel.beforeMarkers {
                            if cluster.latitude == self.naverMapView.selectedLeapMarker?.position.lat && cluster.longitude == self.naverMapView.selectedLeapMarker?.position.lng {
                                findLeap = true
                                break
                            }
                        }
                        if !findLeap {
                            if self.flashAnimator.isAnimating {
                                self.flashAnimator.isAnimating = false
                                self.flashAnimator.stop()
                                self.naverMapView.selectedLeapMarker = nil
                            }
                        }
                    }
                }
            }
        }
    }
    func updateMapView() {
        DispatchQueue.main.async {
            guard let viewModel = self.viewModel else { return }
            let coordBounds = self.naverMapView.coordBounds
            let filtedPlaces = viewModel.fetchedPlaces(with: coordBounds)
            if self.naverMapView.prevZoomLevel != self.mapView.zoomLevel {
                self.naverMapView.prevZoomLevel = self.mapView.zoomLevel
                viewModel.updatePlacesAndAnimation(places: filtedPlaces, bounds: coordBounds) {
                    
                }
            } else {
                viewModel.updatePlaces(places: filtedPlaces, bounds: coordBounds)
            }
        }
    }
}
