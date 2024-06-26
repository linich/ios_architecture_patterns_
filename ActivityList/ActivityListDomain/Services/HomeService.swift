//
//  HomeService.swift
//  ActivityListDomain
//
//  Created by Maksim Linich on 1.04.24.
//

import Foundation

public protocol ImageServiceProtocol {
    associatedtype Image
    associatedtype ImageKind
    
    func getImage(byKind: ImageKind) -> Image
}

public class HomeService<Image, ImageService: ImageServiceProtocol>: HomeServiceProtocol where ImageService.ImageKind == ActivityType, ImageService.Image == Image {
    
    public enum Error: Swift.Error {
        case ReadFromRepository
    }

    private let tasksListRepository: TasksListRepositoryProtocol
    private let imageService: ImageService
    public init(tasksListRepository: TasksListRepositoryProtocol, imageService: ImageService) {
        self.tasksListRepository = tasksListRepository
        self.imageService = imageService
    }
    
    public func readTasksInfos() async throws -> [TasksListInfo<Image>]{
        do {
            let tasksLists = try await tasksListRepository.readTasksLists()
            let counts = try await tasksListRepository.readTaskItemsCount(forTasksListsWithIds: tasksLists.map({$0.id}))
            return tasksLists.map({TasksListInfo(id: $0.id, name: $0.name, type: $0.type, tasksCount: counts[$0.id] ?? 0, icon: self.imageService.getImage(byKind: $0.type))})
        }
        catch {
            throw Error.ReadFromRepository
        }
    }
}
