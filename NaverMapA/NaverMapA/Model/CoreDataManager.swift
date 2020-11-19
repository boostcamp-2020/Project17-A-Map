//
//  CoreDataManager.swift
//  NaverMapA
//
//  Created by 홍경표 on 2020/11/19.
//

import Foundation
import CoreData

class CoreDataManager {
    static let shared: CoreDataManager = CoreDataManager()
    var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: CoreDataManagerInputGuide.persistentContainerName.rawValue)
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    var context: NSManagedObjectContext {
        return self.persistentContainer.viewContext
    }
    func fetch<T: NSManagedObject>(request: NSFetchRequest<T>) -> [T] {
        do {
            let fetchResult = try self.context.fetch(request)
            return fetchResult
        } catch {
            print(error.localizedDescription)
            return []
        }
    }
    @discardableResult
    func insertPlace(place: JsonPlace) -> Bool {
        let entity = NSEntityDescription.entity(forEntityName: CoreDataManagerInputGuide.entityName.rawValue, in: self.context)
        if let entity = entity {
            let managedObject = NSManagedObject(entity: entity, insertInto: self.context)
            print(entity.attributesByName.keys)
            managedObject.setValue(place.id, forKey: Place.Key.id.rawValue)
            managedObject.setValue(place.name, forKey: Place.Key.name.rawValue)
            managedObject.setValue(place.longitude, forKey: Place.Key.longitude.rawValue)
            managedObject.setValue(place.latitude, forKey: Place.Key.latitude.rawValue)
            managedObject.setValue(place.imageUrl, forKey: Place.Key.imageUrl.rawValue)
            managedObject.setValue(place.category, forKey: Place.Key.category.rawValue)
            do {
                try self.context.save()
                return true
            } catch {
                print(error.localizedDescription)
                return false
            }
        } else {
            return false
        }
    }
    @discardableResult
    func delete(object: NSManagedObject) -> Bool {
        self.context.delete(object)
        do {
            try context.save()
            return true
        } catch {
            return false
        }
    }
    @discardableResult
    func deleteAll<T: NSManagedObject>(request: NSFetchRequest<T>) -> Bool {
        let request: NSFetchRequest<NSFetchRequestResult> = T.fetchRequest()
        let delete = NSBatchDeleteRequest(fetchRequest: request)
        do {
            try self.context.execute(delete)
            return true
        } catch {
            print(error)
            return false
        }
    }
    func count<T: NSManagedObject>(request: NSFetchRequest<T>) -> Int? {
        do {
            let count = try self.context.count(for: request)
            return count
        } catch {
            return nil
        }
    }
}

extension CoreDataManager {
    enum CoreDataManagerInputGuide: String {
        case persistentContainerName = "NaverMapA"
        case entityName = "Place"
    }
}
