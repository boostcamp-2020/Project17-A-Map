//
//  NaverMapRepository.swift
//  NaverMapA
//
//  Created by 김병인 on 2020/12/07.
//

import Foundation
import Network

class NaverMapRepository: Repository {
    typealias Entity = Place
    
    private let baseURL = "https://naveropenapi.apigw.ntruss.com/map-reversegeocode/v2/gc"
    
    func getAll(finishedCallback: @escaping (_ labels: [Entity]?) -> Void) {
    }
    
    func get(item entity: Entity, completion: ((Result<Data, Error>) -> Void)?) {
        guard let url = URL(string: "\(baseURL)?coords=\(entity.longitude),\(entity.latitude)&output=json&orders=roadaddr") else {
            return
        }
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(Environment.clientId, forHTTPHeaderField: "X-NCP-APIGW-API-KEY-ID")
        request.setValue(Environment.clientSecret, forHTTPHeaderField: "X-NCP-APIGW-API-KEY")
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, _, error in
            guard error == nil else {
                print(error!)
                return
            }
            guard let data = data else {
                return
            }
            guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                return
            }
            print(json)
            completion?(.success(data))
        })
        task.resume()
    }
    func insert(item: Entity) throws {
    }
    func update(item: Entity) throws {
    }
    func delete(item: Entity) throws {
    }
}
extension NaverMapRepository {
    func getAddress(address: Data) -> String? {
        do {
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
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}
