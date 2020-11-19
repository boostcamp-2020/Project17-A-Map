//
//  JsonPlace.swift
//  NaverMapA
//
//  Created by 홍경표 on 2020/11/19.
//

import Foundation

struct JsonPlace {
    var id: String
    var name: String
    var longitude: Double
    var latitude: Double
    var imageUrl: String?
    var category: String
}

extension JsonPlace: Decodable {
    enum CodingKeys: String, CodingKey {
        case longitude = "x"
        case latitude = "y"
        case id, name, imageUrl, category
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = (try? container.decode(String.self, forKey: .name)) ?? ""
        self.id = (try? container.decode(String.self, forKey: .id)) ?? ""
        self.longitude = Double((try? container.decode(String.self, forKey: .longitude)) ?? "") ?? 0
        self.latitude = Double((try? container.decode(String.self, forKey: .latitude)) ?? "") ?? 0
        self.imageUrl = try? container.decode(String?.self, forKey: .imageUrl)
        self.category = (try? container.decode(String.self, forKey: .category)) ?? ""
    }
}
