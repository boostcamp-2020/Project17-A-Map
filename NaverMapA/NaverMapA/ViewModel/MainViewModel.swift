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
    let queue = OperationQueue()
    init(algorithm: Clusterable) {
        clusteringAlgorithm = algorithm
    }
    func updatePlaces(places: [Place], bounds: CoordinateBounds) {
        queue.cancelAllOperations()
        let clusteringAlgorithm = self.clusteringAlgorithm.copy()
        guard let cluster = clusteringAlgorithm as? Clusterable else {
            return
        }
        cluster.places = places
        cluster.bounds = bounds
        guard let operation = clusteringAlgorithm as? Operation else {
            return
        }
        queue.addOperation(operation)
        queue.addBarrierBlock {
            self.markers.value = cluster.clusters
        }
    }
    
    func updatePlacesAndAnimation(places: [Place], bounds: CoordinateBounds) {
        queue.cancelAllOperations()
        let clusteringAlgorithm = self.clusteringAlgorithm.copy()
        guard let cluster = clusteringAlgorithm as? Clusterable else {
            return
        }
        cluster.places = places
        cluster.bounds = bounds
        guard let operation = clusteringAlgorithm as? Operation else {
            return
        }
        queue.addOperation(operation)
        queue.addBarrierBlock {
            var newClusters = cluster.clusters
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
