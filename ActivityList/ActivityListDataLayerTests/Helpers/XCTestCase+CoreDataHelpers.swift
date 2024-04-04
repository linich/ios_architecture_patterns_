//
//  CoreData+StackCreationswift.swift
//  ActivityListDataLayerTests
//
//  Created by Maksim Linich on 2.04.24.
//

import XCTest
import ActivityListDataLayer
import CoreData

extension XCTestCase {
    
    static  var model: NSManagedObjectModel = {
        let bundle = Bundle(for: TasksListRepository.self)
        guard let modelURL = bundle.url(forResource: "ActivityList",
                                        withExtension: "momd") else {
            fatalError("Failed to find data model")
        }
        
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Failed to create model from file: \(modelURL)")
        }
        return model
    }()
    
    var documentDirectory: URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    
    func generateTempFileURL() -> URL {
        let uuid = UUID()
        guard let url = URL(string: "\(uuid.uuidString).sqlite", relativeTo: documentDirectory) else {
            fatalError("Failed to create store url")
        }
        return url
    }
    
    func createPersistanceStoreCoordinator(storeUrl: URL) -> NSPersistentStoreCoordinator {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: XCTestCase.model)
        do {
            _ = try coordinator.addPersistentStore(
                type: .inMemory,
                at: storeUrl,
                options: nil)
        } catch {
            fatalError("Failed to add persistent store: \(error.localizedDescription)")
        }
        
        return coordinator
    }
}
