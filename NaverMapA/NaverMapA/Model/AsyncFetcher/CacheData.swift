//
//  ImageCache.swift
//  NaverMapA
//
//  Created by 홍경표 on 2020/12/10.
//

import UIKit

final class CacheData {
    
    public static let publicCache = CacheData()
    var placeholderImage = UIImage(systemName: "hourglass")!
    let cachedImages = NSCache<NSString, UIImage>()
    let cachedAddress = NSCache<NSString, NSString>()
    
    public final func image(url: NSString) -> UIImage? {
        return cachedImages.object(forKey: url)
    }
    
    public final func address(lng: Double, lat: Double) -> NSString? {
        let key: NSString = "lng:\(lng)lat:\(lat)" as NSString
        return cachedAddress.object(forKey: key)
    }
    
    public func getImage(url: URL, completion: @escaping (UIImage?) -> Void) -> URLSessionTask? {
        var urlStr = url.absoluteString as NSString
        if urlStr == "" {
            urlStr = "None"
        }
        if let cachedImage = image(url: urlStr) {
            completion(cachedImage)
            return nil
        }
        let task = URLSession(configuration: .default).dataTask(with: url) { (data, _, error) in
            DispatchQueue.main.async {
                guard error == nil else {
                    completion(nil)
                    return
                }
                guard let responseData = data, let image = UIImage(data: responseData) else {
                    self.cachedImages.setObject(self.placeholderImage, forKey: urlStr)
                    completion(nil)
                    return
                }
                self.cachedImages.setObject(image, forKey: urlStr)
                completion(image)
            }
        }
        task.resume()
        return task
    }
    
    public func getAddress(lng: Double, lat: Double, completion: @escaping (NSString?) -> Void) -> URLSessionTask? {
        if let cachedAddress = address(lng: lng, lat: lat) {
            completion(cachedAddress)
            return nil
        }
        let task = NaverMapAPI.getData(lng: lng, lat: lat) { response in
            do {
                let data = try response.get()
                if let address = NaverMapAPI.getAddress(address: data) as NSString? {
                    self.cachedAddress.setObject(address, forKey: "lng:\(lng)lat:\(lat)" as NSString)
                    completion(address)
                } else {
                    completion(nil)
                }
            } catch {
            }
        }
        task?.resume()
        return task
    }
}
