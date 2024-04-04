//
//  TaskItemRepository.swift
//  ActivityListDataLayer
//
//  Created by Maksim Linich on 4.04.24.
//

import Foundation
import ActivityListDomain
import CoreData

public enum TaskItemRepositoryError: Error {
    case ReadTaskItems(Error)
    case InsertTaskItem(Error)
}

public class TaskItemRepository: TaskItemRepositoryProtocol {
    private let context: NSManagedObjectContext
    
    public init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    public func readTasksOfTasksList(withId tasksListId: UUID) async throws -> [TaskModel] {
        do {
            return try await withCheckedThrowingContinuation { continuation in
                self.context.perform {
                    let taskItemsRequest = TaskItem.fetchRequest()
                    taskItemsRequest.predicate = NSPredicate(format: "%K.id == %@", #keyPath(TaskItem.taskList), tasksListId.uuidString as CVarArg)
                    do {
                        let result = try self.context.fetch(taskItemsRequest)
                        let taskItems = result.map({ $0.toModel()}).compactMap({$0})
                        continuation.resume(returning: taskItems)
                    } catch {
                        continuation.resume(throwing: TaskItemRepositoryError.ReadTaskItems(error))
                    }
                }
            }
        } catch {
            throw error
        }
    }
    
    public func insert(task: TaskModel, tasksListId: UUID) async throws -> Void {
        do {
            return try await withCheckedThrowingContinuation { continuation in
                self.context.perform {
                    let tasksListRequest = TasksList.fetchRequest()
                    tasksListRequest.predicate  = NSPredicate(format: "id == %@", tasksListId.uuidString as CVarArg)
                    var tasksList: TasksList? = nil
                    do {
                        tasksList = try self.context.fetch(tasksListRequest).first
                    } catch {
                        continuation.resume(throwing: TaskItemRepositoryError.ReadTaskItems(error))
                    }
                    
                    let taskItem = TaskItem.from(model: task, tasksList: tasksList, inContext: self.context)
                    
                    do {
                        try self.context.save()
                        continuation.resume(returning: ())
                    } catch {
                        continuation.resume(throwing: TaskItemRepositoryError.InsertTaskItem(error as NSError))
                    }
                }
            }
        } catch {
            throw error
        }
    }
}

extension TaskItem {
    func toModel() -> TaskModel? {
        guard
            let itemId = id,
            let name = name,
            let id = UUID(uuidString: itemId),
            let createdAt = createdAt,
            let type = ActivityTypeInner(rawValue: taskType)?.toDomainType() else {
            return nil
        }
        return TaskModel(id: id, name: name, createdAt: createdAt, type: type)
    }
    
    static func from(model: TaskModel, tasksList: TasksList?, inContext context: NSManagedObjectContext) -> TaskItem {
        let taskItem = TaskItem(context: context)
        
        taskItem.id = model.id.uuidString
        taskItem.name = model.name
        taskItem.createdAt = model.createdAt
        taskItem.taskType = ActivityTypeInner.from(activityType: model.type).rawValue
        taskItem.taskList = tasksList
        return taskItem
    }
}
