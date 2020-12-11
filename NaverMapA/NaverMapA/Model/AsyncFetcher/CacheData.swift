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
    var loadingResponses = [NSString: (Item, UIImage?) -> Void]()
    
    let imageURLProtocol = ImageURLProtocol()
    let loadingResponseInsertQueue = DispatchQueue(label: "loadingResponseInsertQueue")
    
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
        let task = imageURLProtocol.urlSession.dataTask(with: url) { (data, _, error) in
            DispatchQueue.main.async {
                guard let responseData = data, let image = UIImage(data: responseData), error == nil else {
                    self.cachedImages.setObject(UIImage(systemName: "xmark.circle")!, forKey: urlStr)
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
                print(error)
            }
        }
        task?.resume()
        return task
    }
    
    final func load(url: URL, item: Item, completion: @escaping (Item, UIImage?) -> Void) {
        let urlStr = url.absoluteString as NSString
        if let cachedImage = image(url: urlStr) {
            DispatchQueue.main.async {
                completion(item, cachedImage)
            }
            return
        }
        loadingResponses[urlStr] = completion
        imageURLProtocol.urlSession.dataTask(with: url) { (data, _, error) in
            guard let responseData = data, let image = UIImage(data: responseData),
                  let block = self.loadingResponses[urlStr], error == nil else {
                DispatchQueue.main.async {
                    completion(item, nil)
                }
                return
            }
            self.cachedImages.setObject(image, forKey: urlStr, cost: responseData.count)
            DispatchQueue.main.async {
                block(item, image)
            }
        }.resume()
    }
    
    func cancelLoading() {
        loadingResponses.removeAll()
    }
    
}

class ImageURLProtocol: URLProtocol {
    
    var cancelledOrComplete: Bool = false
    var block: DispatchWorkItem!
    
    private let queue = DispatchQueue(label: "imageLoader")
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    class override func requestIsCacheEquivalent(_ aRequest: URLRequest, to bRequest: URLRequest) -> Bool {
        return false
    }
    
    final override func startLoading() {
        guard let reqURL = request.url, let urlClient = client else {
            return
        }
        block = DispatchWorkItem(block: {
            if self.cancelledOrComplete == false {
                let fileURL = URL(fileURLWithPath: reqURL.path)
                if let data = try? Data(contentsOf: fileURL) {
                    urlClient.urlProtocol(self, didLoad: data)
                    urlClient.urlProtocolDidFinishLoading(self)
                }
            }
            self.cancelledOrComplete = true
        })
        queue.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: 500 * NSEC_PER_MSEC), execute: block)
    }
    
    final override func stopLoading() {
        queue.async {
            if self.cancelledOrComplete == false, let cancelBlock = self.block {
                cancelBlock.cancel()
                self.cancelledOrComplete = true
            }
        }
    }
    
    let urlSession = URLSession(configuration: .default)
    
}
