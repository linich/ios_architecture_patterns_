//
//  TaskList.swift
//  ActivityListDataLayer
//
//  Created by Maksim Linich on 25.03.24.
//
//

import Foundation
import SwiftData


@Model internal class TaskList {
    var icon: String?
    public var id: String?
    var name: String?
    var createdAt: Date?
    @Relationship(inverse: \Task.taskList) var tasks: Task?
    public init() {

    }
    
}
