//
//  HomeService.swift
//  ActivityListDomain
//
//  Created by Maksim Linich on 1.04.24.
//


public struct TasksListInfo {
    let id: UUID
    let name: String
    let type: TasksListModel.TasksListType
    let tasksCount: Int
}

public protocol HomeServiceProtocol {
    typealias Result = Swift.Result<[TasksListInfo], Error>
    typealias Completion = (Result) -> Void
    
    func readTasksInfos(completion: Completion) -> Void
}
