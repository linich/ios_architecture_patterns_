//
//  TaskListRepository.swift
//  ActivityListDataLayer
//
//  Created by Maksim Linich on 26.03.24.
//

import CoreData
import ActivityListDomain

public class TasksListRepository: TasksListRepositoryProtocol {
    public func insertTasksList(withId id:UUID, name: String, type: ActivityListDomain.TasksListModel.TasksListType, completion: @escaping (InsertionResult) -> Void) {
        let currentDate = self.currentDate
        let context = self.context
        context.perform {
            completion(Swift.Result {
                let tasksList = TasksList(context: context)
                tasksList.id = id.uuidString
                tasksList.createdAt = currentDate()
                tasksList.name = name
                tasksList.tasksListType = TasksList.getTasksListType(by: type)
                try context.save()
                return ()
            })
        }
        
    }
    
    
    private let context: NSManagedObjectContext
    private let currentDate: () -> Date
    public init(
        context: NSManagedObjectContext,
        currentDate: @escaping  () -> Date
    ) {
        self.context = context
        self.currentDate = currentDate
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
              let createdAt = createdAt, let type = tasksListType else {
            return nil as TasksListModel?
        }
        let tasks = tasks.map { tasks in
            tasks.map{($0 as! Task).toModel()}.compactMap({$0})
        } ?? []
        return TasksListModel(id: id, name: name, createdAt: createdAt, type: TasksList.tasksListType(byType: type), tasks: tasks)
    }
    
    static func tasksListType(byType type: String) -> TasksListModel.TasksListType {
        switch type {
        case "airplane":
            return .airplane
        default:
            return .none
        }
    }
    
    static func getTasksListType(by type: TasksListModel.TasksListType) -> String {
        switch type {
        case .airplane:
            return "airplane"
        default:
            return "none"
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
        
        return TaskModel(id: id, name: name, createdAt: createdAt, type: Task.taskType(byType: icon))
    }
    
    static func taskType(byType type: String) -> TaskModel.TaskType {
        switch type {
        default:
            return .none
        }
    }
}
