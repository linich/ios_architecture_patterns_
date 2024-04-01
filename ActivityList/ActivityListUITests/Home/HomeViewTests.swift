//
//  HomeViewTests.swift
//  ActivityListUITests
//
//  Created by Maksim Linich on 28.03.24.
//

import XCTest
import ActivityListUI
import ActivityListDomain


final class HomeViewTests: XCTestCase {
    func test_emptyState_shouldShowViewIfTasksListIsEmpty() {
        let view = createSUT()
        
        view.tasksLists = []
        
        XCTAssertFalse(view.emptyState.isHidden, "Empty state view should be visible if tasksLists is empty");
    }
    
    func test_emptyState_shouldNotShowViewIfTasksListIsNotEmpty() {
        let view = createSUT()
        
        view.tasksLists = [makeTasksList(name: "name1")]
        
        XCTAssertTrue(view.emptyState.isHidden, "Empty state view should be visible if tasksLists is not empty");
    }

    func test_tasksLists_shouldNotShowViewIfTasksListIsEmpty() {
        let view = createSUT()
        
        view.tasksLists = []
        
        XCTAssertTrue(view.tableView.isHidden, "Tasks Lists view should not be visible if tasksLists is empty");
    }

    func test_tasksLists_shouldShowViewIfTasksListIsNotEmpty() {
        let view = createSUT()
        
        view.tasksLists = [makeTasksList(name: "name1", tasksListType: .baseball)]
        
        XCTAssertFalse(view.tableView.isHidden, "Tasks Lists view should  be visible if tasksLists is not empty");
    }
    
    func test_tasksLists_renderTasksLists() {
        let sut = createSUT()
        
        let tasksLists = [
            makeTasksList(name: "name1", tasksListType: .game),
            makeTasksList(name: "name2", tasksListType: .shop),
            makeTasksList(name: "name3", tasksListType: .fight, tasksCount: 10)
        ]
        
        sut.tasksLists = tasksLists
        
        assertThat(sut: sut, configuredFor: tasksLists)
    }
    
    // Mark: - Helpers
    
    fileprivate func createSUT(file: StaticString = #filePath, line: UInt = #line) -> HomeView {
        let view = HomeView()
        view.iconImageProvider = iconImageProvider
        trackMemoryLeak(view)
        return view
    }
    
    fileprivate func assertThat(sut: HomeView, configuredFor models: [TasksListModel], file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(sut.numberOfRenderedTasksLists, models.count);
        
        for ( index, model) in models.enumerated(){
            assertThat(sut: sut, hasConfiguredCellFor: model, at: index)
        }
    }
    
    fileprivate func assertThat(sut: HomeView, hasConfiguredCellFor model: TasksListModel, at row: Int = 0, file: StaticString = #filePath, line: UInt = #line) {
        let cell = sut.tasksListView(at: row)
        guard let tasksListCell = cell as? TasksListCell else {
            XCTFail("Expected \(TasksListCell.self) instance, but got \(String(describing: cell.self))", file: file, line: line)
            return
        }
        
        XCTAssertEqual(tasksListCell.nameLabel.text, model.name, "Expected name to be \(String(describing: model.name)) at \(row)", file: file, line: line)
        
        XCTAssertEqual(tasksListCell.tasksCountLabel.text, "\(model.tasks.count) Tasks", "Expected tasks count text to be '\(model.tasks.count) Tasks') at \(row)", file: file, line: line)
        
        let expectedImageData = iconImageProvider.image(byActivityType: model.type).map({$0.pngData()}) ?? nil
        let actualImageData = tasksListCell.iconImageView.image.map({$0.pngData()}) ?? nil
        XCTAssertEqual(actualImageData, expectedImageData, "Expected image to be valid at \(row)", file: file, line: line)
    }
    
    fileprivate var iconImageProvider = IconImageProviderMock()
}

extension HomeView {
    var numberOfRenderedTasksLists: Int {
        return tableView.numberOfRows(inSection: 0)
    }
    
    func tasksListView(at row: Int) -> UITableViewCell? {
        return tableView.dataSource?.tableView(tableView, cellForRowAt: IndexPath(row: row, section: tasksListSection))
    }
    
    var tasksListSection: Int {
        return 0
    }
}

public class IconImageProviderMock: IconImageProviderProtocol {
    public func image(byActivityType type: ActivityType) -> UIImage? {
        UIGraphicsBeginImageContext(CGSize.init(width: 1, height: 1))
        defer {
            UIGraphicsEndImageContext()
        }
        
        let context = UIGraphicsGetCurrentContext()
        
        let hash = String(describing: type).hashValue
        context?.setFillColor(CGColor(
            red: CGFloat(hash & 0xFF) / 256.0,
            green: CGFloat((hash >> 16) & 0xFF) / 256.0,
            blue: CGFloat((hash >> 32) & 0xFF) / 256.0 ,
            alpha: 1))
        
        context?.fill([CGRect(x: 0, y: 0, width: 1, height: 1)])
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    
}
