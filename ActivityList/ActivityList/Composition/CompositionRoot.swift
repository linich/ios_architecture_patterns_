//
//  CompositionRoot.swift
//  ActivityList
//
//  Created by Maksim Linich on 26.03.24.
//

import Foundation
import ActivityListUI
import ActivityListDataLayer
import ActivityListDomain
import CoreData

internal class CompositionRoot {
    lazy var persistentCoordinator: NSPersistentStoreCoordinator = {
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
            // Set the options to enable lightweight data migrations.
            let options = [NSMigratePersistentStoresAutomaticallyOption: true,
                                 NSInferMappingModelAutomaticallyOption: true]
            // Add the store to the coordinator.
            _ = try coordinator.addPersistentStore(type: .sqlite, at: self.coreDataStoreUrl,
                                               options: options)
        } catch {
            fatalError("Failed to add persistent store: \(error.localizedDescription)")
        }
        
        return coordinator
    }()
    
    lazy var viewContext: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = persistentCoordinator
        return context
    }()

    public init(){
        
    }
    
    var home: HomeViewController {
        return HomeViewController(homeService: homeService)
    }
    
    var taskListRepository: TasksListRepositoryProtocol {
        return TasksListRepository(context: viewContext)
    }
    
    var homeService: HomeServiceProtocol {
        return HomeService(tasksListRepository: taskListRepository)
    }
    
    var coreDataStoreUrl: URL {
        guard let url = URL(string: "ActivityList.sqlite", relativeTo: documentDirectory) else {
            fatalError("Failed to create store url")
        }
        return url
    }
    
    var documentDirectory: URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
}
