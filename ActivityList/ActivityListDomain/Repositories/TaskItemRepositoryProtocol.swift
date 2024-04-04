//
//  TaskItemRepositoryProtocol.swift
//  ActivityListDomain
//
//  Created by Maksim Linich on 4.04.24.
//

public protocol TaskItemRepositoryProtocol {
    func readTasksOfTasksList(withId tasksListId: UUID) async throws -> [TaskModel]
    func insert(task: TaskModel, tasksListId: UUID) async throws -> Void
}
