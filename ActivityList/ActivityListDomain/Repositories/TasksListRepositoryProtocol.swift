//
//  TaskRepositoryProtocol.swift
//  ActivityListDomain
//
//  Created by Maksim Linich on 25.03.24.
//

public protocol TasksListRepositoryProtocol {
    
    func readTasksLists() async throws -> [TasksListModel]
    
    func insertTasksList(withId: UUID, name: String, type: TasksListModel.TasksListType) async throws -> Void
}
