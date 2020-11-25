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
    func distanceTo(_ cluster: Cluster) -> Double {
        return sqrt(pow(totalLatitude / Double(places.count) - cluster.totalLatitude / Double(cluster.places.count), 2) + pow(totalLongitude / Double(places.count) - cluster.totalLongitude / Double(cluster.places.count), 2))
    }
    func distanceTo(lat: Double, lng: Double) -> Double {
        return sqrt(pow(totalLatitude / Double(places.count) - lat, 2) + pow(totalLongitude / Double(places.count) - lng, 2))
    }
}
extension Cluster: Comparable {
    static func < (left: Cluster, right: Cluster) -> Bool {
        let leftDistance = left.distanceTo(lat: ViewController.zeroPosition.lat, lng: ViewController.zeroPosition.lat)
        let rightDistance = right.distanceTo(lat: ViewController.zeroPosition.lat, lng: ViewController.zeroPosition.lat)
        if leftDistance < rightDistance {
            return true
        } else if leftDistance > rightDistance {
            return false
        } else {
            return left.totalLatitude / Double(left.places.count) < right.totalLatitude / Double(right.places.count)
        }
    }
}
class ScaleBasedClustering {
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
            tempClusters.sort()
            while tempClusters.count != 0 {
                var curPlace = tempClusters.removeFirst()
                var clusterCount = tempClusters.count
                var index = 0
                while index < clusterCount {
                    if curPlace.distanceTo(tempClusters[index]) <= mapScale {
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
