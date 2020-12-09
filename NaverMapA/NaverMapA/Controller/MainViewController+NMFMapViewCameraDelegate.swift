//
//  ViewController+NMFMapViewCameraDelegate.swift
//  NaverMapA
//
//  Created by 박태희 on 2020/12/01.
//

import Foundation
import NMapsMap

extension MainViewController: NMFMapViewCameraDelegate {
    
    func mapView(_ mapView: NMFMapView, cameraWillChangeByReason reason: Int, animated: Bool) {
        animationLayer?.sublayers?.forEach {
            $0.removeFromSuperlayer()
        }
        viewModel?.queue.cancelAllOperations()
        viewModel?.animationQueue.cancelAllOperations()
    }
    
    func mapViewCameraIdle(_ mapView: NMFMapView) {
        let coordBounds = mapView.projection.latlngBounds(fromViewBounds: UIScreen.main.bounds)
        let bounds = CoordinateBounds(southWestLng: coordBounds.southWestLng,
                                      northEastLng: coordBounds.northEastLng,
                                      southWestLat: coordBounds.southWestLat,
                                      northEastLat: coordBounds.northEastLat)
        let places = self.dataProvider.fetch(bounds: bounds)
        guard let viewModel = self.viewModel else { return }
        if self.prevZoomLevel != mapView.zoomLevel { // 애니메이션
            self.prevZoomLevel = mapView.zoomLevel
            viewModel.updatePlacesAndAnimation(places: places, bounds: bounds)
        } else {
            viewModel.updatePlaces(places: places, bounds: bounds)
        }
    }
    
}
