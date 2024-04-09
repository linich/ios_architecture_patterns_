//
//  TasksListInfo+Equatable.swift
//  ActivityListUITests
//
//  Created by Maksim Linich on 9.04.24.
//

import UIKit
import ActivityListDomain

extension TasksListInfo: Equatable where Image == UIImage {
    public static func == (lhs: TasksListInfo, rhs: TasksListInfo) -> Bool {
        return lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.type == rhs.type &&
        lhs.tasksCount == rhs.tasksCount &&
        lhs.icon.pngData() == rhs.icon.pngData()
    }
}
