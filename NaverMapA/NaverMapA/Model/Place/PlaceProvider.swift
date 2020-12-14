//
//  CoreDataManager.swift
//  NaverMapA
//
//  Created by 홍경표 on 2020/11/19.
//

import UIKit
import CoreData

enum PlaceError: Error {
    case urlError
    case decodingFail
    case creationError
    case saveError
    case batchInsertError
    case batchDeleteError
}

class PlaceProvider {
    
    static let shared: PlaceProvider = PlaceProvider()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: Constant.persistentName)

        container.loadPersistentStores { _, error in
            guard error == nil else {
                fatalError("Unresolved error \(error!)")
            }
        }
        return container
    }()
    
    var mainContext: NSManagedObjectContext {
        return self.persistentContainer.viewContext
    }
    
    private func newTaskContext() -> NSManagedObjectContext {
        let taskContext = persistentContainer.newBackgroundContext()
        return taskContext
    }
    
    func insert(completionHandler: @escaping (Error?) -> Void) {
        DispatchQueue.global().async {
            guard let data = NSDataAsset(name: Constant.fileName)?.data else {
                completionHandler(PlaceError.urlError)
                return
            }
            do {
                let json = try JSONDecoder().decode([JsonPlace].self, from: data)
                let taskContext = self.newTaskContext()
                
                json.forEach {
                    let object = Place(context: taskContext)
                    object.configure(json: $0)
                }
                
                do {
                    try taskContext.save()
                } catch {
                    completionHandler(PlaceError.saveError)
                }
                
                completionHandler(nil)
            } catch {
                completionHandler(PlaceError.decodingFail)
            }
        }
    }
    
    func insertPlace(latitide: Double, longitude: Double, completionHandler: @escaping (Place?) -> Void) {
        let taskContext = self.newTaskContext()
        let object = Place(context: taskContext)
        object.configure(latitude: latitide, longitude: longitude)
        do {
            try taskContext.save()
            let place = placeFetch(place: object)
            completionHandler(place)
        } catch {
            completionHandler(nil)
        }
    }
    
    func placeFetch(place: Place) -> Place? {
        let fetchRequest: NSFetchRequest<Place> = Place.fetchRequest()
        let lat = place.latitude
        let lng = place.longitude
        let latlngPredict = NSPredicate(format: "latitude == %lf && longitude == %lf", lat, lng)
        fetchRequest.predicate = latlngPredict
        fetchRequest.fetchLimit = 1
        fetchRequest.returnsObjectsAsFaults = false
        let place = try? mainContext.fetch(fetchRequest)
        if let place = place {
            return place[0]
        } else {
            return nil
        }
    }
    
    func fetch(bounds: CoordinateBounds) -> [Place] {
        let minLng = bounds.southWestLng
        let maxLng = bounds.northEastLng
        let minLat = bounds.southWestLat
        let maxLat = bounds.northEastLat
        let fetchRequest: NSFetchRequest<Place> = Place.fetchRequest()
        let lngPredict = NSPredicate(format: "longitude >= %lf && longitude <= %lf", minLng, maxLng)
        let latPredict = NSPredicate(format: "latitude >= %lf && latitude <= %lf", minLat, maxLat)
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [lngPredict, latPredict])
        fetchRequest.returnsObjectsAsFaults = false
        return (try? mainContext.fetch(fetchRequest)) ?? []
    }
    
    func fetchAll() -> [Place] {
        let fetchRequest: NSFetchRequest<Place> = Place.fetchRequest()
        do {
            return try mainContext.fetch(fetchRequest)
        } catch {
            return []
        }
    }

    func delete(object: NSManagedObject, completionHandler: @escaping (Error?) -> Void) {
        mainContext.delete(object)
        do {
            try mainContext.save()
            completionHandler(nil)
        } catch {
            completionHandler(PlaceError.saveError)
        }
    }
    
    func deleteAll(completionHandler: @escaping (Error?) -> Void) {
        let request: NSFetchRequest<NSFetchRequestResult> = Place.fetchRequest()
        let delete = NSBatchDeleteRequest(fetchRequest: request)
        do {
            try self.mainContext.execute(delete)
            completionHandler(nil)
        } catch {
            completionHandler(PlaceError.batchDeleteError)
        }
    }
    
    func saveContext(completionHandler: @escaping (Error?) -> Void) {
        if mainContext.hasChanges {
            do {
                try mainContext.save()
                completionHandler(nil)
            } catch {
                completionHandler(PlaceError.saveError)
            }
        }
    }
    
    weak var fetchedResultsControllerDelegate: NSFetchedResultsControllerDelegate?
    
    lazy var fetchedResultsController: NSFetchedResultsController<Place> = {
        
        let fetchRequest: NSFetchRequest<Place> = Place.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                    managedObjectContext: mainContext,
                                                    sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = fetchedResultsControllerDelegate
        
        do {
            try controller.performFetch()
        } catch {
            fatalError("Unresolved error \(error)")
        }
        
        return controller
    }()
    
    var objectCount: Int {
        fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func resetAndRefetch() {
        mainContext.reset()
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Unresolved error \(error)")
        }
    }
}

extension PlaceProvider {
    enum Constant {
        static let persistentName = "NaverMapA"
        static let fileName = "restaurant_list"
    }
}
