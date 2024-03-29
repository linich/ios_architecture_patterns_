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
    
    func test_read_fromEmptyReturnsEmptyList() {
        let sut = createSUT()
        
        var actual: [TasksListModel]? = nil
        
        let exp = expectation(description: "Loading taks list expectation")
        sut.readTasksLists {  result in
            switch result {
            case let .success(items):
                actual = items
            case let .failure(error):
                XCTFail("Expected success result, but got \(error) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(actual, [], "Expected empty tasks list")
    }
    
    
    // Mark: - Helpers
    
    fileprivate func createSUT(storePath: String = "/dev/null") -> TasksListRepositoryProtocol {
        let coordinator = createPersistanceStoreCoordinator(storeUrl: URL(fileURLWithPath: storePath))
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
        return TasksListRepository(context: context)
    }
    
    fileprivate func createPersistanceStoreCoordinator(storeUrl: URL) -> NSPersistentStoreCoordinator {
        
            let bundle = Bundle(for: TasksListRepository.self)
            guard let modelURL = bundle.url(forResource: "ActivityList",
                                                 withExtension: "momd") else {
                fatalError("Failed to find data model")
            }
            
            guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
                fatalError("Failed to create model from file: \(modelURL)")
            }
            
            let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
            do {
                _ = try coordinator.addPersistentStore(
                    type: .sqlite,
                    at: storeUrl,
                    options: nil)
            } catch {
                fatalError("Failed to add persistent store: \(error.localizedDescription)")
            }
            
            return coordinator
    }
}

extension TasksListModel: Equatable {
    public static func == (lhs: ActivityListDomain.TasksListModel, rhs: ActivityListDomain.TasksListModel) -> Bool {
        return lhs.name == rhs.name &&
        lhs.createdAt == rhs.createdAt &&
        lhs.id == rhs.id &&
        lhs.type == rhs.type &&
        lhs.tasks == rhs.tasks
    }
}

extension TaskModel: Equatable {
    public static func == (lhs: ActivityListDomain.TaskModel, rhs: ActivityListDomain.TaskModel) -> Bool {
        return lhs.id == rhs.id &&
        lhs.createdAt == rhs.createdAt &&
        lhs.name == rhs.name &&
        lhs.type == rhs.type
    }
    
    
}
