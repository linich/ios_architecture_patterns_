//
//  TaskRepositoryProtocol.swift
//  ActivityListDomain
//
//  Created by Maksim Linich on 25.03.24.
//

public protocol TasksListRepositoryProtocol {
    
    func readTasksLists() async throws -> [TasksListModel]
    
    func readTaskItemsCount(forTasksListsWithIds:[UUID]) async throws -> [UUID: Int]
    
    func insertTasksList(withId: UUID, name: String, createdAt: Date, type: TasksListModel.TasksListType) async throws -> Void
}
