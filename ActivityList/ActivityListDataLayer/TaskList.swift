//
//  TaskList.swift
//  ActivityListDataLayer
//
//  Created by Maksim Linich on 25.03.24.
//
//

import Foundation
import SwiftData


@Model public class TaskList {
    @Relationship(inverse: \Task.taskList) var tasks: Task?
    public init() {

    }
    
}
