//
//  Cluster.swift
//  NaverMapA
//
//  Created by 채훈기 on 2020/11/26.
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
        let lPow = pow(left.latitude, 2) + pow(left.longitude, 2)
        let rPow = pow(right.latitude, 2) + pow(right.longitude, 2)
        return lPow<rPow
    }
}
