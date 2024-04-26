//
//  TaskItemsService.swift
//  ActivityListDomain
//
//  Created by Maksim Linich on 26.04.24.
//

import Foundation

public struct TaskItemInfo<Image> {
    public let id: UUID
    public let name: String
    public let done: Bool
    public let icon: Image
}

public protocol TaskItemsServiceProtocol {
    associatedtype Image
    
    func readTaskItems() async ->  [TaskItemInfo<Image>]
    
}
