//
//  HomeServiceTests.swift
//  ActivityListDataLayerTests
//
//  Created by Maksim Linich on 1.04.24.
//

import XCTest
import ActivityListDomain

final class HomeServiceTests: XCTestCase {
    
    func tests_init_shouldNotCalTasksListRepositoryMethods() {
        let (_, tasksListRepository) = makeSUT()
        
        XCTAssertEqual(tasksListRepository.readQueryCount, 0, "Home service should not call read tasks lists method")
        XCTAssertEqual(tasksListRepository.insertQueryCount, 0, "Home service should not call insert task list method")
    }
    
    func test_readTasksInfo_returnsEmptyTasksInfosOnEmptyTasksList() {
        let (sut, repositoryStub) = makeSUT()
        
        assert(sut, receive: [], onAction: {repositoryStub.completeReadTasksList(withTasks: [])})
    }
    
    func test_readTasksInfo_returnsTasksListInfoOnNonEmptyTasksList() {
        let (sut, repositoryStub) = makeSUT()
        
        let tasksListModel1 = makeTasksList(name: "Name1")
        let expectedTasksInfos = [
            makeTasksListInfo(name: tasksListModel1.name, id: tasksListModel1.id)
        ]
        
        assert(sut, receive: expectedTasksInfos, onAction: {repositoryStub.completeReadTasksList(withTasks: [tasksListModel1])})
    }
    
    func test_readTasksInfo_returnsErrorWhenReceiveErrorFromRepository() {
        let (sut, repositoryStub) = makeSUT()
                
        assert(sut, receiveError: HomeService.Error.ReadFromRepository) {
            repositoryStub.completeReadTasksList(withError: anyNSError())
        }
    }
    
    // Mark: - Helpers
    
    fileprivate func assert(_ sut: HomeService, receive expectedTasksInfos: [TasksListInfo], onAction action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Loading tasks list infos")
        Task(operation: {
            defer { exp.fulfill() }
            do {
                async let task = sut.readTasksInfos()
                let items = try await task
                XCTAssertEqual(items, expectedTasksInfos, "Expected to receive tasks", file: file, line: line)
            }
            catch {
                XCTFail("Expect list of tasks, but go \(error)", file: file, line: line)
            }
        })
        RunLoop.current.runForDistanceFuture()
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    fileprivate func assert(_ sut: HomeService, receiveError expectedError: HomeService.Error, onAction action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Loading tasks list infos")
        let createTaskExpectation = expectation(description: "Creating read tasks task")
        Task.detached(operation: {
            defer { exp.fulfill() }
            do {
                async let task = sut.readTasksInfos()
                createTaskExpectation.fulfill()
                let items = try await task
                XCTFail("Expect to get error, but got \(items)")
                
            }
            catch {
                guard let homeError = error as? HomeService.Error else {
                    XCTFail("Expect to get error HomeService.Error, but got \(error)")
                    return
                }
                XCTAssertEqual(homeError, expectedError)
            }
        })
        
        wait(for: [createTaskExpectation], timeout: 1.0)
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    
    fileprivate func makeSUT( file: StaticString = #filePath, line: UInt = #line) -> (HomeService, TasksListRepositoryStub) {
        let tasksListRepository = TasksListRepositoryStub()
        let sut = HomeService(tasksListRepository: tasksListRepository)

        trackMemoryLeak(sut, file: file, line: line)
        
        return (sut, tasksListRepository)
    }
}

fileprivate class TasksListRepositoryStub: TasksListRepositoryProtocol {
    private var readTasksInfosRequests = [CompletionHolder<Result<[TasksListModel], Error>>]()
    
    private var insertQuery = [InsertionCompletion]()
    
    public var readQueryCount: Int {
        return readTasksInfosRequests.count
    }
    
    public var insertQueryCount: Int {
        return insertQuery.count
    }

    public func completeReadTasksList(withTasks tasks: [TasksListModel], at index: Int = 0) -> Void {
        readTasksInfosRequests[index].completion?(.success(tasks))
    }
    
    public func completeReadTasksList(withError error: Error, at index: Int = 0) -> Void {
        readTasksInfosRequests[index].completion?(.failure(error))
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
    
    func insertTasksList(withId: UUID, name: String, type: ActivityListDomain.TasksListModel.TasksListType, completion: @escaping InsertionCompletion) {
        self.insertQuery.append(completion)
    }
}
