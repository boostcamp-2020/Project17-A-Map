//
//  Clustering.swift
//  NaverMapA
//
//  Created by 채훈기 on 2020/11/26.
//

import Foundation

protocol Clusterable: NSCopying {
    var places: [Place] { get set }
    var bounds: CoordinateBounds { get set }
    var clusters: [Cluster] { get set }
    func execute(places: [Place], bounds: CoordinateBounds) -> [Cluster]
}

class MockCluster: Clusterable {
    var places: [Place] = []
    
    var bounds: CoordinateBounds = CoordinateBounds(southWestLng: 0, northEastLng: 0, southWestLat: 0, northEastLat: 0)
    
    var clusters: [Cluster] = []
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = MockCluster()
        return copy
    }
    func execute(places: [Place], bounds: CoordinateBounds) -> [Cluster] {
        return []
    }
}
