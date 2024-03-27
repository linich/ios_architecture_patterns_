//
//  ActivityListUITests.swift
//  ActivityListUITests
//
//  Created by Maksim Linich on 25.03.24.
//

import XCTest
import ActivityListDomain
import ActivityListUI


private class TasksListRepositoryStub: TasksListRepositoryProtocol {
    typealias Completion = (TasksListRepositoryProtocol.Result) -> Void
    
    public var readTasksListCount: Int {
        return readTasksListsRequests.count
    }
    
    private var readTasksListsRequests: [Completion] = []
    
    func readTasksLists(completion: @escaping Completion) {
        readTasksListsRequests.append(completion)
    }
}

final class HomeViewControllerTests: XCTestCase {
    
    func test_loadTasksLists_requestTasksListFromRepository() {
        let (sut, repository) = createSUT()
        
        XCTAssertEqual(repository.readTasksListCount, 0, "Expected no loading requests before view is loaded")
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(repository.readTasksListCount, 1, "Expected loading request once view is loaded")
    }
    
    fileprivate func createSUT(file: StaticString = #filePath, line: UInt = #line) -> (HomeViewController, TasksListRepositoryStub) {
        let stub = TasksListRepositoryStub()
        let homeController = HomeViewController.init(taskListRepository: stub)
        self.trackMemoryLeak(homeController, file: file, line: line)
        
        return (homeController, stub)
    }
    
    fileprivate func trackMemoryLeak(_ object: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        self.addTeardownBlock { [weak object] in
            XCTAssertNil(object, file: file, line: line)
        }
    }
}
