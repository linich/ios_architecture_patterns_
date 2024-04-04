//
//  ActivityListDataLayerTests.swift
//  ActivityListDataLayerTests
//
//  Created by Maksim Linich on 28.03.24.
//

import XCTest
import CoreData
import ActivityListDomain
import ActivityListDataLayer

final class TasksListRepositoryTests: XCTestCase {
    
    func test_readTasksList_returnsEmptyListOnCleanDb() {
        let sut = createSUT()
        
        expect(sut, toRetreive: [])
    }
    
    func test_readTasksList_hasNoSideEffectOnCleanDb() {
        let sut = createSUT()
        
        assertThatReadTasksListHasNoSideEffectCleanDb(sut)
    }
    
    func test_readTasksList_deliverResultOnNonEmptyDb() {
        
        let tasksListCreationDate = Date.now
        let sut = createSUT()
        let tasksListId = UUID()
        
        insertTasksList(
            withId: tasksListId,
            name: "name1",
            createdAt: tasksListCreationDate,
            type: .airplane,
            into: sut
        )
        
        expect(sut, toRetreive: [TasksListModel(id: tasksListId, name: "name1", createdAt: tasksListCreationDate, type: .airplane)])
        
    }
    // Mark: - Helpers
    
    fileprivate func createSUT(storePath: String = "/dev/null") -> TasksListRepositoryProtocol {
        let coordinator = createPersistanceStoreCoordinator(storeUrl: URL(fileURLWithPath: storePath))
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
        return TasksListRepository(context: context)
    }
    
    fileprivate func insertTasksList(withId id: UUID, name: String, createdAt: Date = Date.now, type: TasksListModel.TasksListType, into  sut: TasksListRepositoryProtocol) {
        let exp = expectation(description: "Wait for create tasks list")
        Task {
            defer { exp.fulfill() }
            do {
                try await sut.insertTasksList(withId: id, name: name,createdAt: createdAt, type: type)
            }
            catch {
                XCTFail("Expected insert successfully, but got \(error)")
            }
        }
        
        wait(for: [exp], timeout:  1.0)
    }

    fileprivate func expect(_ sut: TasksListRepositoryProtocol, toRetreive expectedResult: [TasksListModel], file: StaticString = #filePath, line: UInt = #line) {
        
        let exp = expectation(description: "Loading taks lists")
       
        Task {
            defer { exp.fulfill() }
            do {
                let actualTasksList = try await sut.readTasksLists()
                XCTAssertEqual(actualTasksList, expectedResult, file: file, line: line)
            } catch {
                XCTFail("Expect list of tasks, but go \(error)")
            }
        }
        
        RunLoop.current.runForDistanceFuture()
                
        wait(for: [exp], timeout: 1.0)
    }
    
    fileprivate func assertThatReadTasksListHasNoSideEffectCleanDb(_ sut: TasksListRepositoryProtocol, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetrieveTwice: [])
    }
    
    func expect(_ sut: TasksListRepositoryProtocol, toRetrieveTwice expected: [TasksListModel], file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetreive: expected)
        expect(sut, toRetreive: expected)
    }
}

extension TasksListModel: Equatable {
    public static func == (lhs: ActivityListDomain.TasksListModel, rhs: ActivityListDomain.TasksListModel) -> Bool {
        return lhs.name == rhs.name &&
        lhs.createdAt == rhs.createdAt &&
        lhs.id == rhs.id &&
        lhs.type == rhs.type
    }
}
