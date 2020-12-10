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
    
    var address: Dynamic<String>?
    
    var item: Dynamic<Item>?
    
    init(place: Place) {
        self.name = .init(place.name)
        self.latitude = .init(place.latitude)
        self.longitude = .init(place.longitude)
        self.address = .init("불러오는 중")
        if let url = URL(string: place.imageUrl ?? "") {
            self.item = .init(Item(image: UIImage(systemName: "nosign")!, url: url))
        }
    }
    
    func loadAddress(completion: @escaping () -> Void) {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else { return }
            NaverMapAPI.getData(lng: self.longitude.value, lat: self.latitude.value) { response in
                do {
                    let data = try response.get()
                    let address = NaverMapAPI.getAddress(address: data)
                    self.address?.value = address ?? "주소 오류"
                    completion()
                } catch {
                    print(error)
                }
            }
        }
    }
    
    func loadImage(imageCacher: ImageCache, completion: @escaping () -> Void) {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else { return }
            guard let item = self.item?.value else { return }
            imageCacher.load(url: item.url, item: item) { (fetchedItem, image) in
                if let img = image, img != fetchedItem.image {
                    self.item?.value.image = img
                    completion()
                }
            }
        }
    }
}

class Item {
    
    var image: UIImage!
    let url: URL!
    let identifier = UUID()
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    static func == (lhs: Item, rhs: Item) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    init(image: UIImage, url: URL) {
        self.image = image
        self.url = url
    }
    
}
