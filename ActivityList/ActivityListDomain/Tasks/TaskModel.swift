//
//  Task.swift
//  ActivityListDomain
//
//  Created by Maksim Linich on 25.03.24.
//

import Foundation

public class TaskModel {
    
    public let id: UUID
    public let name: String
    public let createdAt: Date
    public let type: ActivityType
    
    public init(id: UUID, name: String, createdAt: Date, type: ActivityType) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.type = type
    }
    
}
