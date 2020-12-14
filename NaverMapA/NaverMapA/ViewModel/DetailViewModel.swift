//
//  DetailViewModel.swift
//  NaverMapA
//
//  Created by 홍경표 on 2020/12/03.
//

import Foundation
import UIKit

final class DetailViewModel: NSObject {
    
    var identifier = UUID()
    
    var name: Dynamic<String>
    
    var latitude: Dynamic<Double>
    
    var longitude: Dynamic<Double>
    
    var address: Dynamic<String>
    
    var url: Dynamic<URL?>
    
    init(place: Place) {
        self.name = .init(place.name)
        self.latitude = .init(place.latitude)
        self.longitude = .init(place.longitude)
        self.address = .init("불러오는 중")
        self.url = .init(URL(string: place.imageUrl ?? "") ?? nil)
    }
    
}
