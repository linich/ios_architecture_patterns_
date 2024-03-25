//
//  Task.swift
//  ActivityListDataLayer
//
//  Created by Maksim Linich on 25.03.24.
//
//

import Foundation
import SwiftData


@Model internal class Task {
    public var id: String?
    var name: String?
    var createdAt: Date?
    var icon: String?
    var taskList: TaskList?
    public init() {

    }
    
}
