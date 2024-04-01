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
        
    }
    
    
}

final class HomeServiceTests: XCTestCase {
    func tests_init_shouldNotCalTasksListRepositoryMethods() {
        let tasksListRepository = TasksListRepositoryStub()
        let sut = HomeService(tasksListRepository: tasksListRepository)
        
        XCTAssertEqual(tasksListRepository.readQueryCount, 0, "Home service should not call read tasks lists method")
        XCTAssertEqual(tasksListRepository.insertQueryCount, 0, "Home service should not call insert tasks list method")
    }
    
    func test_readTasksInfo_returnsEmptyOnTasksList() {
        
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
