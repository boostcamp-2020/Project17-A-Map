//
//  PenaltyCluster.swift
//  NaverMapA
//
//  Created by 채훈기 on 2020/12/01.
//

import Foundation

class PenaltyCluster: Cluster, Equatable {
    
    var latitude: Double
    var longitude: Double
    var places: [Place]
    
    init(places: [Place]) {
        self.places = places
        latitude = places.reduce(0, { $0 + $1.latitude }) / Double(places.count)
        longitude = places.reduce(0, { $0 + $1.longitude }) / Double(places.count)
    }
    
    init(lat: Double, lng: Double, places: [Place]) {
        latitude = lat
        longitude = lng
        self.places = places
    }
    
    func append(jsonPlace: Place) {
        let count = places.count
        latitude = (Double(count)*latitude + jsonPlace.latitude) / Double(count + 1)
        longitude = (Double(count)*longitude + jsonPlace.longitude) / Double(count + 1)
        places.append(jsonPlace)
    }
    
    func clearPlaces() {
        places = []
    }
    
    func sumDistanceInCentroid() -> Double {
        return places.reduce(0, { $0 + $1.distanceTo(lat: latitude, lng: longitude) })
    }
    
    func farthestPlaces(from place: Place) -> [Place] {
        let distances = places.map { ($0.distanceTo(place), $0) }
        return Array(distances.sorted { $0.0 < $1.0 }.map { $0.1 }.dropFirst())
    }
    
    func distanceTo(_ jsonPlace: Place) -> Double {
        return sqrt(pow(latitude - jsonPlace.latitude, 2) + pow(longitude - jsonPlace.longitude, 2))
    }
    
    var totalDistance: Double {
        places.reduce(0.0, {$0 + $1.distanceTo(self)})
    }
    
    static func == (lhs: PenaltyCluster, rhs: PenaltyCluster) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
