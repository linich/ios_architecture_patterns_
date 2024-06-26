//
//  TasksListModel.swift
//  ActivityListDomain
//
//  Created by Maksim Linich on 28.03.24.
//

import Foundation

public enum ActivityType: CaseIterable {
    case undefined
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

public struct TasksListModel {
    public typealias TasksListType = ActivityType
    public let id: UUID
    public let name: String
    public let createdAt: Date
    public let type: TasksListType
    
    public init(id: UUID, 
                name: String,
                createdAt: Date,
                type: TasksListType) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.type = type
    }
    
}
