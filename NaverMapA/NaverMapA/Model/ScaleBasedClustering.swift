//
//  ScaleBasedClustering.swift
//  NaverMapA
//
//  Created by 김병인 on 2020/11/25.
//

import Foundation
struct Centroid {
    var totalLatitude: Double = 0
    var totalLongitude: Double = 0
    var clusters: [JsonPlace] = [JsonPlace]()
}
class ScaleBasedClustering {
    private func distance(origin: Centroid, destination: Centroid) -> Double {
        return sqrt(pow(origin.totalLatitude / Double(origin.clusters.count) - destination.totalLatitude / Double(destination.clusters.count), 2) + pow(origin.totalLongitude / Double(origin.clusters.count) - destination.totalLongitude / Double(destination.clusters.count), 2))
    }
    public func Run(datas: [JsonPlace], mapScale: Double, completion: ([Centroid]) -> Void) {
        if datas.count == 0 {
            completion([])
        }
        var cluster = [Centroid]()
        for place in datas {
            cluster.append(Centroid(totalLatitude: place.latitude, totalLongitude: place.longitude, clusters: [place]))
        }
        var isUpdate = true
        while cluster.count != 0 && isUpdate != false {
            isUpdate = false
            var curPlace = cluster.removeFirst()
            var clusterCount = cluster.count
            var index = 0
            while index < clusterCount {
                if distance(origin: curPlace, destination: cluster[index]) <= mapScale {
                    curPlace.totalLatitude += cluster[index].totalLatitude
                    curPlace.totalLongitude += cluster[index].totalLongitude
                    curPlace.clusters.append(contentsOf: cluster[index].clusters)
                    cluster.remove(at: index)
                    isUpdate = true
                    index = 0
                    clusterCount -= 1
                } else {
                    index += 1
                }
            }
            cluster.append(curPlace)
        }
        completion(cluster)
    }
}
