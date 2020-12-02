//
//  Cluster.swift
//  NaverMapA
//
//  Created by 채훈기 on 2020/11/26.
//

import Foundation

protocol Cluster {
    var latitude: Double { get set }
    var longitude: Double { get set }
    var places: [Place] { get set }
    var placesDictionary: [Point: Int] { get set }
}
