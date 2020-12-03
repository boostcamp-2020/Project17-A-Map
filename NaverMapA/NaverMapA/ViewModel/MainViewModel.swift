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
    var beforeMarkers: [Cluster] = []
    
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
            var newClusters = self.clusteringAlgorithm.execute(places: places, bounds: bounds)
            for index in 0..<newClusters.count {
                newClusters[index].placesDictionary.removeAll()
                newClusters[index].places.forEach { place in
                    newClusters[index].placesDictionary.updateValue(1, forKey: Point(latitude: place.latitude, longitude: place.longitude))
                }
            }
            self.animationMarkers.value = (self.beforeMarkers, newClusters)
            self.beforeMarkers = newClusters
        }
    }
}
