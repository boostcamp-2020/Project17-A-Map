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
    var candidates: [[PenaltyCluster]] = []
    
    override func main() {
        candidates = []
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
        let maximumK = determinateMaxK(count: places.count)
        let clusterQueue = DispatchQueue(label: "cluster", attributes: .concurrent)
        let group = DispatchGroup()
        let semaphore = DispatchSemaphore(value: 1)
        for k in 1...maximumK where !isCancelled {
            clusterQueue.async(group: group) {
                let clusters = self.clustering(places: places, k: k)
                _ = semaphore.wait(timeout: .distantFuture)
                self.candidates.append(clusters)
                semaphore.signal()
            }
        }
        
        let result = group.wait(timeout: .distantFuture)
        
        if isCancelled || result == .timedOut {
            return []
        }
        
        return combineCluster(clusters: bestCluster(candidates: candidates), bounds: bounds)
    }
    
    private func bestCluster(candidates: [[PenaltyCluster]]) -> [PenaltyCluster] {
        guard candidates.count != 0 else { return [] }
        guard candidates.count != 1 else { return candidates[0] }
        var distances = candidates.map { candidate in
            candidate.reduce(0.0, { $0 + $1.totalDistance })
        }
        let diffDistance = (0..<(distances.count) - 1).map { i -> Double in
            return distances[i] - distances[i + 1]
        }
        let decreaseAverage = diffDistance.reduce(0.0, {$0 + $1}) / Double(diffDistance.count) / 3
        var minDistance = Double.greatestFiniteMagnitude
        var minIdx = 0
        
        for i in 0..<distances.count {
            distances[i] += decreaseAverage * Double(i+1)
            if distances[i] < minDistance {
                minDistance = distances[i]
                minIdx = i
            }
        }
        return isCancelled ? [] : candidates[minIdx]
    }
    
    func combineCluster(clusters: [PenaltyCluster], bounds: CoordinateBounds ) -> [PenaltyCluster] {
        let mapScale = sqrt(pow(bounds.northEastLat - bounds.southWestLat, 2) + pow(bounds.northEastLng - bounds.southWestLng, 2)) / 12
        var tempCluster = clusters
        var isFlag = true
        
        while isFlag {
            var first: Int?
            var second: Int?
            for i in 0..<tempCluster.count where first == nil {
                for j in (i+1)..<tempCluster.count where first == nil {
                    if tempCluster[i].distanceTo(tempCluster[j]) <= mapScale {
                        first = i
                        second = j
                        break
                    }
                }
            }
            
            if let i = first, let j = second {
                let newCluster = PenaltyCluster(places: tempCluster[i].places + tempCluster[j].places)
                tempCluster.remove(at: j)
                tempCluster.remove(at: i)
                tempCluster.append(newCluster)
            } else {
                isFlag = false
                continue
            }
        }
        
        return tempCluster
    }
    
    private func clustering(places: [Place], k: Int) -> [PenaltyCluster] {
        var centroids = initialCentroid(k: k, places: places)
        let iterationCount = 5
        centroids = distributeToCentroid(places: places, centroids: centroids)

        for _ in 0..<iterationCount where !isCancelled {
            var newCentroids = centroids.map { PenaltyCluster(lat: $0.averageLatitude, lng: $0.averageLongitude, places: [])}
            newCentroids = distributeToCentroid(places: places, centroids: newCentroids)
            centroids = newCentroids.map {
                PenaltyCluster(lat: $0.averageLatitude,
                               lng: $0.averageLongitude,
                               places: $0.places )
            }
        }
        return centroids
            .map { PenaltyCluster(lat: $0.latitude, lng: $0.longitude, places: $0.places)}
            .filter { $0.places.count > 0 }
    }
    
    private func initialCentroid(k: Int, places: [Place]) -> [PenaltyCluster] {
        let initialRandomCentroid = (0..<k).map {
            return places[$0]
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
            nearCluster?.append(place: place)
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
