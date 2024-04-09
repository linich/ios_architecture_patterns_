//
//  XCTestCase+HomeHelpers.swift
//  ActivityListUITests
//
//  Created by Maksim Linich on 28.03.24.
//

import XCTest
import ActivityListDomain

extension XCTestCase {
    func makeTasksListInfo<Image>(
        name: String,
        tasksListType: TasksListModel.TasksListType = .game,
        taskType: ActivityType = .shop,
        id:UUID = UUID(),
        tasksCount: Int = 0,
        icon: Image) -> TasksListInfo<Image>{
            return TasksListInfo<Image>(id: id, name: name, type: tasksListType, tasksCount: tasksCount, icon: icon)
    }
    
    func  makeTasksList(
        name: String,
        tasksListType: TasksListModel.TasksListType = .game,
        taskType: ActivityType = .shop,
        id:UUID = UUID(),
        createdAt: Date = Date.now,
        tasksCount: Int = 0) -> TasksListModel{
        return TasksListModel(id: id, name: name, createdAt: createdAt, type: tasksListType)
    }
    
    func makeTask(
        name: String,
        type: ActivityType,
        id: UUID = UUID(),
        createdAt: Date = Date.now) -> TaskModel {
        return TaskModel(id: id, name: name, createdAt: createdAt, type: type)
    }
}
