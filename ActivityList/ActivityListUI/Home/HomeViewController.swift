//
//  HomeViewController.swift
//  ActivityListUI
//
//  Created by Maksim Linich on 26.03.24.
//

import UIKit
import ActivityListDomain

public class HomeViewController: UIViewController {
    @IBOutlet weak var homeView: HomeView!
    private var taskListRepository: TaskListRepositoryProtocol?
    
    public convenience init(taskListRepository: TaskListRepositoryProtocol) {
        self.init(nibName: "HomeViewController", bundle: Bundle(for: HomeViewController.self))
        self.taskListRepository = taskListRepository
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        homeView.title = "My To Do List"
        homeView.emptyListMessage = "Press 'Add List' to start"
        homeView.addListButtonText = "Add List"
        
        taskListRepository?.readTasks(completion: { [weak self] result in
            switch result {
            case let .success(items):
                self?.homeView.tasksList = items
            case let .failure(error):
                print("\(error)")
            }
        })
    }
}
