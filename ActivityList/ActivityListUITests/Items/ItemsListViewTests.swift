//
//  ItemsListViewTests.swift
//  ActivityListUITests
//
//  Created by Maksim Linich on 24.04.24.
//

import XCTest
import UIKit

struct ItemData {
    
}
class ItemsView: UIView {
    public let emptyState = {
        let view = UIView()
        return view
        
    }()
    
    public let tableView = {
        let tableView = UITableView()
        return tableView
    }()
    
    public var items: [ItemData] = [] {
        didSet {
            emptyState.isHidden = !self.items.isEmpty
            tableView.isHidden = self.items.isEmpty
        }
    }
}

final class ItemsListViewTests: XCTestCase {
    func test_emptyState_shouldShowViewIfItemsListIsEmpty() {
        let sut = createSUT()
        
        sut.items = []
        
        XCTAssertFalse(sut.emptyState.isHidden, "Empty state view should be visible if items is empty");
    }
    
    func test_emptyState_shouldNotShowViewIfTasksListIsNotEmpty() {
        let sut = createSUT()
        
        sut.items = [makeItemData()]
        
        XCTAssertTrue(sut.emptyState.isHidden, "Empty state view should be visible if items is not empty");
    }

    func test_itemLists_shouldNotShowViewIfTasksListIsEmpty() {
        let sut = createSUT()
        
        sut.items = []
        
        XCTAssertTrue(sut.tableView.isHidden, "Items Lists view should not be visible if items is empty");
    }
    
    func test_itemLists_shouldShowViewIfTasksListIsNotEmpty() {
        let sut = createSUT()
        
        sut.items = [makeItemData()]
        
        XCTAssertFalse(sut.tableView.isHidden, "Items Lists view should  be visible if tasksLists is not empty");
    }
    
    // Mark: - Helpers
    
    fileprivate func createSUT(file: StaticString = #filePath, line: UInt = #line) -> ItemsView {
        let view = ItemsView()
        trackMemoryLeak(view)
        return view
    }
    
    fileprivate func makeItemData() -> ItemData {
        return ItemData()
    }

}
