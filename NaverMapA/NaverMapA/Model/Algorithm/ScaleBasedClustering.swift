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
    
    func run() {
        clusters = execute(places: places, bounds: bounds)
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = ScaleBasedClustering()
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
        let mapScale = sqrt(pow(bounds.northEastLat - bounds.southWestLat, 2) + pow(bounds.northEastLng - bounds.southWestLng, 2)) / 12
        if places.count == 0 {
            return []
        }
        var clusterArray = [BasicCluster]()
        for place in places {
            clusterArray.append(BasicCluster(latitude: place.latitude, longitude: place.longitude, places: [place]))
        }
        if isCancelled {
            return []
        }
        var isUpdate = true
        while isUpdate != false {
            if isCancelled {
                return []
            }
            isUpdate = false
            var tempClusterArray = clusterArray
            clusterArray.removeAll()
            tempClusterArray.sort()
            while tempClusterArray.count != 0 {
                if isCancelled {
                    return []
                }
                var curPlace = tempClusterArray.removeFirst()
                var clusterCount = tempClusterArray.count
                var index = 0
                while index < clusterCount {
                    if isCancelled {
                        return []
                    }
                    if curPlace.distanceTo(tempClusterArray[index]) <= mapScale {
                        for tempPlace in tempClusterArray[index].places {
                            curPlace.places.append(tempPlace)
                        }
                        tempClusterArray.remove(at: index)
                        isUpdate = true
                        index = 0
                        clusterCount -= 1
                    } else {
                        index += 1
                    }
                }
                clusterArray.append(curPlace)
            }
        }
        return clusterArray
    }
}
