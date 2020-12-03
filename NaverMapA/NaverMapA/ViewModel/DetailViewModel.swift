//
//  DetailViewModel.swift
//  NaverMapA
//
//  Created by 홍경표 on 2020/12/03.
//

import Foundation

final class DetailViewModel: NSObject {
    
    var name: Dynamic<String>
    
    var latitude: Dynamic<Double>
    
    var longitude: Dynamic<Double>
    
    var imageUrl: Dynamic<String>
    
    init(place: Place) {
        self.name = .init(place.name)
        self.latitude = .init(place.latitude)
        self.longitude = .init(place.longitude)
        self.imageUrl = .init(place.imageUrl ?? "")
    }
    
}
