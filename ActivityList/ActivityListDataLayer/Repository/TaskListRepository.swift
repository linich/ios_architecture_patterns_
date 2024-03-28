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
    
    public func readTasksLists(completion: @escaping (Result<[TasksListModel], Error>) -> Void) {
        viewContext.perform {
            do {
                let fetchRequest = TasksList.fetchRequest()
                let result = try self.viewContext.fetch<TasksList>(fetchRequest)
                
                let tasksList = result.map {$0.toModel()}.compactMap{$0}
                
                completion(.success(tasksList))
                
            } catch {
                completion(.failure(error))
            }
        }
    }
}

extension TasksList {
    func toModel() -> TasksListModel? {
        guard let stringId = id,
              let id = UUID(uuidString: stringId),
                let name = name,
              let createdAt = createdAt, let icon = icon else {
            return nil as TasksListModel?
        }
        let tasks = tasks.map { tasks in
            tasks.map{($0 as! Task).toModel()}.compactMap({$0})
        } ?? []
        return TasksListModel(id: id, name: name, createdAt: createdAt, type: tasksListType(byIcon: icon), tasks: tasks)
    }
    
    func tasksListType(byIcon icon: String) -> TasksListModel.TasksListType {
        switch icon {
        default:
            return .none
        }
    }
}

extension Task {
    func toModel() -> TaskModel? {
        guard let stringId = id,
              let id = UUID(uuidString: stringId),
                let name = name,
              let createdAt = createdAt, let icon = icon else {
            return nil as TaskModel?
        }
        
        return TaskModel(id: id, name: name, createdAt: createdAt, type: taskType(byIcon: icon))
    }
    
    func taskType(byIcon icon: String) -> TaskModel.TaskType {
        switch icon {
        default:
            return .none
        }
    }
}
