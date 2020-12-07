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
      
    }
    func insert(item: Entity) throws {
    }
    func update(item: Entity) throws {
    }
    func delete(item: Entity) throws {
    }
}
