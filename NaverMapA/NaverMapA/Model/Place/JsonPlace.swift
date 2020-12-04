//
//  JsonPlace.swift
//  NaverMapA
//
//  Created by 홍경표 on 2020/11/19.
//

import Foundation

struct JsonPlace {
    var id: String = ""
    var name: String = ""
    var longitude: Double = 0
    var latitude: Double = 0
    var imageUrl: String?
    var category: String = ""
}

extension JsonPlace: Decodable {
    enum CodingKeys: String, CodingKey {
        case longitude = "x"
        case latitude = "y"
        case id, name, imageUrl, category
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.id = try container.decode(String.self, forKey: .id)
        self.longitude = Double(try container.decode(String.self, forKey: .longitude)) ?? JsonPlaceInputGuideNumber.zero.rawValue
        self.latitude = Double(try container.decode(String.self, forKey: .latitude)) ?? JsonPlaceInputGuideNumber.zero.rawValue
        self.imageUrl = try container.decode(String?.self, forKey: .imageUrl)
        self.category = try container.decode(String.self, forKey: .category)
    }
    
    init(place: Place) {
        self.name = place.name
        self.id = place.id
        self.longitude = place.longitude
        self.latitude = place.latitude
        self.imageUrl = place.imageUrl
        self.category = place.category
    }
}

extension JsonPlace {
    enum JsonPlaceInputGuideNumber: Double {
        case zero = 0
    }
    enum JsonPlaceInputGuideString: String {
        case blank = ""
    }
}

extension JsonPlace: Equatable {
    
}
