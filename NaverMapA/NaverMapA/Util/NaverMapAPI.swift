//
//  NaverMapRepository.swift
//  NaverMapA
//
//  Created by 김병인 on 2020/12/07.
//

import Foundation
import Network

final class NaverMapAPI {
    private static let baseURL = "https://naveropenapi.apigw.ntruss.com/map-reversegeocode/v2/gc"
    static func getData(lng: Double, lat: Double, completion: ((Result<Data, Error>) -> Void)?) -> URLSessionTask? {
        guard let url = URL(string: "\(baseURL)?coords=\(lng),\(lat)&output=json&orders=roadaddr") else {
            return nil
        }
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(Environment.clientId, forHTTPHeaderField: "X-NCP-APIGW-API-KEY-ID")
        request.setValue(Environment.clientSecret, forHTTPHeaderField: "X-NCP-APIGW-API-KEY")
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, _, _ in
            guard let data = data else {
                return
            }
            guard (try? JSONSerialization.jsonObject(with: data) as? [String: Any]) != nil else {
                return
            }
            completion?(.success(data))
        })
        task.resume()
        return task
    }
}

extension NaverMapAPI {
    static func getAddress(address: Data) -> String? {
        if let statusCode = try? JSONDecoder().decode(Geocoding.self, from: address).status, statusCode.code == 3 {
            return nil
        }
        let geocoding = try? JSONDecoder().decode(Geocoding.self, from: address).results?.first
        let region = geocoding?.region
        let area1 = region?.area1?.name ?? ""
        let area2 = region?.area2?.name ?? ""
        let area3 = region?.area3?.name ?? ""
        let area4 = region?.area4?.name ?? ""
        let land = geocoding?.land
        let number1 = land?.number1 ?? ""
        var number2 = land?.number2 ?? ""
        if number2 != "" {
            number2 = "-" + number2
        }
        if let loadName = land?.name {
            return "\(area1) \(area2) \(area3) \(loadName) \(number1)\(number2)"
        } else {
            return "\(area1) \(area2) \(area3) \(area4)"
        }
    }
}
