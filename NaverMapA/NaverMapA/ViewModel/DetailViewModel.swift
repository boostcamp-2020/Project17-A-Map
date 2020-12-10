//
//  DetailViewModel.swift
//  NaverMapA
//
//  Created by 홍경표 on 2020/12/03.
//

import Foundation

final class DetailViewModel: NSObject {
    
    var identifier = UUID()
    
    var name: Dynamic<String>
    
    var latitude: Dynamic<Double>
    
    var longitude: Dynamic<Double>
    
    var address: Dynamic<String>?
    
    var imageUrl: Dynamic<String>
    
    init(place: Place) {
        self.name = .init(place.name)
        self.latitude = .init(place.latitude)
        self.longitude = .init(place.longitude)
        self.imageUrl = .init(place.imageUrl ?? "")
    }
    
    func updateAddress() {
        NaverMapAPI.getData(lng: longitude.value, lat: latitude.value) { response in
            do {
                let data = try response.get()
                let address = NaverMapAPI.getAddress(address: data)
                self.address = .init(address ?? "오류")
            } catch {
                print(error)
            }
        }
    }
    
}
