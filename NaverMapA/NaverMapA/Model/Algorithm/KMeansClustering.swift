//
//  KMeansClustering.swift
//  NaverMapA
//
//  Created by 홍경표 on 2020/11/27.
//

import Foundation

final class KMeansClustering: Operation, Clusterable {
    var places: [Place] = []
    
    var bounds: CoordinateBounds = CoordinateBounds(southWestLng: 0, northEastLng: 0, southWestLat: 0, northEastLat: 0)
    
    var clusters: [Cluster] = []
    
    func run() {
        clusters = execute(places: places, bounds: bounds)
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = KMeansClustering()
        return copy
    }
    
    override func main() {
        if isCancelled {
            return
        }
        run()
    }
    func execute(places: [Place], bounds: CoordinateBounds) -> [Cluster] {
        if isCancelled {
            return []
        }
        let EXECUTE_TIMES = 3
        var centroids: [BasicCluster] = []
        let ks = (0..<5).map { _ in elbow(of: places.shuffled()) }
        let bestK = ks.max()
        let k = bestK ?? ks[0]
        var minTotalDistance = Double.greatestFiniteMagnitude
        (0..<EXECUTE_TIMES).forEach { _ in
            if isCancelled {
                return
            }
            let temp = clustering(k: k, places: places.shuffled())
            let totalDistance = temp.reduce(0.0, {$0 + $1.totalDistance})
            if totalDistance < minTotalDistance {
                minTotalDistance = totalDistance
                centroids = temp
            }
        }
        if isCancelled {
            return []
        }
        return centroids
    }
    
    private func optimalCentroids(k: Int, places: [Place]) -> [BasicCluster] {
        if isCancelled {
            return []
        }
        let K_COUNT = k
        var centroids = [BasicCluster](repeating: BasicCluster(), count: K_COUNT)
        var optimals = BasicCluster()
        (0..<K_COUNT).forEach { optimals.places.append(places[$0]) }
        for i in (0..<places.count) {
            if isCancelled {
                return []
            }
            var minDistance = Double.greatestFiniteMagnitude
            var indexOfNearest = 0
            for j in (0..<optimals.places.count) {
                if isCancelled {
                    return []
                }
                let distance = places[i].distanceTo(optimals.places[j])
                if distance < minDistance {
                    minDistance = distance
                    indexOfNearest = j
                }
            }
            var newOptimals = optimals
            newOptimals.remove(newOptimals.places[indexOfNearest])
            newOptimals.places.append(places[i])
            if newOptimals.totalDistance > optimals.totalDistance {
                optimals = newOptimals
            }
        }
        (0..<K_COUNT).forEach {
            centroids[$0].places.append(optimals.places[$0])
        }
        if isCancelled {
            return []
        }
        return centroids
    }
    private func clustering(k: Int, places: [Place]) -> [BasicCluster] {
        if isCancelled {
            return []
        }
        let K_COUNT = k
        guard places.count > K_COUNT else {
            if isCancelled {
                return []
            }
            let centroids: [BasicCluster] = places.map {
                var centroid = BasicCluster()
                centroid.places.append($0)
                return centroid
            }
            return centroids
        }
        var centroids = optimalCentroids(k: K_COUNT, places: places)
        var indexes = [Int](repeating: -1, count: places.count)
        var flag: Bool
        repeat {
            if isCancelled {
                return []
            }
            flag = false
            for i in (0..<places.count) {
                var minDistance = Double.greatestFiniteMagnitude
                var indexOfNearest = 0
                for (index, centroid) in centroids.enumerated() {
                    let distance = places[i].distanceTo(centroid)
                    if distance < minDistance {
                        minDistance = distance
                        indexOfNearest = index
                    }
                }
                if indexes[i] == -1 {
                    centroids[indexOfNearest].places.append(places[i])
                    indexes[i] = indexOfNearest
                    flag = true
                } else if indexes[i] != indexOfNearest {
                    centroids[indexes[i]].remove(places[i])
                    centroids[indexOfNearest].places.append(places[i])
                    indexes[i] = indexOfNearest
                    flag = true
                }
            }
        } while flag
        return centroids
    }

    private func elbow(of places: [Place]) -> Int {
        if isCancelled {
            return 0
        }
        var distances: [Double] = []
        let maxK = places.count > 10 ? 10 : places.count
        if maxK <= 3 { return maxK }
        (1...maxK).forEach { K_COUNT in
            if isCancelled {
                return
            }
            var centroids = optimalCentroids(k: K_COUNT, places: places)
            var indexes = [Int](repeating: -1, count: places.count)
            var flag: Bool
            repeat {
                if isCancelled {
                    return
                }
                flag = false
                for i in (0..<places.count) {
                    var minDistance = Double.greatestFiniteMagnitude
                    var indexOfNearest = 0
                    for (index, centroid) in centroids.enumerated() {
                        let distance = places[i].distanceTo(centroid)
                        if distance < minDistance {
                            minDistance = distance
                            indexOfNearest = index
                        }
                    }
                    if indexes[i] == -1 {
                        centroids[indexOfNearest].places.append(places[i])
                        indexes[i] = indexOfNearest
                        flag = true
                    } else if indexes[i] != indexOfNearest {
                        centroids[indexes[i]].remove(places[i])
                        centroids[indexOfNearest].places.append(places[i])
                        indexes[i] = indexOfNearest
                        flag = true
                    }
                }
            } while flag
            let totalDistance = centroids.reduce(0.0, {$0 + $1.totalDistance})
            distances.append(totalDistance)
        }
        if isCancelled {
            return 0
        }
        var thetas: [(theta: Double, index: Int)] = []
        for i in (1..<(maxK-1)) { // 1~8 (양끝 0, 9 빼고)
            let diff1 = distances[i-1] - distances[i]
            let diff2 = distances[i] - distances[i+1]
            let theta = atan(diff1) - atan(diff2)
            thetas.append((theta, i))
        }
        thetas.sort(by: {$0.theta > $1.theta})
        guard thetas.count >= 2 else {
            return (thetas[0].index + 1)
        }
        return thetas[0].index > thetas[1].index ?
            (thetas[0].index + 1) : (thetas[1].index + 1)
    }
}
