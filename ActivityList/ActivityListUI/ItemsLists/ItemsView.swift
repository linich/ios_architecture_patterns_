//
//  ItemsView.swift
//  ActivityListUI
//
//  Created by Maksim Linich on 25.04.24.
//

import UIKit

public class ItemsView: UIView {
    public let emptyState = {
        let view = UIView()
        return view
        
    }()
    
    public let tableView = {
        let tableView = UITableView()
        tableView.register(ItemTableCellView.self, forCellReuseIdentifier: "\(ItemTableCellView.self)")
        return tableView
    }()

    public let addButton = {
        let button = UIButton()
        return button
    }()

    private let titleLabel = {
        let titleLabel = UILabel()
        return titleLabel
    }()
    
    private let emptyListLabel = {
        let titleLabel = UILabel()
        return titleLabel
    }()
    
    public var title: String? {
        didSet {
            self.titleLabel.text = title
        }
    }
    
    public var emptyListMessage: String? {
        didSet {
            self.emptyListLabel.text = emptyListMessage
        }
    }

    public var addButtonText: String? {
        didSet {
            self.addButton.setTitle(addButtonText, for: .normal)
        }
    }
    
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
        
        let tasksListCell = tableView.dequeueReusableCell(withIdentifier: "\(ItemTableCellView.self)", for: indexPath) as! ItemTableCellView
        
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
