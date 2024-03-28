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
    
    // Mark: - Helpers
    
    fileprivate func createSUT(file: StaticString = #filePath, line: UInt = #line) -> HomeView {
        let view = HomeView()
        trackMemoryLeak(view)
        return view
    }
}
