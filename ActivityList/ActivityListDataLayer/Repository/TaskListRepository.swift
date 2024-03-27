//
//  TaskListRepository.swift
//  ActivityListDataLayer
//
//  Created by Maksim Linich on 26.03.24.
//

import CoreData
import ActivityListDomain

public class TaskListRepository: TasksListRepositoryProtocol {
    
    lazy var persistentCoordinator: NSPersistentStoreCoordinator = {
        let bundle = Bundle(for: TaskListRepository.self)
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
            _ = try coordinator.addPersistentStore(type: .sqlite, at: self.fileUrl,
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
    
    private let fileUrl: URL
    public init(fileUrl: URL) {
        self.fileUrl = fileUrl
    }
    
    public func readTasksLists(completion: @escaping (Result<[TaskListModel], Error>) -> Void) {
        viewContext.perform {
            do {
                let fetchRequest = ToDoList.fetchRequest()
                let result = try self.viewContext.fetch<TaskList>(fetchRequest)
                let tasksList = result.map { taskList in
                    guard let stringId = taskList.id,
                          let id = UUID(uuidString: stringId),
                            let name = taskList.name,
                          let createdAt = taskList.createdAt, let icon = taskList.icon else {
                        return nil as TaskListModel?
                    }
                    return TaskListModel.init(id: id, name: name, createdDate: createdAt, icon: icon)
                }.compactMap{$0}
                
                completion(.success(tasksList))
                
            } catch {
                completion(.failure(error))
            }
        }
    }
}
