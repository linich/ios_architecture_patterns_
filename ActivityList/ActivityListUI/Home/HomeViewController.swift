//
//  HomeViewController.swift
//  ActivityListUI
//
//  Created by Maksim Linich on 26.03.24.
//

import UIKit
import ActivityListDomain

public class HomeViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    private var taskListRepository: TaskListRepositoryProtocol?
    
    public convenience init(taskListRepository: TaskListRepositoryProtocol) {
        self.init(nibName: "HomeViewController", bundle: Bundle(for: HomeViewController.self))
        self.taskListRepository = taskListRepository
    }
}
