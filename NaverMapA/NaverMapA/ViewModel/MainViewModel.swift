//
//  MainViewModel.swift
//  NaverMapA
//
//  Created by 채훈기 on 2020/11/26.
//

import Foundation

class MainViewModel {
    
    var markers: Dynamic<[Cluster]> = Dynamic([])
    var clusteringAlgorithm: Clusterable
    
    init(algorithm: Clusterable) {
        clusteringAlgorithm = algorithm
    }
    
    func updatePlaces(places: [Place], bounds: CoordinateBounds) {
        DispatchQueue.global().async {
            self.markers.value = self.clusteringAlgorithm.execute(places: places, bounds: bounds)
        }
    }
}
