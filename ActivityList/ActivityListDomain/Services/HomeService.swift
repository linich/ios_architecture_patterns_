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
            return try await withCheckedThrowingContinuation { continuation in
                tasksListRepository.readTasksLists { result in
                    switch result {
                    case let .success(tasks):
                        continuation.resume(returning:tasks.map({TasksListInfo(id: $0.id, name: $0.name, type: $0.type, tasksCount: 0)}))
                    case .failure:
                        continuation.resume(throwing: Error.ReadFromRepository)
                    }
                }
            }
        }
        catch {
            throw error
        }
    }
}
