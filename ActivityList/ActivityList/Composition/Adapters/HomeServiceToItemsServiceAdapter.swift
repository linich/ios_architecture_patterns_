//
//  HomeServiceToItemsAdapter.swift
//  ActivityList
//
//  Created by Maksim Linich on 25.04.24.
//

import Foundation
import ActivityListDomain
import ActivityListUI
import UIKit


struct HomeServiceToItemsServiceAdapter<HS: HomeServiceProtocol>: ItemsServiceProtocol where HS.Image == UIImage{
    private let homeService: HS
    
    public init(homeService: HS) {
        self.homeService = homeService
    }
    
    func readItems() async throws -> [ActivityListUI.ItemData] {
        let tasks = try await homeService.readTasksInfos()
        return tasks.map { return ItemData.init(title: $0.name, subtitle: "\($0.tasksCount) Tasks", icon: $0.icon) }
    }
}
