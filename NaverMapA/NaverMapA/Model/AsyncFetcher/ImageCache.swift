//
//  ImageCache.swift
//  NaverMapA
//
//  Created by 홍경표 on 2020/12/10.
//

import UIKit

final class ImageCache {
    
    public static let publicCache = ImageCache()
    var placeholderImage = UIImage(systemName: "nosign")!
    let cachedImages = NSCache<NSString, UIImage>()
    var loadingResponses = [NSString: (Item, UIImage?) -> Void]()
    
    let imageURLProtocol = ImageURLProtocol()
    
    let loadingResponseInsertQueue = DispatchQueue(label: "loadingResponseInsertQueue")
    
    static var checkedArray: [Bool] = []
    
    public final func image(url: NSString) -> UIImage? {
        return cachedImages.object(forKey: url)
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
