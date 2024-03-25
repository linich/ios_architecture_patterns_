//
//  TaskList.swift
//  ActivityListDataLayer
//
//  Created by Maksim Linich on 25.03.24.
//
//

import Foundation
import SwiftData


@Model public class MyTaskList {
    @Relationship(inverse: \MyTask.taskList) var tasks: MyTask?
    public init() {

    }
    
}
