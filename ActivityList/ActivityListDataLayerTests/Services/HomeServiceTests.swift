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
    
    func test_readTasksInfo_returnsEmptyOnTasksList() {
        let (sut, repositoryStub) = makeSUT()
        
        assert(sut, receive: [], onAction: {repositoryStub.completeReadTasksList(withTasks: [])})
        
    }
    
    func test_readTasksInfo_returnsTasksListInfoOnNonEmptyTasksList() {
        let (sut, repositoryStub) = makeSUT()
        
        let tasksListModel1 = makeTasksList(name: "Name1")
        let expectedTasksInfos = [
            TasksListInfo(
                id: tasksListModel1.id,
                name: tasksListModel1.name,
                type: tasksListModel1.type,
                tasksCount: 0)
        ]
        
        assert(sut, receive: expectedTasksInfos, onAction: {repositoryStub.completeReadTasksList(withTasks: [tasksListModel1])})
    }
    
    func test_readTasksInfo_returnsErrorWhenReceiveErrorFromRepository() {
        let (sut, repositoryStub) = makeSUT()
        
        let tasksListModel1 = makeTasksList(name: "Name1")
        let expectedTasksInfos = [
            TasksListInfo(
                id: tasksListModel1.id,
                name: tasksListModel1.name,
                type: tasksListModel1.type,
                tasksCount: 0)
        ]
        
        assert(sut, receiveError: HomeService.Error.ReadTaskFromRepository) {
            repositoryStub.completeReadTasksList(withError: anyNSError())
        }
    }
    
    // Mark: - Helpers
    
    fileprivate func assert(_ sut: HomeService, receive expectedTasksInfos: [TasksListInfo], onAction action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Loading tasks list infos")
        let createTaskExpectation = expectation(description: "Creating read tasks task")
        Task.detached(operation: {
            defer { exp.fulfill() }
            do {
                async let task = sut.readTasksInfos()
                createTaskExpectation.fulfill()
                let items = try await task
                XCTAssertEqual(items, expectedTasksInfos, "Expected to receive tasks")
            }
            catch {
                XCTFail("Expect list of tasks, but go \(error)")
            }
        })
        
        wait(for: [createTaskExpectation], timeout: 1.0)
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
    private var readQuery = [ReadCompletion]()
    private var insertQuery = [InsertionCompletion]()
    
    public var readQueryCount: Int {
        return readQuery.count
    }
    
    public var insertQueryCount: Int {
        return insertQuery.count
    }

    public func completeReadTasksList(withTasks tasks: [TasksListModel], at index: Int = 0) -> Void {
        readQuery[index](.success(tasks))
    }
    
    public func completeReadTasksList(withError error: Error, at index: Int = 0) -> Void {
        readQuery[index](.failure(error))
    }
    
    func readTasksLists(completion: @escaping ReadCompletion) -> Void {
        self.readQuery.append(completion)
    }
    
    func insertTasksList(withId: UUID, name: String, type: ActivityListDomain.TasksListModel.TasksListType, completion: @escaping InsertionCompletion) {
        self.insertQuery.append(completion)
    }
}
