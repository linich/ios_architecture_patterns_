//
//  TaskItemsServiceTests.swift
//  ActivityListDomainTests
//
//  Created by Maksim Linich on 26.04.24.
//

import XCTest
import ActivityListDomain

struct TaskItemsService<Image>: TaskItemsServiceProtocol {
    private let taskListId: UUID
    public init(taskListId: UUID) {
        self.taskListId = taskListId
    }
    
    func readTaskItems() async -> [ActivityListDomain.TaskItemInfo<Image>] {
        return []
    }
}

fileprivate final class TasksItemsServiceTests: XCTestCase {
    func tests_init_shouldNotCalTasksListRepositoryMethods() {
        let (sut, stub, imageStub) = makeSUT()
        
        XCTAssertEqual(stub.readTasksOfTasksListCallCount, 0, "Service should not call read tasks of tasks list method")
        XCTAssertEqual(stub.insertTaskRequestCallCount, 0, "Service should not call insert task method")
    }
    
    //Mark: - Helpers
    
    func makeSUT(taskListId: UUID = UUID(), file: StaticString = #file, line: UInt = #line) -> (TaskItemsService<Int>, TaskItemsRepositoryStub, ImageServiceStub){
        let sut = TaskItemsService<Int>(taskListId: taskListId)
        let stub = TaskItemsRepositoryStub()
        let imageStub = ImageServiceStub()
        
        trackMemoryLeak(stub)
        trackMemoryLeak(imageStub)
        
        return ( sut, stub, imageStub)
    }
}

fileprivate class TaskItemsRepositoryStub: TaskItemRepositoryProtocol {
    private var readTasksOfTasksListRequests = [CompletionHolder<Result<[TaskModel], Error>>]()
    private var insertTaskRequests = [CompletionHolder<Result<(), Error>>]()
    
    public var readTasksOfTasksListCallCount: Int { return readTasksOfTasksListRequests.count }
    public var insertTaskRequestCallCount: Int { return insertTaskRequests.count }
    
    func readTasksOfTasksList(withId tasksListId: UUID) async throws -> [TaskModel] {
        let completionHolder = CompletionHolder<Result<[TaskModel], Error>>(completion: nil)
        readTasksOfTasksListRequests.append(completionHolder)
        
        return try await withCheckedThrowingContinuation { continuation in
            completionHolder.completion =  { result in
                switch result {
                case let .success(items):
                    continuation.resume(returning:items)
                case let .failure(error):
                    continuation.resume(throwing: error)
                }
                
            }
        }
    }
    
    func insert(task: TaskModel, tasksListId: UUID) async throws {
        let completionHolder = CompletionHolder<Result<(), Error>>(completion: nil)
        insertTaskRequests.append(completionHolder)
        
        return try await withCheckedThrowingContinuation { continuation in
            completionHolder.completion =  { result in
                switch result {
                case let .success(items):
                    continuation.resume(returning:())
                case let .failure(error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
