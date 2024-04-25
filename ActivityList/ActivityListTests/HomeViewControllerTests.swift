//
//  ActivityListTests.swift
//  ActivityListTests
//
//  Created by Maksim Linich on 24.04.24.
//

import XCTest
import ActivityListDomain
import ActivityListUI
@testable import ActivityList

final class HomeViewControllerTests: XCTestCase {
    fileprivate typealias SUT = ItemsViewController<HomeServiceToItemsServiceAdapter<HomeServiceStub>>
    
    func test_Title() {
        let (sut, repository) = createSUT()
        
        XCTAssertEqual(repository.readTasksListCount, 0, "Expected no loading requests before view is loaded")
        
        sut.loadViewIfNeeded()
        
        RunLoop.current.runForDistanceFuture()
        repository.completeReadTasksInfos(with: [])
        
        XCTAssertEqual(sut.title, "Tasks Lists")
    }
    
    func test_EmptyTasksListMessages() {
        let (sut, repository) = createSUT()
        
        XCTAssertEqual(repository.readTasksListCount, 0, "Expected no loading requests before view is loaded")
        
        sut.loadViewIfNeeded()
        
        RunLoop.current.runForDistanceFuture()
        repository.completeReadTasksInfos(with: [])
        XCTAssertEqual(sut.emptyListMessage, "Press 'Add List' to start")
    }
    
    func test_loadTasksLists_requestTasksListFromRepository() {
        let (sut, repository) = createSUT()
        
        XCTAssertEqual(repository.readTasksListCount, 0, "Expected no loading requests before view is loaded")
        
        sut.loadViewIfNeeded()
        
        RunLoop.current.runForDistanceFuture()
        
        XCTAssertEqual(repository.readTasksListCount, 1, "Expected loading request once view is loaded")
        repository.completeReadTasksInfos(with: [])
    }
    
    func test_loadTasksListCompletion_renderSuccessufullyLoadedTasksLists() {
        
        let tasksList1 = makeTasksListInfo(name: "name1", tasksListType: .airplane, icon: image(withColor: .black))
        let tasksList2 = makeTasksListInfo(name: "name2", tasksListType: .american_football, icon: image(withColor: .red))
        let tasksList3 = makeTasksListInfo(name: "name3", tasksListType: .fight, icon: image(withColor: .green))
        
        let (sut, repository) = createSUT()
        sut.loadViewIfNeeded()
        sut.view.frame = CGRect(x: 0, y: 0, width: 300, height: 600)
        sut.view.layoutIfNeeded()
        
        repository.completeReadTasksInfos(with: [tasksList1, tasksList2, tasksList3])
        
        assertThat(sut: sut, hasConfiguredCellFor: tasksList1, at: 0)
        assertThat(sut: sut, hasConfiguredCellFor: tasksList2, at: 1)
        assertThat(sut: sut, hasConfiguredCellFor: tasksList3, at: 2)
    }
    
    func test_loadTasksListCompletion_hideHomeViewIfServiceThrowAnError() {
        let (sut, repository) = createSUT()
        sut.loadViewIfNeeded()
        
        repository.completeReadTasksInfos(with: anyNSError())
        assertThatSutHasNotVisibleTasksList(sut)
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
    
    fileprivate func createSUT(file: StaticString = #filePath, line: UInt = #line) -> (SUT, HomeServiceStub) {
        let compositionRoot = CompositionRoot()
        let stub = HomeServiceStub()
        let sut = compositionRoot.createHomeViewController(withService: stub)
        trackMemoryLeak(sut, file: file, line: line)
        trackMemoryLeak(stub, file: file, line: line)
        
        return (sut, stub)
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
    
    fileprivate func assertThatSutHasNotVisibleTasksList(_ sut: SUT, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertTrue(sut.itemsView.isHidden)
    }
    
    fileprivate func assertThat(sut: SUT, hasConfiguredCellFor model: TasksListInfo<UIImage>, at row: Int = 0, file: StaticString = #filePath, line: UInt = #line) {
        let cell = sut.itemsView!.itemTableCellView(at: row)
        guard let itemCell = cell as? ItemTableCellView else {
            XCTFail("Expected \(TasksListCell.self) instance, but got \(String(describing: cell.self))", file: file, line: line)
            return
        }
        
        XCTAssertEqual(itemCell.titleLabel.text, model.name, "Expected name to be \(String(describing: model.name)) at \(row)", file: file, line: line)
        
        XCTAssertEqual(itemCell.subtitleLabel.text, "\(model.tasksCount) Tasks", "Expected tasks count text to be '\(model.tasksCount) Tasks') at \(row)", file: file, line: line)
        
        let expectedImageData = model.icon.pngData()
        let actualImageData = itemCell.iconImageView.image.map({$0.pngData()}) ?? nil
        XCTAssertEqual(actualImageData, expectedImageData, "Expected image to be valid at \(row)", file: file, line: line)
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

extension ItemsView {
    func itemTableCellView(at row: Int) -> UITableViewCell? {
        return self.tableView.cellForRow(at: IndexPath(row: row, section: 0))
    }
}
