//
//  TasksListInfo+Equtable.swift
//  ActivityListDomain
//
//  Created by Maksim Linich on 1.04.24.
//

import Foundation
import ActivityListDomain

extension TasksListInfo: Equatable {
    public static func == (lhs: TasksListInfo, rhs: TasksListInfo) -> Bool {
        return lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.type == rhs.type &&
        lhs.tasksCount == rhs.tasksCount
    }
}
