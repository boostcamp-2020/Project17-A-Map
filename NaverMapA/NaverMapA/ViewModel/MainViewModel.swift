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
    var fetchedPlaces: [Place] = []
    let queue = OperationQueue()
    
    init(algorithm: Clusterable) {
        clusteringAlgorithm = algorithm
    }
    
    func fetchedPlaces(with bounds: CoordinateBounds) -> [Place] {
        return fetchedPlaces.filter {
            $0.longitude > bounds.southWestLng
            && $0.longitude < bounds.northEastLng
            && $0.latitude > bounds.southWestLat
            && $0.latitude < bounds.northEastLat
        }
    }
    
    func updatePlaces(places: [Place], bounds: CoordinateBounds, completionHandler: @escaping () -> Void) {
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
            guard !operation.isCancelled else { return }
            self.beforeMarkers = cluster.clusters
            self.markers.value = cluster.clusters
            completionHandler()
        }
    }
    
    func updatePlacesAndAnimation(places: [Place], bounds: CoordinateBounds) {
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
            guard !operation.isCancelled else { return }
            var newClusters = cluster.clusters
            for index in 0..<newClusters.count where !operation.isCancelled {
                newClusters[index].placesDictionary.removeAll()
                newClusters[index].places.forEach { place in
                    newClusters[index].placesDictionary.updateValue(1, forKey: Point(latitude: place.latitude, longitude: place.longitude))
                }
            }
            guard !operation.isCancelled else { return }
            self.animationMarkers.value = (self.beforeMarkers, newClusters)
            self.beforeMarkers = newClusters
        }
    }
}
