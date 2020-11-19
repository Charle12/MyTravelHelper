//
//  CoreDataManager.swift
//  MyTravelHelper
//
//  Created by Prabhat Pandey on 19/11/2020.
//  Copyright © 2020 Prabhat Pandey. All rights reserved.
//

import CoreData
import UIKit

class CoreDataManager {
    /*
     * CompletionHandler: for handling success and faliure case.
     */
    typealias CompletionHandler = (_ success: Bool, _ error: String, _ result: [String]) -> Void
    
    /*
     * We are creating a static let, so that sharedManager have same instance and can not be changed.
     */
    static let sharedManager = CoreDataManager()
    
    /*
     * Prevent clients from creating another instance.
     * Using private keyword, so that this class can not be initialize mistakenly. If at some place you will try to initialize it again you will get compile time error.
     */
    
    private init() {}
    
    /*
     * Initializing NSPersistentContainer.
     * Initializing core data stack lazily. persistentContainer object will be initialized only when it's' needed.
     */
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: coreDataStack.DATABASE_NAME)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    /*
     * Save context method will save our uncommitted changes in core data store.
     */
    
    func saveContext () {
        let context = CoreDataManager.sharedManager.persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    /*
     * Convert NSManagedObject in to Json Array.
     * Convert Json array into Model
     */
    
    func convertToJSONArray(moArray: [NSManagedObject]) -> [String] {
        var models: [String] = []
        for item in moArray {
            for attribute in item.entity.attributesByName {
                //check if value is present, then add key to dictionary so as to avoid the nil value crash
                if let value = item.value(forKey: attribute.key) {
                    models.append((value as? String)!)
                }
            }
        }
        return models
    }
    
    /*
     * Retrieve All user information from table.
     */
    
    func fetchAllSavedInformationFromDB(completionHandler: CompletionHandler) {
        var people = [NSManagedObject]()
        let managedContext = CoreDataManager.sharedManager.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: coreDataStack.TABLE_NAME)
        do {
            people = try managedContext.fetch(fetchRequest)
            completionHandler(true, "Fetched all record", convertToJSONArray(moArray: people))
        } catch let error as NSError {
            completionHandler(false, "Could not fetch. \(error), \(error.userInfo)", [])
        }
    }
    
    /*
     * Save singel user information in table.
     */
    
    func saveStationNameInEntity(stationName: String, completionHandler: CompletionHandler)  {
        let managedContext = CoreDataManager.sharedManager.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: coreDataStack.TABLE_NAME, in: managedContext)!
        let station = NSManagedObject(entity: entity, insertInto: managedContext)
        station.setValue(stationName, forKeyPath: dbKey.KEY_NAME)
        do {
            try managedContext.save()
            completionHandler(true, "Station name added in favourite list.", [])
        } catch let error as NSError {
            completionHandler(false, "Could not save. \(error), \(error.userInfo)", [])
        }
    }
    
    func removeStationNameInEntity(stationName: String, completionHandler: CompletionHandler) {
         let managedContext = CoreDataManager.sharedManager.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: coreDataStack.TABLE_NAME)
        fetchRequest.predicate = NSPredicate(format: "stationName = %@", stationName)
        do {
            let test = try managedContext.fetch(fetchRequest)
            let objectToDelete = test[0] as! NSManagedObject
            managedContext.delete(objectToDelete)
            do {
                try managedContext.save()
                completionHandler(true, "Station name removed in favourite list.", [])
            }
            catch let error as NSError {
                completionHandler(false, "Could not save. \(error), \(error.userInfo)", [])
            }
        } catch let error as NSError {
            completionHandler(false, "Could not save. \(error), \(error.userInfo)", [])
        }
    }
}
