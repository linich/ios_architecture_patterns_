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
    func createPersistanceStoreCoordinator(storeUrl: URL) -> NSPersistentStoreCoordinator {
        
        let bundle = Bundle(for: TasksListRepository.self)
        guard let modelURL = bundle.url(forResource: "ActivityList",
                                        withExtension: "momd") else {
            fatalError("Failed to find data model")
        }
        
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Failed to create model from file: \(modelURL)")
        }
        
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        do {
            _ = try coordinator.addPersistentStore(
                type: .sqlite,
                at: storeUrl,
                options: nil)
        } catch {
            fatalError("Failed to add persistent store: \(error.localizedDescription)")
        }
        
        return coordinator
    }
}
