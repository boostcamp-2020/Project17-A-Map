//
//  ScaleBasedClustering.swift
//  NaverMapA
//
//  Created by 김병인 on 2020/11/25.
//

import Foundation
struct Cluster {
    var latitude: Double = 0
    var longitude: Double = 0
    var places: [Place] = [Place]() {
        didSet {
            let n = oldValue.count
            latitude = (Double(n)*latitude + places.last!.latitude) / Double(n + 1)
            longitude = (Double(n)*longitude + places.last!.longitude) / Double(n + 1)
        }
    }
    func distanceTo(_ cluster: Cluster) -> Double {
        return sqrt(pow(latitude - cluster.latitude, 2) + pow(longitude - cluster.longitude, 2))
    }
    func distanceTo(lat: Double, lng: Double) -> Double {
        return sqrt(pow(latitude - lat, 2) + pow(longitude - lng, 2))
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
            return left.latitude < right.latitude
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
            cluster.append(Cluster(latitude: place.latitude, longitude: place.longitude, places: [place]))
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
                        for p in tempClusters[index].places {
                            curPlace.places.append(p)
                        }
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
