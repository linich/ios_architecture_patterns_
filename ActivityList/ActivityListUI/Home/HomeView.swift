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

internal class HomeView: UIView {
    weak var delegate: HomeViewDelegate?
    
    public var tasksList: [TaskListModel] = [] {
        didSet {
            tableView.reloadData()
            emptyState.isHidden = tasksList.count > 0
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

    private let titleLabel = {
        let label =  UILabel()
        label.textAlignment = .center
        return label
    }()
    
    private let tableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        return tableView
    }()
    
    private let emptyState = {
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
    
    public func setTasksLists(_ list: [TaskListModel]) {
        tasksList = list
    }
}


extension HomeView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasksList.count
    }
    
}
