//
//  MainViewModel.swift
//  NaverMapA
//
//  Created by 채훈기 on 2020/11/26.
//

import Foundation

class MainViewModel {
    
    var markers: Dynamic<[Cluster]> = Dynamic([])
    var animationMarkers: Dynamic<([Cluster], [Cluster])> = Dynamic(([], []))
    var clusteringAlgorithm: Clusterable
    
    init(algorithm: Clusterable) {
        clusteringAlgorithm = algorithm
    }
    
    func updatePlaces(places: [Place], bounds: CoordinateBounds) {
        DispatchQueue.global().async {
            self.markers.value = self.clusteringAlgorithm.execute(places: places, bounds: bounds)
        }
    }
    
    func updatePlacesAndAnimation(places: [Place], bounds: CoordinateBounds) {
        DispatchQueue.global().async {
            var temp = self.clusteringAlgorithm.execute(places: places, bounds: bounds)
            for index in 0..<temp.count {
                temp[index].placesDictionary.removeAll()
                temp[index].places.forEach { place in
                    temp[index].placesDictionary.updateValue(1, forKey: Point(latitude: place.latitude, longitude: place.longitude))
                }
            }
            self.animationMarkers.value = (self.markers.value, temp)
        }
    }
}
