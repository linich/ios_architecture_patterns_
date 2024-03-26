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
    
    var taskListRepository: TaskListRepositoryProtocol {
        return TaskListRepository(fileUrl: coreDataStoreUrl)
    }
    
    var coreDataStoreUrl: URL {
        return documentDirectory.appendingPathComponent("activity_task_list.data", isDirectory: false)
    }
    
    var documentDirectory: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
}
