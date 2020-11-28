//
//  RemainKmeans.swift
//  NaverMapA
//
//  Created by 채훈기 on 2020/11/27.
//

import Foundation

class Centroid {
    
    var latitude: Double
    var longitude: Double
    var places: [JsonPlace]
    
    init(places: [JsonPlace]) {
        self.places = places
        latitude = places.reduce(0, { $0 + $1.latitude }) / Double(places.count)
        longitude = places.reduce(0, { $0 + $1.longitude }) / Double(places.count)
    }
    
    func sumDistanceFromPlaces() -> Double {
        return places.reduce(0, { $0 + $1.distanceTo(lat: latitude, lng: longitude) })
    }
    
    func farthestPlaces(from place: JsonPlace) -> [JsonPlace] {
        let distances = places.map { ($0.distanceTo(place), $0) }
        return Array(distances.sorted { $0.0 < $1.0 }.map { $0.1 }.dropFirst())
    }
}

final class RemainKmeans: Clusterable {
    
    func execute(places: [Place], bounds: CoordinateBounds) -> [Cluster] {
        // 최대 평균 거리 중심 구하기
        // 3 은 임의의 k 개수
        let jsonPlaces = places.map { JsonPlace(place: $0) }
        var centroids = initialCentroid(jsonPlaces: jsonPlaces)
        
        return []
    }
    
    func initialCentroid(jsonPlaces: [JsonPlace]) -> [Centroid] {
        let initailRandomCentroid = (0..<3).map { _ -> JsonPlace in
            let idx = Int.random(in: 0..<jsonPlaces.count)
            return jsonPlaces[idx]
        }
        
        var centerOfCentroid = Centroid(places: initailRandomCentroid)
        
        for place in jsonPlaces {
            let newCandidatePlace = centerOfCentroid.farthestPlaces(from: place) + [place]
            let newCenterOfCentroid = Centroid(places: newCandidatePlace)
            if newCenterOfCentroid.sumDistanceFromPlaces() > centerOfCentroid.sumDistanceFromPlaces() {
                centerOfCentroid = newCenterOfCentroid
            }
        }
        
        return centerOfCentroid.places.map { Centroid(places: [$0]) }
    }
    
    func distributeToCentroid(jsonPlace: [JsonPlace], centroids: [Centroid]) -> [Centroid] {
        
        return []
    }
}
