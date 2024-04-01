//
//  HomeServiceTests.swift
//  ActivityListDataLayerTests
//
//  Created by Maksim Linich on 1.04.24.
//

import XCTest
import ActivityListDomain

class HomeService: HomeServiceProtocol {
    
    private let tasksListRepository: TasksListRepositoryProtocol
    init(tasksListRepository: TasksListRepositoryProtocol) {
        self.tasksListRepository = tasksListRepository
    }
    
    func readTasksInfos(completion: @escaping HomeService.Completion) {
        tasksListRepository.readTasksLists { result in
            switch result {
            case let .success(tasks):
                completion(.success(tasks.map({TasksListInfo(id: $0.id, name: $0.name, type: $0.type, tasksCount: 0)})))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}

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
    
    
    // Mark: - Helpers
    
    fileprivate func assert(_ sut: HomeService, receive expectedTasksInfos: [TasksListInfo], onAction action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Loading tasks list infos")
        sut.readTasksInfos { result in
            switch result {
            case let .success(items):
                XCTAssertEqual(items, expectedTasksInfos, "Expected to receive tasks")
            default:
                XCTFail("Expected \([TasksListInfo].self), but got \(result) instead")
            }
            exp.fulfill()
        }
        
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
    
    func readTasksLists(completion: @escaping ReadCompletion) -> Void {
        self.readQuery.append(completion)
    }
    
    func insertTasksList(withId: UUID, name: String, type: ActivityListDomain.TasksListModel.TasksListType, completion: @escaping InsertionCompletion) {
        self.insertQuery.append(completion)
    }
}

extension TasksListInfo: Equatable {
    public static func == (lhs: TasksListInfo, rhs: TasksListInfo) -> Bool {
        return lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.type == rhs.type &&
        lhs.tasksCount == rhs.tasksCount
    }
    
    
}
