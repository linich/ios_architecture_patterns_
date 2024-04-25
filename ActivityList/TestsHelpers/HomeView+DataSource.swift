//
//  HomeView+DataSource.swift
//  ActivityList
//
//  Created by Maksim Linich on 25.04.24.
//

import UIKit
import ActivityListUI

extension HomeView {
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
