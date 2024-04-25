//
//  ItemsViewControllerTests.swift
//  ActivityListUITests
//
//  Created by Maksim Linich on 25.04.24.
//

import XCTest

import ActivityListUI

final class ItemsViewControllerTests: XCTestCase {
    
    func test_loadTasksLists_requestTasksListFromRepository() {
        let (sut, repository) = createSUT()
        
        XCTAssertEqual(repository.readTasksListCount, 0, "Expected no loading requests before view is loaded")
        
        sut.loadViewIfNeeded()
        
        RunLoop.current.runForDistanceFuture()
        
        XCTAssertEqual(repository.readTasksListCount, 1, "Expected loading request once view is loaded")
        repository.completeReadTasksInfos(with: [])
    }
    
    func test_loadTasksListCompletion_renderSuccessufullyLoadedTasksLists() {
        
        let tasksList1 = makeItemData()
        let tasksList2 = makeItemData()
        let tasksList3 = makeItemData()
        
        let (sut, repository) = createSUT()
        sut.loadViewIfNeeded()
        
        repository.completeReadTasksInfos(with: [tasksList1, tasksList2, tasksList3])
        
        XCTAssertEqual(sut.itemsView.items, [tasksList1, tasksList2, tasksList3])
    }
    
    func test_loadTasksListCompletion_hideHomeViewIfServiceThrowAnError() {
        let (sut, repository) = createSUT()
        sut.loadViewIfNeeded()
        
        repository.completeReadTasksInfos(with: anyNSError())
        XCTAssertTrue(sut.itemsView.isHidden)
    }
    
    func test_loadTasksListCompletion_shouldWorksCorrectlyIfViewControllerWasDeintBeforeReceiveDataFromService() {
        let createRepForSut = {
            let (sut, rep) = self.createSUT()
            sut.loadViewIfNeeded()
            RunLoop.current.runForDistanceFuture()
            return rep
        }
    
        createRepForSut().completeReadTasksInfos(with: [])
        
        createRepForSut().completeReadTasksInfos(with: anyNSError())
    }
    
    func test_loadView_shouldSetTitle() {
        let (sut,stub) = createSUT()
    
        sut.title = "Title for test"
        sut.loadViewIfNeeded()
        stub.completeReadTasksInfos(with: [])
        XCTAssertEqual(sut.itemsView.title, "Title for test")
    }
    
    func test_setTitle_shouldUpdateTitle() {
        let (sut,stub) = createSUT()
    
        sut.title = "Title before load"
        sut.loadViewIfNeeded()
        stub.completeReadTasksInfos(with: [])
        sut.title = "Title after load"
        
        XCTAssertEqual(sut.itemsView.title, "Title after load")
    }
    
    fileprivate func createSUT(file: StaticString = #filePath, line: UInt = #line) -> (ItemsViewController<ItemsServiceStub>, ItemsServiceStub) {
        let stub = ItemsServiceStub()
        let homeController = ItemsViewController(itemsService: stub)
        trackMemoryLeak(homeController, file: file, line: line)
        trackMemoryLeak(stub, file: file, line: line)
        
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

private class ItemsServiceStub: ItemsServiceProtocol {
    func readItems() async throws -> [ItemData] {
        let completionHolder = CompletionHolder<Result<[ItemData], Error>>( completion: nil)
        self.readItemsRequests.append(completionHolder)
        
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
        return readItemsRequests.count
    }
    
    func completeReadTasksInfos(with items: [ItemData], at:Int = 0) {
        RunLoop.current.runForDistanceFuture()
        readItemsRequests[at].completion!(.success(items))
        RunLoop.current.runForDistanceFuture()
    }
    
    func completeReadTasksInfos(with error: Error , at:Int = 0) {
        RunLoop.current.runForDistanceFuture()
        readItemsRequests[at].completion!(.failure(error))
        RunLoop.current.runForDistanceFuture()
    }
    
    private var readItemsRequests = [CompletionHolder<Result<[ItemData], Error>>]()
}

extension ItemData: Equatable {
    public static func == (lhs: ItemData, rhs: ItemData) -> Bool {
        lhs.icon.pngData() == rhs.icon.pngData() &&
        lhs.subtitle == rhs.subtitle &&
        lhs.title == rhs.title
    }
    
    
}
