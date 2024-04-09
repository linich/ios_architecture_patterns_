//
//  HomeViewController.swift
//  ActivityListUI
//
//  Created by Maksim Linich on 26.03.24.
//

import UIKit
import ActivityListDomain

final public class HomeViewController<HS: HomeServiceProtocol>: UIViewController where HS.Image == UIImage{
    @IBOutlet public weak var homeView: HomeView!
    public var homeService: HS?
    
    public convenience init(homeService: HS) {
        self.init(nibName: "HomeViewController", bundle: Bundle(for: HomeViewController.self))
        self.homeService = homeService
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        homeView.title = "My To Do List"
        homeView.emptyListMessage = "Press 'Add List' to start"
        homeView.addListButtonText = "Add List"
        
        Task { [weak self] in
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
}
