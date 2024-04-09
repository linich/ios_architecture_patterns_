//
//  HomeServiceTests.swift
//  ActivityListDataLayerTests
//
//  Created by Maksim Linich on 1.04.24.
//

import XCTest
import ActivityListDomain

final class HomeServiceTests: XCTestCase {
    fileprivate typealias SutType = HomeService<Int, IconImageProviderStub>
    func tests_init_shouldNotCalTasksListRepositoryMethods() {
        let (_, tasksListRepository) = makeSUT()
        
        XCTAssertEqual(tasksListRepository.readQueryCallCount, 0, "Home service should not call read tasks lists method")
        XCTAssertEqual(tasksListRepository.insertQueryCallCount, 0, "Home service should not call insert task list method")
        XCTAssertEqual(tasksListRepository.readTaskItemsCountCallCount, 0, "Home service should not call read task items count")
    }
    
    func test_readTasksInfo_returnsEmptyTasksInfosOnEmptyTasksList() {
        let (sut, repositoryStub) = makeSUT()
        
        assert(sut, receive: [], onActions: [{
            repositoryStub.completeReadTasksList(withTasks: [])
        },
         {
            repositoryStub.completeReadTasksCount(withTasksCount: [:])
         }])
    }
    
    func test_readTasksInfo_returnsTasksListInfoOnNonEmptyTasksList() {
        let (sut, repositoryStub) = makeSUT()
        
        let tasksListModel1 = makeTasksList(name: "Name1", tasksListType: .gym)
        let expectedTasksInfos = [
            makeTasksListInfo(name: tasksListModel1.name, tasksListType: .gym, id: tasksListModel1.id, tasksCount: 0, icon: ActivityType.gym.hashValue)
        ]
        
        assert(sut, receive: expectedTasksInfos, onActions: [
            { repositoryStub.completeReadTasksList(withTasks: [tasksListModel1]) },
            { repositoryStub.completeReadTasksCount(withTasksCount: [:]) }
        ])
    }
    
    func test_readTasksInfo_returnsErrorWhenReceiveErrorFromRepository() {
        let (sut, repositoryStub) = makeSUT()
                
        assert(sut, receiveError: SutType.Error.ReadFromRepository) {
            repositoryStub.completeReadTasksList(withError: anyNSError())
        }
    }
    
    func test_readTasksInfo_returnsTasksListInfoWithTasksCountInfo() {
        let (sut, repositoryStub) = makeSUT()
        
        let tasksListModel1 = makeTasksList(name: "Name1", tasksListType: .airplane)
        let tasksListModel2 = makeTasksList(name: "Name2", taskType: .baseball)
        
        let expectedTasksInfos = [
            makeTasksListInfo(name: tasksListModel1.name,tasksListType: tasksListModel1.type, id: tasksListModel1.id, tasksCount: 1, icon: tasksListModel1.type.hashValue),
            makeTasksListInfo(name: tasksListModel2.name,tasksListType: tasksListModel2.type, id: tasksListModel2.id, tasksCount: 3, icon: tasksListModel2.type.hashValue),
        ]
        
        assert(sut, receive: expectedTasksInfos, onActions: [
            { repositoryStub.completeReadTasksList(withTasks: [tasksListModel1, tasksListModel2]) },
            { repositoryStub.completeReadTasksCount(withTasksCount: [tasksListModel1.id: 1, tasksListModel2.id: 3]) }
        ])
    }
    
    // Mark: - Helpers
    
    fileprivate func assert(_ sut: SutType, receive expectedTasksInfos: [TasksListInfo<Int>], onAction action: @escaping() -> Void, file: StaticString = #filePath, line: UInt = #line) {
        assert(sut, receive: expectedTasksInfos, onActions: [action])
    }
    
    fileprivate func assert(_ sut: SutType, receive expectedTasksInfos: [TasksListInfo<Int>], onActions actions: [() -> Void], file: StaticString = #filePath, line: UInt = #line) {
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
        actions.forEach { action in
            action()
            RunLoop.current.runForDistanceFuture()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    fileprivate func assert(_ sut: SutType, receiveError expectedError: SutType.Error, onAction action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
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
                guard let homeError = error as? SutType.Error else {
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
    
    
    fileprivate func makeSUT( file: StaticString = #filePath, line: UInt = #line) -> (SutType, TasksListRepositoryStub) {
        let tasksListRepository = TasksListRepositoryStub()
        let sut = HomeService<Int, IconImageProviderStub>(tasksListRepository: tasksListRepository, imageProvider: IconImageProviderStub())

        trackMemoryLeak(sut, file: file, line: line)
        
        return (sut, tasksListRepository)
    }
}

fileprivate class TasksListRepositoryStub: TasksListRepositoryProtocol {

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


fileprivate class IconImageProviderStub: ImageProviderProtocol {
    typealias Image = Int
    typealias ImageKind = ActivityType
    
    func getImage(byKind kind: ActivityType) -> Int {
        return kind.hashValue
    }
}
