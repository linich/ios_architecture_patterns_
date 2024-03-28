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
    public let createdDate: Date
    public let icon: String
    
    public init(id: UUID, name: String, createdDate: Date, icon: String) {
        self.id = id
        self.name = name
        self.createdDate = createdDate
        self.icon = icon
    }
    
}
