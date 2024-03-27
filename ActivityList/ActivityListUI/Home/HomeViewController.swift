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
    private var taskLists =  [TaskListModel]()
    
    public convenience init(taskListRepository: TaskListRepositoryProtocol) {
        self.init(nibName: "HomeViewController", bundle: Bundle(for: HomeViewController.self))
        self.taskListRepository = taskListRepository
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.homeView.title = "My To Do List"
        self.homeView.emptyListMessage = "Press 'Add List' to start"
        self.homeView.addListButtonText = "Add List"
        taskListRepository?.readTasks(completion: { [weak self] result in
            switch result {
            case let .success(items):
                self?.taskLists = items
            case let .failure(error):
                print("\(error)")
            }
        })
    }
}
