//
//  ActivityListUITests.swift
//  ActivityListUITests
//
//  Created by Maksim Linich on 25.03.24.
//

import XCTest
import ActivityListDomain
import ActivityListUI

final class HomeViewControllerTests: XCTestCase {
    
    func test_loadTasksLists_requestTasksListFromRepository() {
        let (sut, repository) = createSUT()
        
        XCTAssertEqual(repository.readTasksListCount, 0, "Expected no loading requests before view is loaded")
        
        sut.loadViewIfNeeded()
        
        RunLoop.current.runForDistanceFuture()
        
        XCTAssertEqual(repository.readTasksListCount, 1, "Expected loading request once view is loaded")
    }
    
    func test_loadTasksListCompletion_renderSuccessufullyLoadedTasksLists() {
        
        let tasksList1 = makeTasksListInfo(name: "name1", tasksListType: .airplane, icon: image(withColor: .black))
        let tasksList2 = makeTasksListInfo(name: "name2", tasksListType: .american_football, icon: image(withColor: .red))
        let tasksList3 = makeTasksListInfo(name: "name3", tasksListType: .fight, icon: image(withColor: .green))
        
        let (sut, repository) = createSUT()
        sut.loadViewIfNeeded()
        
        repository.completeReadTasksInfos(with: [tasksList1, tasksList2, tasksList3])
        
        XCTAssertEqual(sut.homeView.tasksLists, [tasksList1, tasksList2, tasksList3])
    }
    
    func test_loadTasksListCompletion_hideHomeViewIfServiceThrowAnError() {
        let (sut, repository) = createSUT()
        sut.loadViewIfNeeded()
        
        repository.completeReadTasksInfos(with: anyNSError())
        XCTAssertTrue(sut.homeView.isHidden)
    }
    
    fileprivate func createSUT(file: StaticString = #filePath, line: UInt = #line) -> (HomeViewController<HomeServiceStub>, HomeServiceStub) {
        let stub = HomeServiceStub()
        let homeController = HomeViewController(homeService: stub)
        trackMemoryLeak(homeController, file: file, line: line)
        
        return (homeController, stub)
    }
    
    fileprivate func image(withColor color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        context.fill([rect])
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
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

private class HomeServiceStub: HomeServiceProtocol {
    func readTasksInfos() async throws -> [TasksListInfo<UIImage>] {
        let completionHolder = CompletionHolder<Result<[TasksListInfo<UIImage>], Error>>( completion: nil)
        self.readTasksInfosRequests.append(completionHolder)
        
        return try await withCheckedThrowingContinuation { continuation in
            completionHolder.completion =  { result in
                switch result{
                case let .success(items):
                    continuation.resume(returning:items)
                case let .failure(error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    public var readTasksListCount: Int {
        return readTasksInfosRequests.count
    }
    
    func completeReadTasksInfos(with items: [TasksListInfo<UIImage>], at:Int = 0) {
        RunLoop.current.runForDistanceFuture()
        readTasksInfosRequests[at].completion!(.success(items))
        RunLoop.current.runForDistanceFuture()
    }
    
    func completeReadTasksInfos(with error: Error , at:Int = 0) {
        RunLoop.current.runForDistanceFuture()
        readTasksInfosRequests[at].completion!(.failure(error))
        RunLoop.current.runForDistanceFuture()
    }
    
    private var readTasksInfosRequests = [CompletionHolder<Result<[TasksListInfo<UIImage>], Error>>]()
}
