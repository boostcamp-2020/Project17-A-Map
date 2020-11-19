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
}
