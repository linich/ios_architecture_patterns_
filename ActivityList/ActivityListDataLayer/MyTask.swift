//
//  Task.swift
//  ActivityListDataLayer
//
//  Created by Maksim Linich on 25.03.24.
//
//

import Foundation
import SwiftData

@Model public class MyTask {
    public var id: String?
    public var name: String?
    public var createdAt: Date?
    public var icon: String?
    public var taskList: TaskList?
    public init() {

    }
    
}
