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
    
    func readTasksLists(completion: @escaping Completion) {
        readTasksListsRequests.append(completion)
    }
    
    func completeReadTasksLists(with tasksLists: [TasksListModel], at:Int = 0) {
        readTasksListsRequests[at](.success(tasksLists))
    }
    
    private var readTasksListsRequests: [Completion] = []
    
}

final class HomeViewControllerTests: XCTestCase {
    
    func test_loadTasksLists_requestTasksListFromRepository() {
        let (sut, repository) = createSUT()
        
        XCTAssertEqual(repository.readTasksListCount, 0, "Expected no loading requests before view is loaded")
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(repository.readTasksListCount, 1, "Expected loading request once view is loaded")
    }
    
    func test_loadTasksListCompletion_renderSuccessufullyLoadedTasksLists() {
        
        let tasksList1 = TasksListModel(id: UUID(), name: "name1", createdDate: Date.now, icon: "icon1")
        let tasksList2 = TasksListModel(id: UUID(), name: "name2", createdDate: Date.now, icon: "icon2")
        let tasksList3 = TasksListModel(id: UUID(), name: "name3", createdDate: Date.now, icon: "icon3")
        
        let (sut, repository) = createSUT()
        sut.loadViewIfNeeded()
        
        repository.completeReadTasksLists(with: [tasksList1, tasksList2, tasksList3])
        
        XCTAssertEqual(sut.homeView.tasksLists, [tasksList1, tasksList2, tasksList3])
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

extension TasksListModel: Equatable {
    public static func == (lhs: TasksListModel, rhs: TasksListModel) -> Bool {
        return lhs.id == rhs.id &&
        lhs.icon == rhs.icon &&
        lhs.createdDate == rhs.createdDate &&
        lhs.name == rhs.name
    }
    
    
}
