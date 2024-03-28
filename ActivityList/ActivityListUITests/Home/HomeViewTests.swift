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
        
        view.tasksLists = [TasksListModel(id: UUID(), name: "name1", createdDate: Date.now, icon: "icon1")]
        
        XCTAssertTrue(view.emptyState.isHidden, "Empty state view should be visible if tasksLists is not empty");
    }

    func test_tasksLists_shouldNotShowViewIfTasksListIsEmpty() {
        let view = createSUT()
        
        view.tasksLists = []
        
        XCTAssertTrue(view.tableView.isHidden, "Tasks Lists view should not be visible if tasksLists is empty");
    }

    func test_tasksLists_shouldShowViewIfTasksListIsNotEmpty() {
        let view = createSUT()
        
        view.tasksLists = [TasksListModel(id: UUID(), name: "name1", createdDate: Date.now, icon: "icon1")]
        
        XCTAssertFalse(view.tableView.isHidden, "Tasks Lists view should  be visible if tasksLists is not empty");
    }
    
    func test_tasksLists_renderTasksLists() {
        let sut = createSUT()
        let tasksList1 = TasksListModel(id: UUID(), name: "name1", createdDate: Date.now, icon: "icon1")
        let tasksList2 = TasksListModel(id: UUID(), name: "name2", createdDate: Date.now, icon: "icon2")
        let tasksList3 = TasksListModel(id: UUID(), name: "name3", createdDate: Date.now, icon: "icon3")
        
        sut.tasksLists = [
            tasksList1,
            tasksList2,
            tasksList3
        ]
        
        XCTAssertEqual(sut.numberOfRenderedTasksLists, 3);
        
        assertThat(sut: sut, hasConfiguredCellFor: tasksList1, at: 0)
        
        assertThat(sut: sut, hasConfiguredCellFor: tasksList2, at: 1)
        
        assertThat(sut: sut, hasConfiguredCellFor: tasksList3, at: 2)
        
    }
    
    // Mark: - Helpers
    
    fileprivate func createSUT(file: StaticString = #filePath, line: UInt = #line) -> HomeView {
        let view = HomeView()
        trackMemoryLeak(view)
        return view
    }
    
    fileprivate func assertThat(sut: HomeView, hasConfiguredCellFor model: TasksListModel, at row: Int = 0, file: StaticString = #filePath, line: UInt = #line) {
        let cell = sut.tasksListView(at: row)
        guard let tasksListCell = cell as? TasksListCell else {
            XCTFail("Expected \(TasksListCell.self) instance, but got \(String(describing: cell.self))", file: file, line: line)
            return
        }
        
        XCTAssertEqual(tasksListCell.nameLabel.text, model.name, "Expected name to be \(String(describing: model.name)) at \(row)", file: file, line: line)
    }
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
