//
//  HomeServiceTests.swift
//  ActivityListDataLayerTests
//
//  Created by Maksim Linich on 1.04.24.
//

import XCTest
import ActivityListDomain

final class HomeServiceTests: XCTestCase {
    fileprivate typealias SutType = HomeService<Int, ImageServiceStub>
    
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
        let sut = HomeService<Int, ImageServiceStub>(tasksListRepository: tasksListRepository, imageService: ImageServiceStub())

        trackMemoryLeak(sut, file: file, line: line)
        
        return (sut, tasksListRepository)
    }
}
