//
//  TaskRepositoryProtocol.swift
//  ActivityListDomain
//
//  Created by Maksim Linich on 25.03.24.
//

public protocol TasksListRepositoryProtocol {
    typealias Result = Swift.Result<[TaskListModel], Error>
    
    func readTasksLists(completion: @escaping (Result) -> Void) -> Void
    
}
