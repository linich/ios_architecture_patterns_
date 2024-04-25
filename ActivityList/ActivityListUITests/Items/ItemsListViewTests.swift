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
    
    public var items: [ItemData] = []
}

final class ItemsListViewTests: XCTestCase {
    func test_emptyState_shouldShowViewIfItemsListIsEmpty() {
        let view = createSUT()
        
        view.items = []
        
        XCTAssertFalse(view.emptyState.isHidden, "Empty state view should be visible if tasksLists is empty");
    }

    // Mark: - Helpers
    
    fileprivate func createSUT(file: StaticString = #filePath, line: UInt = #line) -> ItemsView {
        let view = ItemsView()
        trackMemoryLeak(view)
        return view
    }

}
