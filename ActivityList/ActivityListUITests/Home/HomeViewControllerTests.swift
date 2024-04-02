//
//  ActivityListUITests.swift
//  ActivityListUITests
//
//  Created by Maksim Linich on 25.03.24.
//

import XCTest
import ActivityListDomain
import ActivityListUI



private class HomeServiceStub: HomeServiceProtocol {    
    func readTasksInfos() async throws -> HomeServiceProtocol.Result {
        let completionHolder = CompletionHolder<HomeService.Result>( completion: nil)
        self.readTasksInfosRequests.append(completionHolder)
        
        return try await withCheckedThrowingContinuation { continuation in
            completionHolder.completion =  { result in continuation.resume(returning:result)}
        }
    }
    
    public var readTasksListCount: Int {
        return readTasksInfosRequests.count
    }
    
    func completeReadTasksInfos(with items: HomeService.Result, at:Int = 0) {
        RunLoop.current.runForDistanceFuture()
        readTasksInfosRequests[at].completion!(items)
        RunLoop.current.runForDistanceFuture()
    }
    
    private var readTasksInfosRequests = [CompletionHolder<HomeService.Result>]()
    
}

final class HomeViewControllerTests: XCTestCase {
    
    func test_loadTasksLists_requestTasksListFromRepository() {
        let (sut, repository) = createSUT()
        
        XCTAssertEqual(repository.readTasksListCount, 0, "Expected no loading requests before view is loaded")
        
        sut.loadViewIfNeeded()
        
        RunLoop.current.runForDistanceFuture()
        
        XCTAssertEqual(repository.readTasksListCount, 1, "Expected loading request once view is loaded")
    }
    
    func test_loadTasksListCompletion_renderSuccessufullyLoadedTasksLists() {
        
        let tasksList1 = makeTasksListInfo(name: "name1", tasksListType: .airplane)
        let tasksList2 = makeTasksListInfo(name: "name2", tasksListType: .american_football)
        let tasksList3 = makeTasksListInfo(name: "name3", tasksListType: .fight)
        
        let (sut, repository) = createSUT()
        sut.loadViewIfNeeded()
        
        repository.completeReadTasksInfos(with: [tasksList1, tasksList2, tasksList3])
        
        XCTAssertEqual(sut.homeView.tasksLists, [tasksList1, tasksList2, tasksList3])
    }
    
    fileprivate func createSUT(file: StaticString = #filePath, line: UInt = #line) -> (HomeViewController, HomeServiceStub) {
        let stub = HomeServiceStub()
        let homeController = HomeViewController(homeService: stub)
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
