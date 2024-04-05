//
//  TaskListRepository.swift
//  ActivityListDataLayer
//
//  Created by Maksim Linich on 26.03.24.
//

import CoreData
import ActivityListDomain

public enum TasksListRepositoryError: Error {
    case ReadTasksLists
}

public class TasksListRepository: TasksListRepositoryProtocol {
    private let context: NSManagedObjectContext
    
    public init(context: NSManagedObjectContext) {
        self.context = context
    }
        
    public func readTasksLists() async throws -> [TasksListModel] {
        do {
            let items = try await withCheckedThrowingContinuation({continuation in
                self.readTasksLists { result in
                    switch result {
                    case let .success(items):
                        continuation.resume(returning: items)
                    case let .failure(error):
                        continuation.resume(throwing: error)
                    }
                }
            })
            
            return items
        } catch {
            throw TasksListRepositoryError.ReadTasksLists
        }
    }
    
    public func insertTasksList(withId id: UUID, name: String, createdAt: Date, type: ActivityListDomain.TasksListModel.TasksListType) async throws -> Void {
        do {
            try await withCheckedThrowingContinuation({continuation in
                self.insertTasksList(withId: id, name: name, createdAt: createdAt, type: type) { result in
                    switch result {
                    case let .success(data):
                        continuation.resume(returning: data)
                    case let .failure(error):
                        continuation.resume(throwing: error)
                    }
                }
            })
        } catch {
            throw TasksListRepositoryError.ReadTasksLists
        }
    }

    private func readTasksLists(completion: @escaping (Result<[TasksListModel], Error>) -> Void) {
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
    
    private func insertTasksList(withId id: UUID, name: String, createdAt: Date, type: ActivityListDomain.TasksListModel.TasksListType, completion: @escaping (Result<Void, Error>) -> Void) {
        let context = self.context
        context.perform {
            completion(Swift.Result {
                let tasksList = TasksList(context: context)
                tasksList.id = id.uuidString
                tasksList.createdAt = createdAt
                tasksList.name = name
                tasksList.tasksListType = ActivityTypeInner.from(activityType: type).rawValue
                try context.save()
                return ()
            })
        }
    }
}

extension TasksList {
    func toModel() -> TasksListModel? {
        // ToDo Should it fail in case invalid data? Will it be better to send log
        guard let stringId = id,
              let id = UUID(uuidString: stringId),
              let name = name,
              let type = ActivityTypeInner.init(rawValue: tasksListType)?.toDomainType(),
              let createdAt = createdAt else {
            return nil as TasksListModel?
        }
        return TasksListModel(id: id, name: name, createdAt: createdAt, type: type)
    }
}
