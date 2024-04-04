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
    case ReadTaskItems(Error)
    case InsertTaskItem(Error)
}

protocol TaskItemRepositoryProtocol {
    func readTasksOfTasksList(withId tasksListId: UUID) async throws -> [TaskModel]
    func insert(task: TaskModel, tasksListId: UUID) async throws -> Void
}

class TaskItemRepository: TaskItemRepositoryProtocol {
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
                        let taskItems = result.map({ $0.toModel()}).compactMap({$0})
                        continuation.resume(returning: taskItems)
                    } catch {
                        continuation.resume(throwing: TaskItemRepositoryError.ReadTaskItems(error))
                    }
                }
            }
        } catch {
            throw error
        }
    }
    
    func insert(task: TaskModel, tasksListId: UUID) async throws -> Void {
        do {
            return try await withCheckedThrowingContinuation { continuation in
                self.context.perform {
                    let tasksListRequest = TasksList.fetchRequest()
                    tasksListRequest.predicate  = NSPredicate(format: "id == %@", tasksListId.uuidString as CVarArg)
                    var tasksList: TasksList? = nil
                    do {
                        tasksList = try self.context.fetch(tasksListRequest).first
                    } catch {
                        continuation.resume(throwing: TaskItemRepositoryError.ReadTaskItems(error))
                    }
                    
                    let taskItem = TaskItem.from(model: task, tasksList: tasksList, inContext: self.context)
                    
                    do {
                        try self.context.save()
                        continuation.resume(returning: ())
                    } catch {
                        continuation.resume(throwing: TaskItemRepositoryError.InsertTaskItem(error as NSError))
                    }
                }
            }
        } catch {
            throw error
        }
    }
}

extension TaskItem {
    func toModel() -> TaskModel? {
        guard
            let itemId = id,
            let name = name,
            let id = UUID(uuidString: itemId),
            let createdAt = createdAt,
            let type = ActivityTypeInner(rawValue: taskType)?.toDomainType() else {
            return nil
        }
        return TaskModel(id: id, name: name, createdAt: createdAt, type: type)
    }
    
    static func from(model: TaskModel, tasksList: TasksList?, inContext context: NSManagedObjectContext) -> TaskItem {
        let taskItem = TaskItem(context: context)
        
        taskItem.id = model.id.uuidString
        taskItem.name = model.name
        taskItem.createdAt = model.createdAt
        taskItem.taskType = ActivityTypeInner.from(activityType: model.type).rawValue
        taskItem.taskList = tasksList
        return taskItem
    }
}

final class TaskItemsRepositoryTests: XCTestCase {
    
    func test_readTasks_returnsEmptyTasksListOnEmptyData() {
        let (sut, _) = createSUT()
        
        assert(sut, receivesTasks: [], ofTasksListWithId: UUID())
    }

    func test_readTasks_returnsTasksWhenOnlyOneTasksListExists() {
        let parentId = anyUUID()
        let (sut, context) = createSUT()

        createTasksList(id: parentId, name: "tasks list 1", inContext: context)
        let taskId = UUID()
        let createdAt = Date.init(timeIntervalSince1970: 100)
        let task = TaskModel(id: taskId, name: "Task Name", createdAt: createdAt, type: .american_football)
        insert(task: task, into: sut, tasksListId: parentId)

        assert(sut, receivesTasks:
            [TaskModel.init(id: taskId, name: "Task Name", createdAt: createdAt, type: .american_football)]
        , ofTasksListWithId: parentId)
    }
    
    func test_readTasks_returnsValidTasksWhenMultipleTasksListsExists() {
        let parentId = anyUUID()
        let tasksListId = anyUUID()
        let (sut, context) = createSUT()
        
        createTasksList(id: tasksListId, name: "tasks list 1", inContext: context)
        createTasksList(id: parentId, name: "tasks list 2", inContext: context)
        
        
        insert(task: TaskModel(id: anyUUID(), name: "name 1", createdAt: anyDate(), type: .american_football), into: sut, tasksListId: tasksListId)
        
        let taskId1 = anyUUID()
        let taskId2 = anyUUID()
        let createdAt = anyDate()
        
        insert(task: TaskModel(id: taskId1, name: "name 1", createdAt: createdAt, type: .airplane), into: sut, tasksListId: parentId)

        insert(task: TaskModel(id: taskId2, name: "name 2", createdAt: createdAt, type: .game), into: sut, tasksListId: parentId)

        assert(sut, receivesTasks: [
            TaskModel(id: taskId1, name: "name 1", createdAt: createdAt, type: .airplane),
            TaskModel(id: taskId2, name: "name 2", createdAt: createdAt, type: .game),
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
            
            insert(task: TaskModel(id: taskId, name: taskName, createdAt: createdAt, type: type), into: sut, tasksListId: parentId)
            
            let expectedTasks = [TaskModel(id: taskId, name: "task name 1", createdAt: createdAt, type: type)]
            
            assert(sut, receivesTasks: expectedTasks, ofTasksListWithId: parentId)
        }
    }

    func test_insert_throwsAnErrorIfTasksListNotExist() {
        let (sut, _) = createSUT()
        
        let exp = expectation(description: "Insert task item")
        Task {
            defer { exp.fulfill()}
            do {
                let task = TaskModel(id: anyUUID(), name:name,
                                     createdAt: anyDate(), type: .fight)
                try await sut.insert(task: task, tasksListId: anyUUID())
                XCTFail("Expected to fail, but finish without error")
            } catch let error as TaskItemRepositoryError {
                switch error {
                case .InsertTaskItem:
                    break;
                default:
                    XCTFail("Expected TaskItemRepositoryError.InsertTaskItem error, but got error \(error)")
                }
                
            } catch {
                XCTFail("Expected TaskItemRepositoryError.InsertTaskItem error, but got error \(error)")
            }

        }
        wait(for: [exp], timeout: 1.0)
    }
    
    
    // Mark: - Helpers
    
    fileprivate func createSUT(storeURL: URL = URL(fileURLWithPath: "/dev/null")) -> (TaskItemRepositoryProtocol, NSManagedObjectContext) {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = createPersistanceStoreCoordinator(storeUrl: storeURL)
        let sut = TaskItemRepository(context: managedObjectContext)
        
        trackMemoryLeak(sut)
        trackMemoryLeak(managedObjectContext)
        
        return (sut, managedObjectContext)
    }
    
    fileprivate func assert(_ sut: TaskItemRepositoryProtocol, receivesTasks expected: [TaskModel], ofTasksListWithId tasksListId: UUID, file: StaticString = #filePath, line: UInt = #line) {
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

    fileprivate func insert(task: TaskModel, into sut: TaskItemRepositoryProtocol, tasksListId: UUID, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Insert task item")
        Task {
            defer { exp.fulfill()}
            do {
                try await sut.insert(task: task, tasksListId: tasksListId)
            } catch {
                XCTFail("Expected to not throw, but got \(error)", file: file, line: line)
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
            tasksList.tasksListType = 0

            try! context.save()
        }
        
        return tasksList
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
