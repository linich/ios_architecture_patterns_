//
//  HomeService.swift
//  ActivityListDomain
//
//  Created by Maksim Linich on 1.04.24.
//

import Foundation

public protocol ImageProviderProtocol {
    associatedtype Image
    associatedtype ImageKind
    
    func getImage(byKind: ImageKind) -> Image
}

public class HomeService<Image, ImageProvider: ImageProviderProtocol>: HomeServiceProtocol where ImageProvider.ImageKind == ActivityType, ImageProvider.Image == Image {
    
    public enum Error: Swift.Error {
        case ReadFromRepository
    }

    private let tasksListRepository: TasksListRepositoryProtocol
    private let imageProvider: ImageProvider
    public init(tasksListRepository: TasksListRepositoryProtocol, imageProvider: ImageProvider) {
        self.tasksListRepository = tasksListRepository
        self.imageProvider = imageProvider
    }
    
    public func readTasksInfos() async throws -> [TasksListInfo<Image>]{
        do {
            let tasksLists = try await tasksListRepository.readTasksLists()
            let counts = try await tasksListRepository.readTaskItemsCount(forTasksListsWithIds: tasksLists.map({$0.id}))
            return tasksLists.map({TasksListInfo(id: $0.id, name: $0.name, type: $0.type, tasksCount: counts[$0.id] ?? 0, icon: self.imageProvider.getImage(byKind: $0.type))})
        }
        catch {
            throw Error.ReadFromRepository
        }
    }
}
