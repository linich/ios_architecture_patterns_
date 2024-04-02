//
//  TaskItemsRepositoryTests.swift
//  ActivityListDomainTests
//
//  Created by Maksim Linich on 2.04.24.
//

import XCTest
import CoreData
import ActivityListDomain
import ActivityListDataLayer

public enum TaskItemRepositoryError: Error {
    case ReadTaskItems
}

class TaskItemRepository {
    private let context: NSManagedObjectContext
    private let tasksListId: UUID
    
    public init(context: NSManagedObjectContext, tasksListId: UUID) {
        self.context = context
        self.tasksListId = tasksListId
    }
    
    func readTasks() async throws -> [TaskModel] {
        do {
            return try await withCheckedThrowingContinuation { continuation in
                self.context.perform {
                    let request = TaskItem.fetchRequest()
                    do {
                        let result = try self.context.fetch(request)
                        
                        let taskItems = result.map({
                            guard
                                let itemId = $0.id,
                                let name = $0.name,
                                let id = UUID(uuidString: itemId),
                                let createdAt = $0.createdAt else {
                                return nil as TaskModel?
                            }
                            return TaskModel(id: id, name: name, createdAt: createdAt, type: .airplane)
                        }).compactMap({$0})
                        continuation.resume(returning: taskItems)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            }
        } catch {
            throw TaskItemRepositoryError.ReadTaskItems
        }
    }
}

final class TaskItemsRepositoryTests: XCTestCase {
    
    func test_readTasks_returnsEmptyTasksListOnEmptyData() {
        let (sut, _) = createSUT()
        
        let exp = expectation(description: "Loading task items")
        Task {
            defer {exp.fulfill()}
            do {
                let tasks = try await sut.readTasks()
                XCTAssertEqual(tasks, [], "Should return empty task list")
            } catch {
                XCTFail("Expected task items, but got \(error)")
            }
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_readTasks_returnsTasksUseOnlyOneTasksList() {
        let (sut, context) = createSUT()
        let tasksList1 = createTasksList(name: "tasks list 1", inContext: context)
        let tasksList2 = createTasksList(name: "tasks list 2", inContext: context)
        
        let taskItem1_1 = createTaskItem(forTaskslist: tasksList1, inContext: context)
        
        var tasks  = [TaskModel]()
        
        let exp = expectation(description: "Loading task items")
        Task {
            defer { exp.fulfill() }
            do {
            let tasks = try await sut.readTasks()
            
            XCTAssertEqual(tasks, [
                taskModel(from: taskItem1_1)
            ])
            } catch {
                XCTFail("Expected task items, but got \(error)")
            }
            
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    // Mark: - Helpers
    
    fileprivate func createSUT(storeURL: URL = URL(fileURLWithPath: "/dev/null"), tasksListId: UUID = UUID()) -> (TaskItemRepository, NSManagedObjectContext) {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = createPersistanceStoreCoordinator(storeUrl: storeURL)
        let sut = TaskItemRepository(context: managedObjectContext, tasksListId: tasksListId)
        
        trackMemoryLeak(sut)
        trackMemoryLeak(managedObjectContext)
        
        return (sut, managedObjectContext)
    }
    
    fileprivate func createTasksList(id: UUID = UUID(), name: String = "Tasks List", inContext context: NSManagedObjectContext) -> TasksList {
        let tasksList = TasksList(context: context)

        context.performAndWait {
            tasksList.id = id.uuidString
            tasksList.createdAt = Date.now
            tasksList.name = name
            tasksList.tasksListType = 1

            try! context.save()
        }
        
        return tasksList
    }
    
    fileprivate func taskModel(from taskItem: TaskItem) -> TaskModel {
        return TaskModel(id: UUID(uuidString: taskItem.id!)!, name: taskItem.name!, createdAt: taskItem.createdAt!, type: .airplane)
    }
    
    fileprivate func createTaskItem(forTaskslist tasksList: TasksList, id: UUID = UUID(), name: String = "Tasks List", inContext context: NSManagedObjectContext) -> TaskItem {
        let taskItem = TaskItem(context: context)

        context.performAndWait {
            taskItem.id = id.uuidString
            taskItem.createdAt = Date.now
            taskItem.name = name
            taskItem.taskList = tasksList

            try! context.save()
        }
        
        return taskItem
    }
}
