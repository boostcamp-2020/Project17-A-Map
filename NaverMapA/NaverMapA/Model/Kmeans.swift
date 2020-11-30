//
//  RemainKmeans.swift
//  NaverMapA
//
//  Created by 채훈기 on 2020/11/27.
//

import Foundation

class Centroid: Equatable {
    
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
    
    static func == (lhs: Centroid, rhs: Centroid) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

final class Kmeans: Clusterable {
    
    func execute(places: [Place], bounds: CoordinateBounds) -> [Cluster] {
        var candidateCluster: [[Cluster]] = []
        let maximumK = places.count < 40 ? places.count : 40
        
        for k in 1..<maximumK {
            let clusters = clustering(places: places, k: k)
            candidateCluster.append(clusters)
        }
        
        return bestCluster(clusters: candidateCluster)
    }
    
    func bestCluster(clusters: [[Cluster]]) -> [Cluster] {
        var distances = clusters.map { candidate in
            candidate.reduce(0.0, { $0 + $1.totalDistance })
        }

        let diffDistance = (0..<(distances.count) - 1).map { i -> Double in
            return distances[i] - distances[i + 1]
        }

        let decreaseAverage = diffDistance.reduce(0.0, {$0 + $1}) / Double(diffDistance.count)

        var minDistance = Double.greatestFiniteMagnitude
        var minIdx = 0
        for i in 0..<distances.count {
            distances[i] -= decreaseAverage * Double(i)
            if distances[i] > 0 && distances[i] < minDistance {
                minDistance = distances[i]
                minIdx = i
            }
        }
        return clusters[minIdx]
    }
    
    func clustering(places: [Place], k: Int) -> [Cluster] {
        var centroids = initialCentroid(k: k, places: places)
        let iterationCount = 3
        centroids = distributeToCentroid(places: places, centroids: centroids)

        for _ in 0..<iterationCount {
            var newCentroids = centroids.map { Centroid(lat: $0.latitude, lng: $0.longitude, places: [])}
            newCentroids = distributeToCentroid(places: places, centroids: newCentroids)
            centroids = newCentroids
        }
        
        return centroids.map { Cluster(latitude: $0.latitude, longitude: $0.longitude, places: $0.places)}
    }
    
    func initialCentroid(k: Int, places: [Place]) -> [Centroid] {
        let initailRandomCentroid = (0..<k).map { _ -> Place in
            let idx = Int.random(in: 0..<places.count)
            return places[idx]
        }
        
        var centerOfCentroid = Centroid(places: initailRandomCentroid)
        
        for place in places {
            let newCandidateCentroid = centerOfCentroid.farthestPlaces(from: place) + [place]
            let newCenterOfCentroid = Centroid(places: newCandidateCentroid)
            if newCenterOfCentroid.sumDistanceInCentroid() > centerOfCentroid.sumDistanceInCentroid() {
                centerOfCentroid = newCenterOfCentroid
            }
        }
        
        let centroidToCluster = centerOfCentroid.places.map { Centroid(places: [$0]) }
        centroidToCluster.forEach { $0.clearPlaces() }
        return centroidToCluster
    }
    
    func distributeToCentroid(places: [Place], centroids: [Centroid]) -> [Centroid] {
        let distributedCentroid = centroids
        
        places.forEach { place in
            let distances = distributedCentroid
                            .map { ($0.distanceTo(place), $0) }
                            .sorted { $0.0 < $1.0 }
            distances[0].1.append(jsonPlace: place)
        }

        return distributedCentroid
    }
}
