//
//  HomeService.swift
//  ActivityListDomain
//
//  Created by Maksim Linich on 1.04.24.
//


public struct TasksListInfo<Image> {
    public let id: UUID
    public let name: String
    public let type: TasksListModel.TasksListType
    public let tasksCount: Int
    public let icon: Image
    
    public init(id: UUID, name: String, type: TasksListModel.TasksListType, tasksCount: Int, icon: Image) {
        self.id = id
        self.name = name
        self.type = type
        self.tasksCount = tasksCount
        self.icon = icon
    }
}

public protocol HomeServiceProtocol {
    associatedtype Image
    typealias Result = [TasksListInfo<Image>]
    
    func readTasksInfos() async throws -> Result
}
