//
//  XCTestCase+HomeHelpers.swift
//  ActivityListUITests
//
//  Created by Maksim Linich on 28.03.24.
//

import XCTest
import ActivityListDomain

extension XCTestCase {
    func makeTasksList(
        name: String,
        icon: String,
        id:UUID = UUID(),
        createdAt: Date = Date.now,
        tasksCount: Int = 0) -> TasksListModel{
            let tasks = (0..<tasksCount).map { makeTask(name: "task_\($0)", icon: "icon_\($0)")}
        return TasksListModel(id: id, name: name, createdAt: createdAt, icon: icon, tasks: tasks)
    }
    
    func makeTask(
        name: String,
        icon: String,
        id: UUID = UUID(),
        createdAt: Date = Date.now) -> TaskModel {
        return TaskModel(id: id, name: name, createdAt: createdAt, icon: icon)
    }
}
