//
//  Repository.swift
//  NaverMapA
//
//  Created by 김병인 on 2020/12/07.
//

import Foundation

protocol Repository {
    associatedtype Entity
    func getAll(finishedCallback: @escaping (_ entityObject: [Entity]?) -> Void)
    func get(item entity: Entity, completion: ((Result<Data, Error>) -> Void)?)
    func insert(item: Entity) throws
    func update(item: Entity) throws
    func delete(item: Entity) throws
}
