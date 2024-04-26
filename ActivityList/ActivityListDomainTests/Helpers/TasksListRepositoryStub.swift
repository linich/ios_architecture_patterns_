//
//  TasksListRepositoryStub.swift
//  ActivityListDomainTests
//
//  Created by Maksim Linich on 26.04.24.
//

import ActivityListDomain

internal class TasksListRepositoryStub: TasksListRepositoryProtocol {

    private var readTasksInfosRequests = [CompletionHolder<Result<[TasksListModel], Error>>]()
    private var readTaskItemsCountRequests = [CompletionHolder<Result<[UUID: Int], Error>>]()
    private var insertQuery = [CompletionHolder<Result<(), Error>>]()
    
    public var readTaskItemsCountCallCount: Int {
        return readTaskItemsCountRequests.count
    }
    public var readQueryCallCount: Int {
        return readTasksInfosRequests.count
    }
    
    public var insertQueryCallCount: Int {
        return insertQuery.count
    }
    
    public func completeReadTasksCount(withTasksCount tasksCout: [UUID: Int], at index: Int = 0) -> Void {
        readTaskItemsCountRequests[index].completion?(.success(tasksCout))
    }
    
    public func completeReadTasksList(withTasks tasks: [TasksListModel], at index: Int = 0) -> Void {
        readTasksInfosRequests[index].completion?(.success(tasks))
    }
    
    public func completeReadTasksList(withError error: Error, at index: Int = 0) -> Void {
        readTasksInfosRequests[index].completion?(.failure(error))
    }
    
    public func readTaskItemsCount(forTasksListsWithIds: [UUID]) async throws -> [UUID : Int] {
        let completion = CompletionHolder<Result<[UUID : Int], Error>>( completion: nil)
        readTaskItemsCountRequests.append(completion)
        
        return try await withCheckedThrowingContinuation { continuation in
            completion.completion =  { result in
                switch result {
                case let .success(items):
                    continuation.resume(returning:items)
                case let .failure(error):
                    continuation.resume(throwing: error)
                }
                
            }
        }
    }

    func readTasksLists() async throws -> [TasksListModel] {
        let completion = CompletionHolder<Result<[TasksListModel], Error>>( completion: nil)
        self.readTasksInfosRequests.append(completion)
        
        return try await withCheckedThrowingContinuation { continuation in
            completion.completion =  { result in
                switch result {
                case let .success(items):
                    continuation.resume(returning:items)
                case let .failure(error):
                    continuation.resume(throwing: error)
                }
                
            }
        }
    }
    
    func insertTasksList(withId: UUID, name: String, createdAt: Date, type: ActivityListDomain.TasksListModel.TasksListType) async throws {
        let completionHolder = CompletionHolder<Result<(), Error>>( completion: nil)
        self.insertQuery.append(completionHolder)
        return try await withCheckingContinuation(completionHolder:completionHolder)
    }
    
    func withCheckingContinuation<T>(completionHolder: CompletionHolder<Result<T, Error>>) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            completionHolder.completion =  { result in
                switch result {
                case .success:
                    continuation.resume(returning: ())
                case let .failure(error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
