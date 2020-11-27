//
//  RemainKmeans.swift
//  NaverMapA
//
//  Created by 채훈기 on 2020/11/27.
//

import Foundation

class PointLngLat {
    
    var latitude: Double
    var longitude: Double
    var places: [Place]
    
    init(places: [Place]) {
        self.places = places
        latitude = places.reduce(0, { $0 + $1.latitude }) / Double(places.count)
        longitude = places.reduce(0, { $0 + $1.longitude }) / Double(places.count)
    }
    
    func sumDistanceFromPlaces() -> Double {
        return places.reduce(0, { $0 + $1.distanceTo(lat: latitude, lng: longitude) })
    }
    
}

final class RemainKmeans: Clusterable {
    
    func execute(places: [Place], bounds: CoordinateBounds) -> [Cluster] {
        // 최대 평균 거리 중심 구하기
        // 3 은 임의의 k 개수
        let initailRandomCentroid = (0..<3).map { _ -> Place in
            let idx = Int.random(in: 0..<places.count)
            return places[idx]
        }
        
        var centerOfInitRandCentroid = PointLngLat(places: initailRandomCentroid)
        
        return []
    }
    
    
    
    
}
