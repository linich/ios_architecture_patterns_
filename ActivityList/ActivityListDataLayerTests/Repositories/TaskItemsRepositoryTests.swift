//
//  TaskItemsRepositoryTests.swift
//  ActivityListDomainTests
//
//  Created by Maksim Linich on 2.04.24.
//

import XCTest
import CoreData
import ActivityListDomain
@testable import ActivityListDataLayer


public enum TaskItemRepositoryError: Error {
    case ReadTaskItems
}

class TaskItemRepository {
    private let context: NSManagedObjectContext
    
    public init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func readTasksOfTasksList(withId tasksListId: UUID) async throws -> [TaskModel] {
        do {
            return try await withCheckedThrowingContinuation { continuation in
                self.context.perform {
                    let taskItemsRequest = TaskItem.fetchRequest()
                    taskItemsRequest.predicate = NSPredicate(format: "%K.id == %@", #keyPath(TaskItem.taskList), tasksListId.uuidString as CVarArg)
                    do {
                        let result = try self.context.fetch(taskItemsRequest)
                        let taskItems = result.map({
                            guard
                                let itemId = $0.id,
                                let name = $0.name,
                                let id = UUID(uuidString: itemId),
                                let createdAt = $0.createdAt,
                                let type = ActivityTypeInner(rawValue: $0.taskType)?.toDomainType() else {
                                return nil as TaskModel?
                            }
                            return TaskModel(id: id, name: name, createdAt: createdAt, type: type)
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
    
    func insertTask(withId id: UUID, name: String, type: ActivityType, createdAt: Date, tasksListId: UUID) async throws -> Void {
        do {
            return try await withCheckedThrowingContinuation { continuation in
                self.context.perform {
                    let tasksListRequest = TasksList.fetchRequest()
                    let tasksList = try! self.context.fetch(tasksListRequest).first
                    
                    let taskItem = TaskItem(context: self.context)
                    
                    taskItem.id = id.uuidString
                    taskItem.name = name
                    taskItem.createdAt = createdAt
                    taskItem.taskType = ActivityTypeInner.from(activityType: type).rawValue
                    taskItem.taskList = tasksList
                    do {
                        try self.context.save()
                        continuation.resume(returning: ())
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
        
        assert(sut, receivesTasks: [], ofTasksListWithId: UUID())
    }

    func test_readTasks_returnsTasksUseOnlyOneTasksList() {
        let parentId = UUID()
        let (sut, context) = createSUT()

        let tasksList1 = createTasksList(id: parentId, name: "tasks list 1", inContext: context)
        let taskItem1_1 = createTaskItem(forTaskslist: tasksList1, inContext: context)
        
        assert(sut, receivesTasks: [
            taskModel(from: taskItem1_1)
        ], ofTasksListWithId: parentId)
    }
    
    func test_readTasks_returnsValidTasksWhenMultipleTasksListExists() {
        let parentId = UUID()
        let (sut, context) = createSUT()
        let tasksList1 = createTasksList(name: "tasks list 1", inContext: context)
        let tasksList2 = createTasksList(id: parentId, name: "tasks list 2", inContext: context)
        
        insertTaskInto(sut, withId: UUID(), name: "name 1", type: .american_football, createdAt: Date.now, tasksListId: UUID())
        
        let taskItem2_1 = createTaskItem(forTaskslist: tasksList2, inContext: context)
        let taskItem2_2 = createTaskItem(forTaskslist: tasksList2, inContext: context)
        
        assert(sut, receivesTasks: [
            taskModel(from: taskItem2_1),
            taskModel(from: taskItem2_2),
        ], ofTasksListWithId: parentId)
    }
    
    func test_insert_readTaskItemAfterInsertion() {
        for type in ActivityType.allCases {
            let parentId = UUID()
            let (sut, context) = createSUT()
            
            createTasksList(id: parentId, name: "tasks list 1", inContext: context)
            
            
            let taskId = UUID()
            let createdAt = Date.now
            let taskName = "task name 1"
            
            insertTaskInto(sut, withId: taskId, name: taskName, type: type, createdAt: createdAt, tasksListId: parentId)
            
            let expectedTasks = [TaskModel(id: taskId, name: "task name 1", createdAt: createdAt, type: type)]
            
            assert(sut, receivesTasks: expectedTasks, ofTasksListWithId: parentId)
        }
    }

    
    // Mark: - Helpers
    
    fileprivate func createSUT(storeURL: URL = URL(fileURLWithPath: "/dev/null")) -> (TaskItemRepository, NSManagedObjectContext) {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = createPersistanceStoreCoordinator(storeUrl: storeURL)
        let sut = TaskItemRepository(context: managedObjectContext)
        
        trackMemoryLeak(sut)
        trackMemoryLeak(managedObjectContext)
        
        return (sut, managedObjectContext)
    }
    
    fileprivate func assert(_ sut: TaskItemRepository, receivesTasks expected: [TaskModel], ofTasksListWithId tasksListId: UUID, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Loading task items")
        Task {
            defer { exp.fulfill() }
            do {
                let tasks = try await sut.readTasksOfTasksList(withId: tasksListId)
                XCTAssertEqual(tasks, expected, "Actual tasks \(String(describing: tasks)) not equal to expected tasks \(expected)", file: file, line: line)
            } catch {
                XCTFail("Expected task items, but got \(error)")
            }
        }
        
        wait(for: [exp], timeout: 1.0)
    }

    fileprivate func insertTaskInto(_ sut: TaskItemRepository, withId id: UUID, name: String, type: ActivityType, createdAt: Date, tasksListId: UUID) {
        let exp = expectation(description: "Insert task item")
        Task {
            defer { exp.fulfill()}
            do {
                try await sut.insertTask(withId:id,
                                         name:name,
                                         type: type,
                                         createdAt: createdAt,
                                         tasksListId: tasksListId)
            } catch {
                XCTFail("Expected to not throw expection, but got \(error)")
            }
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    @discardableResult
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
    
    @discardableResult
    fileprivate func createTaskItem(forTaskslist tasksList: TasksList, id: UUID = UUID(), name: String = "Tasks List", inContext context: NSManagedObjectContext) -> TaskItem {
        let taskItem = TaskItem(context: context)

        context.performAndWait {
            taskItem.id = id.uuidString
            taskItem.createdAt = Date.now
            taskItem.name = name
            taskItem.taskList = tasksList
            taskItem.taskType = ActivityTypeInner.airplane.rawValue

            try! context.save()
        }
        
        return taskItem
    }
}

extension TaskModel: Equatable {
    public static func == (lhs: ActivityListDomain.TaskModel, rhs: ActivityListDomain.TaskModel) -> Bool {
        return lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.createdAt == rhs.createdAt &&
        lhs.type == rhs.type
    }
    
    
}
