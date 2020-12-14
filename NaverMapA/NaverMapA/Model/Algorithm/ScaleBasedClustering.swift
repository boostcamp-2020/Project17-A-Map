//
//  ScaleBasedClustering.swift
//  NaverMapA
//
//  Created by 김병인 on 2020/11/25.
//

import Foundation

class ScaleBasedClustering: Operation, Clusterable {
    var places: [Place] = []
    
    var bounds: CoordinateBounds = CoordinateBounds(southWestLng: 0, northEastLng: 0, southWestLat: 0, northEastLat: 0)
    
    var clusters: [Cluster] = []
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = ScaleBasedClustering()
        return copy
    }
    
    override func main() {
        if isCancelled {
            return
        }
        clusters = execute(places: places, bounds: bounds)
    }
    
    func execute(places: [Place], bounds: CoordinateBounds) -> [Cluster] {
        let mapScale = sqrt(pow(bounds.northEastLat - bounds.southWestLat, 2) + pow(bounds.northEastLng - bounds.southWestLng, 2)) / 12
        if places.count == 0 {
            return []
        }
        var clusterArray = [BasicCluster]()
        for place in places where !isCancelled {
            clusterArray.append(BasicCluster(latitude: place.latitude, longitude: place.longitude, places: [place]))
        }
        var isUpdate = true
        while isUpdate != false && !isCancelled {
            isUpdate = false
            var tempClusterArray = clusterArray
            clusterArray.removeAll()
            tempClusterArray.sort()
            while tempClusterArray.count != 0 && !isCancelled {
                var curCluster = tempClusterArray.removeFirst()
                var clusterCount = tempClusterArray.count
                var index = 0
                while index < clusterCount && !isCancelled {
                    if curCluster.distanceTo(tempClusterArray[index]) <= mapScale {
                        for tempPlace in tempClusterArray[index].places {
                            curCluster.places.append(tempPlace)
                        }
                        tempClusterArray.remove(at: index)
                        isUpdate = true
                        index = 0
                        clusterCount -= 1
                    } else {
                        index += 1
                    }
                }
                clusterArray.append(curCluster)
            }
        }
        return isCancelled ? [] : clusterArray
    }
}
