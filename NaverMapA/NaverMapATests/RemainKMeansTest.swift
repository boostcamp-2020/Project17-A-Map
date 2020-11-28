//
//  RemainKMeansTest.swift
//  NaverMapATests
//
//  Created by 채훈기 on 2020/11/27.
//

import XCTest
import CoreData

class RemainKMeansTest: XCTestCase {

    func testExample() {
        
        let places = (1..<4).map {
            return JsonPlace(id: "", name: "", longitude: 0, latitude: Double($0), imageUrl: nil, category: "")
        }
        let newPlace = JsonPlace(id: "", name: "", longitude: 0, latitude: 0, imageUrl: "", category: "")

        let center = PointLngLat(places: places)
        let ret = center.farthestPlaces(from: newPlace)
        print(ret[0].latitude)
        XCTAssertEqual(ret[0].latitude, 2)
    }
}
