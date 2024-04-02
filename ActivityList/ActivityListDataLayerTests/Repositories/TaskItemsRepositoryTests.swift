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
    
    func test_read_returnsEmptyTasksListOnEmptyData() {
        let sut = TaskItemRepository()
        
        let exp = expectation(description: "Loading task items")
        Task {
            defer {exp.fulfill()}
            let tasks = await sut.readTasks()
            XCTAssertEqual(tasks, [], "Should return empty task list")
        }
        
        wait(for: [exp], timeout: 1.0)
    }
}
