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
    
    func readTasksInfos(completion: HomeServiceProtocol.Completion) {
        completion(.success([]))
    }
    
    
}

final class HomeServiceTests: XCTestCase {
    
    func tests_init_shouldNotCalTasksListRepositoryMethods() {
        let (_, tasksListRepository) = makeSUT()
        
        XCTAssertEqual(tasksListRepository.readQueryCount, 0, "Home service should not call read tasks lists method")
        XCTAssertEqual(tasksListRepository.insertQueryCount, 0, "Home service should not call insert task list method")
    }
    
    func test_readTasksInfo_returnsEmptyOnTasksList() {
        let (sut, repository) = makeSUT()
        
        let exp = expectation(description: "Loading tasks list infos")
        var tasksInfos: [TasksListInfo]? = nil
        sut.readTasksInfos { result in
            switch result {
            case let .success(items):
                tasksInfos = items
            default:
                XCTFail("Expected \([TasksListInfo].self), but got \(result) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(tasksInfos?.count, 0, "Tasks infos list should be empty on empty tasks list")
    }
    
    // Mark: - Helpers
    
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

    func readTasksLists(completion: @escaping ReadCompletion) -> Void {
        self.readQuery.append(completion)
    }
    
    func insertTasksList(withId: UUID, name: String, type: ActivityListDomain.TasksListModel.TasksListType, completion: @escaping InsertionCompletion) {
        self.insertQuery.append(completion)
    }
    
    
}
