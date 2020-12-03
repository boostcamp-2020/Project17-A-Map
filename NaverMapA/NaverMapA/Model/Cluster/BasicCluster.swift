//
//  BasicCluster.swift
//  NaverMapA
//
//  Created by 채훈기 on 2020/12/01.
//

import Foundation

struct BasicCluster: Cluster {
    var latitude: Double = 0
    var longitude: Double = 0
    var places: [Place] = [Place]() {
        didSet {
            let n = oldValue.count
            if n < places.count {
                latitude = (Double(n)*latitude + places.last!.latitude) / Double(n + 1)
                longitude = (Double(n)*longitude + places.last!.longitude) / Double(n + 1)
            }
        }
    }
    var placesDictionary: [Point: Int] = [:]
    
    mutating func remove(_ place: Place) {
        if let index = places.firstIndex(of: place) {
            let n = places.count
            places.remove(at: index)
            latitude = n == 1 ? 0 : (Double(n)*latitude - place.latitude) / Double(n - 1)
            longitude = n == 1 ? 0 : (Double(n)*longitude - place.longitude) / Double(n - 1)
        }
    }
    
    var totalDistance: Double {
        places.reduce(0.0, {$0 + $1.distanceTo(self)})
    }
    
    func distanceTo(_ cluster: Cluster) -> Double {
        return sqrt(pow(latitude - cluster.latitude, 2) + pow(longitude - cluster.longitude, 2))
    }
    
    func distanceTo(lat: Double, lng: Double) -> Double {
        return sqrt(pow(latitude - lat, 2) + pow(longitude - lng, 2))
    }
    
}

extension BasicCluster: Comparable {
    static func < (left: BasicCluster, right: BasicCluster) -> Bool {
        let lPow = pow(left.latitude, 2) + pow(left.longitude, 2)
        let rPow = pow(right.latitude, 2) + pow(right.longitude, 2)
        return lPow<rPow
    }
}

struct Point: Hashable {
    var latitude: Double
    var longitude: Double
}
