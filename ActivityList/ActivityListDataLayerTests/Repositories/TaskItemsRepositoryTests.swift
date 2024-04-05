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

final class TaskItemsRepositoryTests: XCTestCase {
    
    override class func setUp() {
        NSPersistentStoreCoordinator.registerStoreClass(ErrorProneStore.self, forStoreType: ErrorProneStoreType.rawValue)
    }

    func test_readTasks_returnsEmptyTasksListOnEmptyData() {
        let (sut, _) = createSUT()
        
        assert(sut, receivesTasks: [], ofTasksListWithId: UUID())
    }

    func test_readTasks_returnsTasksWhenOnlyOneTasksListExists() {
        let (sut, context) = createSUT()

        let tasksListId = anyUUID()
        createTasksList(id: tasksListId, name: "tasks list 1", inContext: context)

        let taskId = UUID()
        let createdAt = Date.init(timeIntervalSince1970: 100)
        let task = TaskModel(id: taskId, name: "Task Name", createdAt: createdAt, type: .american_football)
        
        insert(task: task, into: sut, tasksListId: tasksListId)

        let expectedTasks = [
            TaskModel.init(id: taskId, name: "Task Name", createdAt: createdAt, type: .american_football)
        ]
        assert(sut, receivesTasks: expectedTasks, ofTasksListWithId: tasksListId)
    }
    
    func test_readTasks_returnsValidTasksWhenMultipleTasksListsExists() {
        
        let (sut, context) = createSUT()

        let tasksListId1 = anyUUID()
        let tasksListId2 = anyUUID()
        createTasksList(id: tasksListId2, name: "tasks list 1", inContext: context)
        createTasksList(id: tasksListId1, name: "tasks list 2", inContext: context)
        
        
        insert(task: TaskModel(id: anyUUID(), name: "name 1", createdAt: anyDate(), type: .american_football), into: sut, tasksListId: tasksListId2)
        
        let taskId1 = anyUUID()
        let taskId2 = anyUUID()
        let createdAt = anyDate()
        
        insert(task: TaskModel(id: taskId1, name: "name 1", createdAt: createdAt, type: .airplane), into: sut, tasksListId: tasksListId1)

        insert(task: TaskModel(id: taskId2, name: "name 2", createdAt: createdAt, type: .game), into: sut, tasksListId: tasksListId1)

        assert(sut, receivesTasks: [
            TaskModel(id: taskId1, name: "name 1", createdAt: createdAt, type: .airplane),
            TaskModel(id: taskId2, name: "name 2", createdAt: createdAt, type: .game),
        ], ofTasksListWithId: tasksListId1)
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
                
        expect(receiveError: TaskItemRepositoryError.InsertTaskItem) {
            let task = TaskModel(id: anyUUID(), name: "name",
                                 createdAt: anyDate(), type: .fight)
            try await sut.insert(task: task, tasksListId: anyUUID())
        }
    }
    
    func test_insert_throwsAnErrorIfCoreDateThrowError() {
        let (sut, _) = createSUT(storeType: ErrorProneStoreType)
        
        
        expect(receiveError: TaskItemRepositoryError.InsertTaskItem) {
            let task = TaskModel(id: anyUUID(), name:"name",
                                 createdAt: anyDate(), type: .fight)
            try await sut.insert(task: task, tasksListId: anyUUID())
        }
    }
    
    func test_readTaskItems_throwsAnErrorIfCoreDateThrowError() {
        let (sut, _) = createSUT(storeType: ErrorProneStoreType)
        
        
        expect(receiveError: TaskItemRepositoryError.ReadTaskItems) {
            let _ = try await sut.readTasksOfTasksList(withId: anyUUID())
        }
    }
    
    func test_readTaskItems_deliverTaskItemsWithoutItemWithInvalidUUID() {
        let (sut, context) = createSUT()
        
        let tasksListId = anyUUID()
        let tasksList = createTasksList(id: tasksListId, name: "tasks list 1", inContext: context)
        let taskItem = TaskItem(context: context)
        taskItem.id = "invalid_id"
        taskItem.taskList = tasksList
        
        try! context.save()

        let taskModel = anyTaskModel()
        insert(task: taskModel, into: sut, tasksListId: tasksListId)
        
        assert(sut, receivesTasks: [taskModel], ofTasksListWithId: tasksListId)
    }
    
    func test_readTaskItems_deliverTaskItemWithoutItemWithInvalidType() {
        let (sut, context) = createSUT()
        
        let tasksListId = anyUUID()
        let tasksList = createTasksList(id: tasksListId, name: "tasks list 1", inContext: context)
        let taskItem = TaskItem(context: context)
        taskItem.id = anyUUID().uuidString
        taskItem.taskList = tasksList
        taskItem.taskType = Int16.max
        
        try! context.save()

        let taskModel = anyTaskModel()
        insert(task: taskModel, into: sut, tasksListId: tasksListId)
        
        assert(sut, receivesTasks: [taskModel], ofTasksListWithId: tasksListId)
    }
    
    // Mark: - Helpers
    
    fileprivate func createSUT(storeURL: URL = URL(fileURLWithPath: "/dev/null"), storeType: NSPersistentStore.StoreType = .inMemory) -> (TaskItemRepositoryProtocol, NSManagedObjectContext) {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = createPersistanceStoreCoordinator(storeUrl: storeURL, storeType: storeType)
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

    fileprivate func anyTaskModel() -> TaskModel {
        return TaskModel(id: anyUUID(), name: "name \(UUID().uuidString)", createdAt: Date.now, type: .fight)
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
