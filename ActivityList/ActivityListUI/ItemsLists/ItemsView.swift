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
            tableView.reloadData()
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
        addSubview(titleLabel)
        addSubview(tableView)
        addSubview(emptyState)
        emptyState.addSubview(emptyListLabel)
        addSubview(addButton)
        setupConstraints()
        tableView.dataSource = dataSource
    }
    
    private func setupConstraints() {
        
        //Title label constraints
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        titleLabel.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
        
        
        //tableView constraints
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4).isActive = true
        tableView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        
        tableView.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        tableView.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
        
        // AddListButton constraints
        addButton.translatesAutoresizingMaskIntoConstraints = false
        
        addButton.heightAnchor.constraint(equalToConstant: 24).isActive = true
        addButton.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: 24).isActive = true
        
        addButton.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        addButton.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
        
        // emptyState constraints
        emptyState.translatesAutoresizingMaskIntoConstraints = false
        emptyState.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8).isActive = true
        emptyState.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        emptyState.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
        emptyState.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant:0 ).isActive = true
        
        // emptyListLabel constraints
        
        emptyListLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyListLabel.topAnchor.constraint(equalTo: emptyState.safeAreaLayoutGuide.topAnchor, constant: 18).isActive = true
        emptyListLabel.leadingAnchor.constraint(equalTo: emptyState.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        
        emptyListLabel.trailingAnchor.constraint(equalTo: emptyState.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
        emptyListLabel.heightAnchor.constraint(equalToConstant: 18).isActive = true
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
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}
