//
//  HomeService.swift
//  ActivityListDomain
//
//  Created by Maksim Linich on 1.04.24.
//


public struct TasksListInfo {
    public let id: UUID
    public let name: String
    public let type: TasksListModel.TasksListType
    public let tasksCount: Int
    
    public init(id: UUID, name: String, type: TasksListModel.TasksListType, tasksCount: Int) {
        self.id = id
        self.name = name
        self.type = type
        self.tasksCount = tasksCount
    }
}

public protocol HomeServiceProtocol {
    typealias Result = Swift.Result<[TasksListInfo], Error>
    typealias Completion = (Result) -> Void
    
    func readTasksInfos(completion: @escaping Completion) -> Void
}
