//
//  TaskRepositoryProtocol.swift
//  ActivityListDomain
//
//  Created by Maksim Linich on 25.03.24.
//

public protocol TasksListRepositoryProtocol {
    typealias ReadResult = [TasksListModel]
    
    typealias InsertionResult = Swift.Result<Void, Error>
    typealias InsertionCompletion = (InsertionResult) -> Void
    
    func readTasksLists() async throws -> ReadResult
    
    func insertTasksList(withId: UUID, name: String, type: TasksListModel.TasksListType, completion: @escaping InsertionCompletion) -> Void
    
}
