//
//  CompositionRoot.swift
//  ActivityList
//
//  Created by Maksim Linich on 26.03.24.
//

import Foundation
import ActivityListUI
import ActivityListDataLayer
import ActivityListDomain

internal class CompositionRoot {
    
    public init(){
        
    }
    
    var home: HomeViewController {
        return HomeViewController(taskListRepository: taskListRepository)
    }
    
    var taskListRepository: TasksListRepositoryProtocol {
        return TaskListRepository(fileUrl: coreDataStoreUrl)
    }
    
    var coreDataStoreUrl: URL {
        guard let url = URL(string: "ActivityList.sqlite", relativeTo: documentDirectory) else {
            fatalError("Failed to create store url")
        }
        return url
    }
    
    var documentDirectory: URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
}
