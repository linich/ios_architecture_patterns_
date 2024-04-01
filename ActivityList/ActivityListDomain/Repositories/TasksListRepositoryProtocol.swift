//
//  TaskRepositoryProtocol.swift
//  ActivityListDomain
//
//  Created by Maksim Linich on 25.03.24.
//

public protocol TasksListRepositoryProtocol {
    typealias Result = Swift.Result<[TasksListModel], Error>
    typealias ReadCompletion = (Result) -> Void
    
    typealias InsertionResult = Swift.Result<Void, Error>
    typealias InsertionCompletion = (InsertionResult) -> Void
    
    func readTasksLists(completion: @escaping ReadCompletion) -> Void
    
    func insertTasksList(withId: UUID, name: String, type: TasksListModel.TasksListType, completion: @escaping InsertionCompletion) -> Void
    
}
