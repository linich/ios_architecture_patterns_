//
//  HomeViewController.swift
//  ActivityListUI
//
//  Created by Maksim Linich on 26.03.24.
//

import UIKit
import ActivityListDomain

final public class HomeViewController<HS: HomeServiceProtocol>: UIViewController where HS.Image == UIImage{
    public enum AccessibilityIdentifiers: String {
        case homeView
    }
    
    @IBOutlet public weak var homeView: HomeView!
    public var homeService: HS?
    private var task: Task<(), Never>? {
        willSet {
            if let currentTask = self.task {
                currentTask.cancel()
            }
        }
    }
    public convenience init(homeService: HS) {
        self.init(nibName: "HomeViewController", bundle: Bundle(for: HomeViewController.self))
        self.homeService = homeService
    }
    
    public override func viewDidLoad() {
        homeView.accessibilityIdentifier = AccessibilityIdentifiers.homeView.rawValue
        
        super.viewDidLoad()
        homeView.title = "My To Do List"
        homeView.emptyListMessage = "Press 'Add List' to start"
        homeView.addListButtonText = "Add List"
        
        self.task = Task { [weak self] in
            do {
                let items = try await self?.homeService?.readTasksInfos()
                self?.update(tasksListInfos: items ?? [])
            } catch {
                self?.homeView.isHidden = true
            }
        }
    }
    
    @MainActor
    private func update(tasksListInfos items: [TasksListInfo<UIImage>]) {
        homeView.tasksLists = items
    }
    
    deinit {
        self.task = nil
    }
}
