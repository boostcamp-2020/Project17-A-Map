//
//  Clustering.swift
//  NaverMapA
//
//  Created by 채훈기 on 2020/11/26.
//

import Foundation

protocol Clusterable {
    func execute(places: [Place]) -> [Cluster]
}

class MockCluster: Clusterable {
    
    func execute(places: [Place]) -> [Cluster] {
        return []
    }
}
