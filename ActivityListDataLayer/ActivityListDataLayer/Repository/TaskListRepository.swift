//
//  TaskListRepository.swift
//  ActivityListDataLayer
//
//  Created by Maksim Linich on 25.03.24.
//

import ActivityListDomain
import CoreData

public class TaskListRepository: TaskRepositoryProtocol {
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ActivityList")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Unable to load model \(error)")
            }
        }
        return container
    }()
    
    lazy var viewContext: NSManagedObjectContext = {
        return persistentContainer.viewContext
    }()
    
    
    public init() {
        
    }
    
    public func readTasks(completion: @escaping (Result<[ActivityListDomain.TaskListModel], Error>) -> Void) {
        viewContext.perform {
            do {
                let fetchRequest = TaskList.fetchRequest()
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
