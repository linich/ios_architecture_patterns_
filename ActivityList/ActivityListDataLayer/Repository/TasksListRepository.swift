//
//  TaskListRepository.swift
//  ActivityListDataLayer
//
//  Created by Maksim Linich on 26.03.24.
//

import CoreData
import ActivityListDomain

public class TasksListRepository: TasksListRepositoryProtocol {
    
    private let context: NSManagedObjectContext
    public init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    public func readTasksLists(completion: @escaping (Result<[TasksListModel], Error>) -> Void) {
        context.perform {
            do {
                let fetchRequest = TasksList.fetchRequest()
                let result = try self.context.fetch<TasksList>(fetchRequest)
                
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
