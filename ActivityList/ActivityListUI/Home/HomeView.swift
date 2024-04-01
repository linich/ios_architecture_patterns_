//
//  HomeView.swift
//  ActivityListUI
//
//  Created by Maksim Linich on 27.03.24.
//

import UIKit
import ActivityListDomain

internal protocol HomeViewDelegate: AnyObject {
    
}

public protocol IconImageProviderProtocol{
    func image(byActivityType: ActivityType) -> UIImage?
}

public class HomeView: UIView {
    weak var delegate: HomeViewDelegate?
    
    public var iconImageProvider: IconImageProviderProtocol = IconImageProvider() {
        didSet {
            tableViewDataSource.iconImageProvider = iconImageProvider
        }
    }
    
    public var tasksLists: [TasksListModel] = [] {
        didSet {
            tableViewDataSource.tasksLists = tasksLists
            tableView.reloadData()
            emptyState.isHidden = !tasksLists.isEmpty
            tableView.isHidden = tasksLists.isEmpty
        }
    }
    
    public var emptyListMessage: String = "" {
        didSet {
            emptyListLabel.text = emptyListMessage
        }
    }
    
    public var title: String = "" {
        didSet {
            titleLabel.text = title
        }
    }
    
    public var addListButtonText: String = "" {
        didSet {
            addListButton.setTitle(addListButtonText, for: .normal)
        }
    }
    
    private var tableViewDataSource = HomeViewTableViewDataSource()
    
    private let titleLabel = {
        let label =  UILabel()
        label.textAlignment = .center
        return label
    }()
    
    public let tableView = {
        let tableView = UITableView()
        tableView.register(TasksListCell.self, forCellReuseIdentifier: "\(TasksListCell.self)")
        return tableView
    }()
    
    public let emptyState = {
        let view = UIView()
        return view
        
    }()
        
    private let emptyListLabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    
    private let addListButton =  {
        let button = UIButton(type: .system)
        button.setTitle("Add", for: .normal)
        return button
    }()
    
    
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
        addSubview(addListButton)
        
        setupConstraints();
        
        tableView.dataSource = tableViewDataSource
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
        addListButton.translatesAutoresizingMaskIntoConstraints = false
        
        addListButton.heightAnchor.constraint(equalToConstant: 24).isActive = true
        addListButton.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: 24).isActive = true
        
        addListButton.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        addListButton.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
        
        // emptyState constraints
        emptyState.translatesAutoresizingMaskIntoConstraints = false
        emptyState.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8).isActive = true
        emptyState.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        emptyState.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
        emptyState.bottomAnchor.constraint(equalTo: addListButton.topAnchor, constant:0 ).isActive = true
        
        // emptyListLabel constraints
        
        emptyListLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyListLabel.topAnchor.constraint(equalTo: emptyState.safeAreaLayoutGuide.topAnchor, constant: 18).isActive = true
        emptyListLabel.leadingAnchor.constraint(equalTo: emptyState.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        
        emptyListLabel.trailingAnchor.constraint(equalTo: emptyState.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
        emptyListLabel.heightAnchor.constraint(equalToConstant: 18).isActive = true
    }
}


internal class HomeViewTableViewDataSource:NSObject, UITableViewDataSource {
    public var tasksLists = [TasksListModel]()
    public var iconImageProvider: IconImageProviderProtocol?
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let tasksListCell = tableView.dequeueReusableCell(withIdentifier: "\(TasksListCell.self)", for: indexPath) as? TasksListCell else {
            fatalError("Can't get cell for item at \(indexPath)")
        }
        let model = tasksLists[indexPath.row]
        tasksListCell.nameLabel.text = model.name
        tasksListCell.tasksCountLabel.text = "\(model.tasks.count) Tasks"
        tasksListCell.iconImageView.image = iconImageProvider?.image(byActivityType: model.type)
        return tasksListCell
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasksLists.count
    }
    
}

final public class TasksListCell: UITableViewCell {
    public let nameLabel = UILabel()
    public let tasksCountLabel = UILabel()
    public let iconImageView = UIImageView()
}
