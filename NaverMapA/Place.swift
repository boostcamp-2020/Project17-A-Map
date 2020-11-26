//
//  Place+CoreDataClass.swift
//  NaverMapA
//
//  Created by 홍경표 on 2020/11/19.
//
//

import Foundation
import CoreData

@objc(Place)
public class Place: NSManagedObject {

    func configure(json: JsonPlace) {
        id = json.id
        name = json.name
        longitude = json.longitude
        latitude = json.latitude
        imageUrl = json.imageUrl
        category = json.category
    }
}

extension Place {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Place> {
        return NSFetchRequest<Place>(entityName: PlaceInputGuide.place.rawValue)
    }

    @NSManaged public var category: String
    @NSManaged public var id: String
    @NSManaged public var imageUrl: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var name: String

}

extension Place: Identifiable {

}

extension Place {
    enum PlaceInputGuide: String {
        case place = "Place"
    }
    enum Key: String {
        case category
        case id
        case imageUrl
        case latitude
        case longitude
        case name
    }
}
