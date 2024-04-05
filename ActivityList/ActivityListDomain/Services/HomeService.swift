//
//  HomeService.swift
//  ActivityListDomain
//
//  Created by Maksim Linich on 1.04.24.
//

import Foundation

public class HomeService: HomeServiceProtocol {
    public enum Error: Swift.Error {
        case ReadFromRepository
    }

    private let tasksListRepository: TasksListRepositoryProtocol
    public init(tasksListRepository: TasksListRepositoryProtocol) {
        self.tasksListRepository = tasksListRepository
    }
    
    public func readTasksInfos() async throws -> HomeServiceProtocol.Result {
        do {
            let tasksLists = try await tasksListRepository.readTasksLists()
            let counts = try await tasksListRepository.readTaskItemsCount(forTasksListsWithIds: tasksLists.map({$0.id}))
            return tasksLists.map({TasksListInfo(id: $0.id, name: $0.name, type: $0.type, tasksCount: counts[$0.id] ?? 0)})
        }
        catch {
            throw Error.ReadFromRepository
        }
    }
}
