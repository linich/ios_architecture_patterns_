//
//  ItemsListViewTests.swift
//  ActivityListUITests
//
//  Created by Maksim Linich on 24.04.24.
//

import XCTest
import UIKit
import ActivityListUI

class ItemCellView: UITableViewCell {
    public let titleLabel = UILabel()
    public let subtitleLabel = UILabel()
    public let iconImageView = UIImageView()
}

class ItemsView: UIView {
    public let emptyState = {
        let view = UIView()
        return view
        
    }()
    
    public let tableView = {
        let tableView = UITableView()
        tableView.register(ItemCellView.self, forCellReuseIdentifier: "\(ItemCellView.self)")
        return tableView
    }()
    
    public var items: [ItemData] = [] {
        didSet {
            dataSource.items = self.items
            emptyState.isHidden = !self.items.isEmpty
            tableView.isHidden = self.items.isEmpty
        }
    }
    
    private let dataSource = ItemsViewTableViewDataSource()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews();
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews();
    }

    private func setupSubviews() {
        tableView.dataSource = dataSource
    }
}

internal class ItemsViewTableViewDataSource:NSObject, UITableViewDataSource {
    public var items = [ItemData]()
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let tasksListCell = tableView.dequeueReusableCell(withIdentifier: "\(ItemCellView.self)", for: indexPath) as! ItemCellView
        
        let model = items[indexPath.row]
        tasksListCell.titleLabel.text = model.title
        tasksListCell.subtitleLabel.text = model.subtitle
        tasksListCell.iconImageView.image = model.icon
        
        return tasksListCell
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
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
    
    func test_tasksLists_renderTasksLists() {
        let sut = createSUT()
        
        let items = [
            makeItemData(),
            makeItemData(),
            makeItemData()
        ]
        
        sut.items = items
        
        assertThat(sut: sut, configuredFor: items)
    }
    
    // Mark: - Helpers
    
    fileprivate func createSUT(file: StaticString = #filePath, line: UInt = #line) -> ItemsView {
        let view = ItemsView()
        trackMemoryLeak(view)
        return view
    }
    
    fileprivate func makeItemData(title: String = "title_\(#line)", subtitle: String = "subtitile_\(#line)", icon: UIImage = UIImage()) -> ItemData {
        return ItemData(title: title, subtitle: subtitle, icon: icon)
    }
    
    
    fileprivate func assertThat(sut: ItemsView, configuredFor models: [ItemData], file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(sut.numberOfRenderedTasksLists, models.count);
        
        for ( index, model) in models.enumerated(){
            assertThat(sut: sut, hasConfiguredCellFor: model, at: index)
        }
    }
    
    fileprivate func assertThat(sut: ItemsView, hasConfiguredCellFor model: ItemData, at row: Int = 0, file: StaticString = #filePath, line: UInt = #line) {
        let cell = sut.tasksListView(at: row)
        guard let tasksListCell = cell as? ItemCellView else {
            XCTFail("Expected \(ItemCellView.self) instance, but got \(String(describing: cell.self))", file: file, line: line)
            return
        }
        
        XCTAssertEqual(tasksListCell.titleLabel.text, model.title, "Expected title to be \(String(describing: model.title)) at \(row)", file: file, line: line)
        
        XCTAssertEqual(tasksListCell.subtitleLabel.text, model.subtitle, "Expected subtitle to be '\(model.subtitle)') at \(row)", file: file, line: line)
        
        let expectedImageData = model.icon.pngData()
        let actualImageData = tasksListCell.iconImageView.image.map({$0.pngData()}) ?? nil
        XCTAssertEqual(actualImageData, expectedImageData, "Expected image to be valid at \(row)", file: file, line: line)
    }
}

extension ItemsView {
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

