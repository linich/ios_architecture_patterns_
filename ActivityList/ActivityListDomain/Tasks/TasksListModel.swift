//
//  TasksListModel.swift
//  ActivityListDomain
//
//  Created by Maksim Linich on 28.03.24.
//

import Foundation

public struct TasksListModel {
    public let id: UUID
    public let name: String
    public let createdAt: Date
    public let icon: String
    public let tasks: [TaskModel]
    
    public init(id: UUID, 
                name: String,
                createdAt: Date,
                icon: String,
                tasks: [TaskModel]) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.icon = icon
        self.tasks = tasks
    }
    
}
