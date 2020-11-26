//
//  ScaleBasedClustering.swift
//  NaverMapA
//
//  Created by 김병인 on 2020/11/25.
//

import Foundation
class ScaleBasedClustering: Clusterable {
    func execute(places: [Place], bounds: CoordinateBounds) -> [Cluster] {
        let mapScale = sqrt(pow(bounds.northEastLat - bounds.southWestLat, 2) + pow(bounds.northEastLng - bounds.southWestLng, 2)) / 12
        if places.count == 0 {
            return []
        }
        var clusterArray = [Cluster]()
        for place in places {
            clusterArray.append(Cluster(latitude: place.latitude, longitude: place.longitude, places: [place]))
        }
        var isUpdate = true
        while isUpdate != false {
            isUpdate = false
            var tempClusterArray = clusterArray
            clusterArray.removeAll()
            tempClusterArray.sort()
            while tempClusterArray.count != 0 {
                var curPlace = tempClusterArray.removeFirst()
                var clusterCount = tempClusterArray.count
                var index = 0
                while index < clusterCount {
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
