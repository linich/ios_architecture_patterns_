//
//  Task.swift
//  ActivityListDomain
//
//  Created by Maksim Linich on 25.03.24.
//

import Foundation

public class TaskModel {
    public enum TaskType {
        case none
        case game
        case gym
        case fight
        case airplane
        case shop
        case baseball
        case american_football
        case skiing
        case swimming
    }
    
    public let id: UUID
    public let name: String
    public let createdAt: Date
    public let type: TaskType
    
    public init(id: UUID, name: String, createdAt: Date, type: TaskType) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.type = type
    }
    
}
