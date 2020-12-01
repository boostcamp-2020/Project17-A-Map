//
//  RemainKMeansTest.swift
//  NaverMapATests
//
//  Created by 채훈기 on 2020/11/27.
//

import XCTest
import CoreData

class RemainKMeansTest: XCTestCase {

    var context: NSManagedObjectContext!
    var places: [Place] = []
    
    override func setUpWithError() throws {
        context = PlaceProvider.shared.mainContext
        
        places = (1..<4).map { i -> Place in
            let json = JsonPlace(id: "", name: "", longitude: 0, latitude: Double(i), imageUrl: nil, category: "")
            let place = Place(context: context)
            place.configure(json: json)
            return place
        }
    }
    
    func test_centroid_of_farthestPlace() {
    
        let newPlace = Place(context: context)
        newPlace.configure(json: JsonPlace(id: "", name: "", longitude: 0, latitude: 0, imageUrl: "", category: ""))

        let center = PenaltyCluster(places: places)
        let ret = center.farthestPlaces(from: newPlace)
        
        XCTAssertEqual(ret[0].latitude, 2)
    }
    
    func test_centroid_of_CenterLngLat() {
        
        let newPlace = Place(context: context)
        newPlace.configure(json: JsonPlace(id: "", name: "", longitude: 0, latitude: 2, imageUrl: "", category: ""))
        let center = PenaltyCluster(places: places)
        center.append(jsonPlace: newPlace)
        XCTAssertEqual(center.latitude, 2)
        
    }
}
