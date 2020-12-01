//
//  ViewController+NMFMapViewCameraDelegate.swift
//  NaverMapA
//
//  Created by 박태희 on 2020/12/01.
//

import Foundation
import NMapsMap

extension MainViewController: NMFMapViewCameraDelegate {
    
    func mapViewCameraIdle(_ mapView: NMFMapView) {
        let coordBounds = mapView.projection.latlngBounds(fromViewBounds: UIScreen.main.bounds)
        DispatchQueue.global().async {
            let bounds = CoordinateBounds(southWestLng: coordBounds.southWestLng,
                                          northEastLng: coordBounds.northEastLng,
                                          southWestLat: coordBounds.southWestLat,
                                          northEastLat: coordBounds.northEastLat)
            
            let places = self.dataProvider.fetch(bounds: bounds)
            guard let viewModel = self.viewModel else { return }
            //이전 마커를 저장
            self.beforeClusterMarkers = self.clusterMarkers
            self.beforeClusters = viewModel.markers.value
            viewModel.updatePlaces(places: places, bounds: bounds)
        }
    }
}
