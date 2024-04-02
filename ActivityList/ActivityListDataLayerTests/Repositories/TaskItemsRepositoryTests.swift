//
//  TaskItemsRepositoryTests.swift
//  ActivityListDomainTests
//
//  Created by Maksim Linich on 2.04.24.
//

import XCTest
import CoreData
import ActivityListDomain

class TaskItemRepository {
    
    func readTasks() async -> [TaskModel] {
        return []
    }
}

final class TaskItemsRepositoryTests: XCTestCase {
    
    func test_readTasks_returnsEmptyTasksListOnEmptyData() {
        let (sut, _) = createSUT()
        
        let exp = expectation(description: "Loading task items")
        Task {
            defer {exp.fulfill()}
            let tasks = await sut.readTasks()
            XCTAssertEqual(tasks, [], "Should return empty task list")
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
//    func test_readTasks_returnsAllTasksOnNonEmptyStorage() {
//
//    }
    
    // Mark: - Helpers
    
    fileprivate func createSUT(storeURL: URL = URL(fileURLWithPath: "/dev/null")) -> (TaskItemRepository, NSManagedObjectContext) {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = createPersistanceStoreCoordinator(storeUrl: storeURL)
        
        return (TaskItemRepository(), managedObjectContext)
    }
}
