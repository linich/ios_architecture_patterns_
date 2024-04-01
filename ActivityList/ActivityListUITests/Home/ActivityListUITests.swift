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
    func insertTasksList(withId: UUID, name: String, type: TasksListModel.TasksListType, completion: @escaping InsertionCompletion) {
        completion(.success(()))
    }
    
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
        
        let tasksList1 = makeTasksList(name: "name1", tasksListType: .airplane)
        let tasksList2 = makeTasksList(name: "name2", tasksListType: .american_football)
        let tasksList3 = makeTasksList(name: "name3", tasksListType: .fight)
        
        let (sut, repository) = createSUT()
        sut.loadViewIfNeeded()
        
        repository.completeReadTasksLists(with: [tasksList1, tasksList2, tasksList3])
        
        XCTAssertEqual(sut.homeView.tasksLists, [tasksList1, tasksList2, tasksList3])
    }
    
    fileprivate func createSUT(file: StaticString = #filePath, line: UInt = #line) -> (HomeViewController, TasksListRepositoryStub) {
        let stub = TasksListRepositoryStub()
        let homeController = HomeViewController.init(taskListRepository: stub)
        trackMemoryLeak(homeController, file: file, line: line)
        
        return (homeController, stub)
    }
    

}

extension TasksListModel: Equatable {
    public static func == (lhs: TasksListModel, rhs: TasksListModel) -> Bool {
        return lhs.id == rhs.id &&
        lhs.type == rhs.type &&
        lhs.createdAt == rhs.createdAt &&
        lhs.name == rhs.name
    }
    
    
}
