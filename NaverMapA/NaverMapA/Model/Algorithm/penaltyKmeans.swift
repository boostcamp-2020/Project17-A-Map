//
//  RemainKmeans.swift
//  NaverMapA
//
//  Created by 채훈기 on 2020/11/27.
//

import Foundation

final class PenaltyKmeans: Clusterable {
    
    func execute(places: [Place], bounds: CoordinateBounds) -> [Cluster] {
        guard places.count != 0 else { return [] }
        var candidateCluster: [[PenaltyCluster]] = []
        let maximumK = determinateMaxK(count: places.count, bounds: bounds)
        
        for k in 1..<maximumK {
            let clusters = clustering(places: places, k: k)
            candidateCluster.append(clusters)
        }
        
        return bestCluster(clusters: candidateCluster, count: places.count)
    }
    
    func bestCluster(clusters: [[PenaltyCluster]], count: Int) -> [PenaltyCluster] {
        var distances = clusters.map { candidate in
            candidate.reduce(0.0, { $0 + $1.totalDistance })
        }
        let diffDistance = (0..<(distances.count) - 1).map { i -> Double in
            return distances[i] - distances[i + 1]
        }
        let decreaseAverage = diffDistance.reduce(0.0, {$0 + $1}) / Double(diffDistance.count) / 2
        var minDistance = Double.greatestFiniteMagnitude
        var minIdx = 0
        
        for i in 0..<distances.count {
            distances[i] += decreaseAverage * Double(i+1)
            if distances[i] < minDistance {
                minDistance = distances[i]
                minIdx = i
            }
        }
        
        return clusters[minIdx]
    }
    
    func clustering(places: [Place], k: Int) -> [PenaltyCluster] {
        var centroids = initialCentroid(k: k, places: places)
        let iterationCount = 3
        centroids = distributeToCentroid(places: places, centroids: centroids)

        for _ in 0..<iterationCount {
            var newCentroids = centroids.map { PenaltyCluster(lat: $0.latitude, lng: $0.longitude, places: [])}
            newCentroids = distributeToCentroid(places: places, centroids: newCentroids)
            centroids = newCentroids
        }
        return centroids
            .map { PenaltyCluster(lat: $0.latitude, lng: $0.longitude, places: $0.places)}
            .filter { $0.places.count > 0 }
    }
    
    func initialCentroid(k: Int, places: [Place]) -> [PenaltyCluster] {
        let initialRandomCentroid = (0..<k).map { _ -> Place in
            let idx = Int.random(in: 0..<places.count)
            return places[idx]
        }
        var centerOfCentroid = PenaltyCluster(places: initialRandomCentroid)
        
        for place in places {
            let newCandidateCentroid = centerOfCentroid.farthestPlaces(from: place) + [place]
            let newCenterOfCentroid = PenaltyCluster(places: newCandidateCentroid)
            if newCenterOfCentroid.sumDistanceInCentroid() > centerOfCentroid.sumDistanceInCentroid() {
                centerOfCentroid = newCenterOfCentroid
            }
        }
        
        let centroidToCluster = centerOfCentroid.places.map { PenaltyCluster(places: [$0]) }
        centroidToCluster.forEach { $0.clearPlaces() }
        
        return centroidToCluster
    }
    
    func distributeToCentroid(places: [Place], centroids: [PenaltyCluster]) -> [PenaltyCluster] {
        let distributedCentroid = centroids
        
        places.forEach { place in
            let distances = distributedCentroid
                            .map { ($0.distanceTo(place), $0) }
                            .sorted { $0.0 < $1.0 }
            distances[0].1.append(jsonPlace: place)
        }

        return distributedCentroid
    }
    
    func determinateMaxK(count: Int, bounds: CoordinateBounds) -> Int {
        guard count > 40 else { return 40 }
        let mapScale = sqrt(pow(bounds.northEastLat - bounds.southWestLat, 2) + pow(bounds.northEastLng - bounds.southWestLng, 2))
        switch mapScale {
        case let x where x > 10:
            return 1
        case let x where x > 1:
            return 2
        case let x where x > 0.1:
            return 10
        case let x where x > 0.01:
            return 20
        case let x where x > 0.001:
            return 30
        default:
            return 40
        }
    }
}
