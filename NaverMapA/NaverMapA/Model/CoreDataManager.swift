//
//  CoreDataManager.swift
//  NaverMapA
//
//  Created by 홍경표 on 2020/11/19.
//

import Foundation
import CoreData

class CoreDataManager {
    static var shared: CoreDataManager = CoreDataManager()
    var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "NaverMapA")
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
        let entity = NSEntityDescription.entity(forEntityName: "Place", in: self.context)
        if let entity = entity {
            let managedObject = NSManagedObject(entity: entity, insertInto: self.context)
            print(entity.attributesByName.keys)
            managedObject.setValue(place.id, forKey: "id")
            managedObject.setValue(place.name, forKey: "name")
            managedObject.setValue(place.lng, forKey: "lng")
            managedObject.setValue(place.lat, forKey: "lat")
            managedObject.setValue(place.imageUrl, forKey: "imageUrl")
            managedObject.setValue(place.category, forKey: "category")
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
}
