//
//  RemainKmeans.swift
//  NaverMapA
//
//  Created by 채훈기 on 2020/11/27.
//

import Foundation

final class PenaltyKmeans: Operation, Clusterable {
    
    var places: [Place] = []
    var bounds: CoordinateBounds = CoordinateBounds(southWestLng: 0, northEastLng: 0, southWestLat: 0, northEastLat: 0)
    var clusters: [Cluster] = []

    override func main() {
        if isCancelled {
            return
        }
        clusters = execute(places: places, bounds: bounds)
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = PenaltyKmeans()
        return copy
    }
    
    func execute(places: [Place], bounds: CoordinateBounds) -> [Cluster] {
        guard places.count != 0 else { return [] }
        var candidateCluster: [[PenaltyCluster]] = []
        let maximumK = determinateMaxK(count: places.count)
        for k in 1..<maximumK where !isCancelled {
            let clusters = clustering(places: places, k: k)
            candidateCluster.append(clusters)
        }
        return bestCluster(clusters: candidateCluster, count: places.count)
    }
    
    private func bestCluster(clusters: [[PenaltyCluster]], count: Int) -> [PenaltyCluster] {
        guard clusters.count != 0 else { return [] }
        var distances = clusters.map { candidate in
            candidate.reduce(0.0, { $0 + $1.totalDistance })
        }
        let diffDistance = (0..<(distances.count) - 1).map { i -> Double in
            return distances[i] - distances[i + 1]
        }
        let decreaseAverage = diffDistance.reduce(0.0, {$0 + $1}) / Double(diffDistance.count)
        var minDistance = Double.greatestFiniteMagnitude
        var minIdx = 0
        
        for i in 0..<distances.count {
            distances[i] += decreaseAverage * Double(i+1)
            if distances[i] < minDistance {
                minDistance = distances[i]
                minIdx = i
            }
        }
        return isCancelled ? [] : clusters[minIdx]
    }
    
    private func clustering(places: [Place], k: Int) -> [PenaltyCluster] {
        var centroids = initialCentroid(k: k, places: places)
        let iterationCount = 5
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
    
    private func initialCentroid(k: Int, places: [Place]) -> [PenaltyCluster] {
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
    
    private func distributeToCentroid(places: [Place], centroids: [PenaltyCluster]) -> [PenaltyCluster] {
        let distributedCentroid = centroids
        
        for place in places where !isCancelled {
            let nearCluster = distributedCentroid
                .min { $0.distanceTo(place) < $1.distanceTo(place) }
            nearCluster?.append(jsonPlace: place)
        }
        
        return distributedCentroid
    }
    
    private func determinateMaxK(count: Int) -> Int {
        let MAXOPERATION: Double = 125000
        let a: Double = 5
        let b: Double = 1
        let c: Double = MAXOPERATION / Double(count)
        let root = Int((-b + sqrt(1 + 4 * a * c)) / Double(2 * a))
        
        switch (count, root) {
        case (let x, let y) where x > y:
            return y
        case (let x, let y) where x <= y:
            return x
        case (_, let y) where y == 0:
            return 1
        default:
            return 1
        }
    }
}
