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
