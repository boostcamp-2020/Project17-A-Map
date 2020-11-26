//
//  KMeansClustering.swift
//  NaverMapA
//
//  Created by 홍경표 on 2020/11/27.
//

import Foundation

final class KMeansClustering {
    func kkk(datas: [Place], completion: ([Cluster]) -> Void) {
        let EXECUTE_TIMES = 3
        var centroids: [Cluster] = []
        var minTotalDistance = Double.greatestFiniteMagnitude
        var count: Int = 0 {
            didSet {
                if count == EXECUTE_TIMES {
                    completion(centroids)
                }
            }
        }
        let ks = (0..<5).map { _ in elbow(of: datas.shuffled()) }
        let bestK = ks.max()
        let k = bestK ?? ks[0]
//        print("@")
//        print(ks)
//        print("-")
//        print(k)
        (0..<EXECUTE_TIMES).forEach { _ in
            clustering(k: k, datas: datas.shuffled()) { (temp) in
                let totalDistance = temp.reduce(0.0, {$0 + $1.totalDistance})
//                print(totalDistance)
                if totalDistance < minTotalDistance {
                    minTotalDistance = totalDistance
                    centroids = temp
                }
            }
            count += 1
        }
    }
    private func optimalCentroids(k: Int, datas: [Place]) -> [Cluster] {
        let K_COUNT = k
        var centroids = [Cluster](repeating: Cluster(), count: K_COUNT)
        var optimals = Cluster()
        (0..<K_COUNT).forEach { optimals.places.append(datas[$0]) }
        for i in (0..<datas.count) {
            var minDistance = Double.greatestFiniteMagnitude
            var indexOfNearest = 0
            for j in (0..<optimals.places.count) {
                let distance = datas[i].distanceTo(optimals.places[j])
                if distance < minDistance {
                    minDistance = distance
                    indexOfNearest = j
                }
            }
            var newOptimals = optimals
            newOptimals.remove(newOptimals.places[indexOfNearest])
            newOptimals.places.append(datas[i])
            if newOptimals.totalDistance > optimals.totalDistance {
                optimals = newOptimals
            }
        }
        (0..<K_COUNT).forEach {
            centroids[$0].places.append(optimals.places[$0])
        }
        return centroids
    }
    private func clustering(k: Int, datas: [Place], completion: ([Cluster]) -> Void) {
        let K_COUNT = k
        guard datas.count > K_COUNT else {
            let centroids: [Cluster] = datas.map {
                var centroid = Cluster()
                centroid.places.append($0)
                return centroid
            }
            completion(centroids)
            return
        }
        var centroids = optimalCentroids(k: K_COUNT, datas: datas)
        var iii = [Int](repeating: -1, count: datas.count)
        var flag: Bool
        repeat {
            flag = false
            for i in (0..<datas.count) {
                var minDistance = Double.greatestFiniteMagnitude
                var indexOfNearest = 0
                for (index, centroid) in centroids.enumerated() {
                    let distance = datas[i].distanceTo(centroid)
                    if distance < minDistance {
                        minDistance = distance
                        indexOfNearest = index
                    }
                }
                if iii[i] == -1 {
                    centroids[indexOfNearest].places.append(datas[i])
                    iii[i] = indexOfNearest
                    flag = true
                } else if iii[i] != indexOfNearest {
                    centroids[iii[i]].remove(datas[i])
                    centroids[indexOfNearest].places.append(datas[i])
                    iii[i] = indexOfNearest
                    flag = true
                }
            }
        } while flag
        completion(centroids)
    }

    private func elbow(of datas: [Place]) -> Int {
        var distances: [Double] = []
        let maxK = datas.count > 10 ? 10 : datas.count
        if maxK <= 3 { return maxK }
        (1...maxK).forEach { K_COUNT in
            var centroids = optimalCentroids(k: K_COUNT, datas: datas)
            var iii = [Int](repeating: -1, count: datas.count)
            var flag: Bool
            repeat {
                flag = false
                for i in (0..<datas.count) {
                    var minDistance = Double.greatestFiniteMagnitude
                    var indexOfNearest = 0
                    for (index, centroid) in centroids.enumerated() {
                        let distance = datas[i].distanceTo(centroid)
                        if distance < minDistance {
                            minDistance = distance
                            indexOfNearest = index
                        }
                    }
                    if iii[i] == -1 {
                        centroids[indexOfNearest].places.append(datas[i])
                        iii[i] = indexOfNearest
                        flag = true
                    } else if iii[i] != indexOfNearest {
                        centroids[iii[i]].remove(datas[i])
                        centroids[indexOfNearest].places.append(datas[i])
                        iii[i] = indexOfNearest
                        flag = true
                    }
                }
            } while flag
            let totalDistance = centroids.reduce(0.0, {$0 + $1.totalDistance})
            distances.append(totalDistance)
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

