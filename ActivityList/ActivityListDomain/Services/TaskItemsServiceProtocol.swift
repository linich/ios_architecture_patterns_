//
//  TaskItemsService.swift
//  ActivityListDomain
//
//  Created by Maksim Linich on 26.04.24.
//

import Foundation

public struct TaskItemInfo<Image> {
    public let id: UUID
    public let name: String
    public let done: Bool
    public let icon: Image
    public let type: ActivityType
    
    public init(id: UUID, name: String, done: Bool, type: ActivityType, icon: Image) {
        self.id = id
        self.name = name
        self.done = done
        self.type = type
        self.icon = icon
    }
}

public protocol TaskItemsServiceProtocol {
    associatedtype Image
    
    func readTaskItems() async throws ->  [TaskItemInfo<Image>]
    
}
