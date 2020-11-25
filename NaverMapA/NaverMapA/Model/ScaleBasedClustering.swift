//
//  ScaleBasedClustering.swift
//  NaverMapA
//
//  Created by 김병인 on 2020/11/25.
//

import Foundation
struct Cluster {
    var totalLatitude: Double = 0
    var totalLongitude: Double = 0
    var places: [Place] = [Place]()
}
class ScaleBasedClustering {
    private func distance(origin: Cluster, destination: Cluster) -> Double {
        return sqrt(pow(origin.totalLatitude / Double(origin.places.count) - destination.totalLatitude / Double(destination.places.count), 2) + pow(origin.totalLongitude / Double(origin.places.count) - destination.totalLongitude / Double(destination.places.count), 2))
    }
    public func Run(datas: [Place], mapScale: Double, completion: ([Cluster]) -> Void) {
        if datas.count == 0 {
            completion([])
        }
        var cluster = [Cluster]()
        for place in datas {
            cluster.append(Cluster(totalLatitude: place.latitude, totalLongitude: place.longitude, places: [place]))
        }
        var isUpdate = true
        while isUpdate != false {
            isUpdate = false
            var tempClusters = cluster
            cluster.removeAll()
            while tempClusters.count != 0 {
                var curPlace = tempClusters.removeFirst()
                var clusterCount = tempClusters.count
                var index = 0
                while index < clusterCount {
                    if distance(origin: curPlace, destination: tempClusters[index]) <= mapScale {
                        curPlace.totalLatitude += tempClusters[index].totalLatitude
                        curPlace.totalLongitude += tempClusters[index].totalLongitude
                        curPlace.places.append(contentsOf: tempClusters[index].places)
                        tempClusters.remove(at: index)
                        isUpdate = true
                        index = 0
                        clusterCount -= 1
                    } else {
                        index += 1
                    }
                }
                cluster.append(curPlace)
            }
        }
        completion(cluster)
    }
}
