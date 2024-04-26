//
//  TaskItemsServiceTests.swift
//  ActivityListDomainTests
//
//  Created by Maksim Linich on 26.04.24.
//

import XCTest
import ActivityListDomain

struct TaskItemsService<Image, T: TaskItemRepositoryProtocol, IS: ImageServiceProtocol>: TaskItemsServiceProtocol where IS.Image == Image, IS.ImageKind == ActivityType {
    
    private let taskListId: UUID
    private let taskItemRepository: T
    private let imageService: IS
    public init(taskListId: UUID, taskItemRepository: T, imageService: IS) {
        self.taskListId = taskListId
        self.taskItemRepository = taskItemRepository
        self.imageService = imageService
    }
    
    func readTaskItems() async throws -> [ActivityListDomain.TaskItemInfo<Image>] {
        do {
            return try await self.taskItemRepository.readTasksOfTasksList(withId: taskListId).map {
                TaskItemInfo<Image>(
                    id: $0.id,
                    name: $0.name,
                    done: true,
                    type: $0.type,
                    icon: imageService.getImage(byKind: $0.type))
            }
        } catch {
            throw error
        }
    }
}

final class TasksItemsServiceTests: XCTestCase {
    fileprivate typealias SutType = TaskItemsService<Int, TaskItemsRepositoryStub, ImageServiceStub>
    func tests_init_shouldNotCalTasksListRepositoryMethods() {
        let (_, stub, _) = makeSUT()
        
        XCTAssertEqual(stub.readTasksOfTasksListCallCount, 0, "Service should not call read tasks of tasks list method")
        XCTAssertEqual(stub.insertTaskRequestCallCount, 0, "Service should not call insert task method")
    }
    
    
    func test_readTasksItems_shouldReturnTaskItems() {
        let taskListId = UUID()
        let (sut, repositoryStub, imageStub) = makeSUT(taskListId: taskListId)
        
        let exp = expectation(description: "Loading task items")
        let taskItem1 = TaskItemInfo<Int>(id: UUID(), name: "name 1", done: true, type:.gym, icon: imageStub.getImage(byKind: .gym))
        
        let expected = [taskItem1]
        Task {
            defer {exp.fulfill()}
            do {
                let result = try await sut.readTaskItems()
                XCTAssertEqual(result, expected, "Expected to receive valid task items")
            } catch {
                XCTFail("Expected items, but got \(error) instead")
            }
        }
        RunLoop.current.runForDistanceFuture()
        repositoryStub.completeReadTasks(with: [TaskModel(id: taskItem1.id, name:taskItem1.name, createdAt: Date(), type: taskItem1.type)])
        
        wait(for: [exp], timeout: 1.0)
        
        let (actualTaskListId) = repositoryStub.readTasksArguments[0]
        XCTAssertEqual(actualTaskListId, taskListId, "Expected to pass valid tasks list id to the repository")
    }
    
    //Mark: - Helpers
    
    fileprivate func makeSUT(taskListId: UUID = UUID(), file: StaticString = #file, line: UInt = #line) -> (SutType, TaskItemsRepositoryStub, ImageServiceStub){
        let stub = TaskItemsRepositoryStub()
        let imageStub = ImageServiceStub()
        let sut = SutType(taskListId: taskListId, taskItemRepository: stub, imageService: imageStub)
        
        trackMemoryLeak(stub)
        trackMemoryLeak(imageStub)
        
        return ( sut, stub, imageStub)
    }
}

fileprivate class TaskItemsRepositoryStub: TaskItemRepositoryProtocol {
    private var readTasksOfTasksListRequests = [CompletionHolder<Result<[TaskModel], Error>>]()
    public var readTasksArguments = Array<(UUID)>()
    private var insertTaskRequests = [CompletionHolder<Result<(), Error>>]()
    
    public var readTasksOfTasksListCallCount: Int { return readTasksOfTasksListRequests.count }
    public var insertTaskRequestCallCount: Int { return insertTaskRequests.count }
    
    func completeReadTasks(with tasks: [TaskModel], at index: Int = 0) {
        readTasksOfTasksListRequests[index].completion!(.success(tasks))
    }
    
    func readTasksOfTasksList(withId tasksListId: UUID) async throws -> [TaskModel] {
        let completionHolder = CompletionHolder<Result<[TaskModel], Error>>(completion: nil)
        readTasksOfTasksListRequests.append(completionHolder)
        readTasksArguments.append((tasksListId))
        
        return try await withCheckedThrowingContinuation { continuation in
            completionHolder.completion =  { result in
                switch result {
                case let .success(items):
                    continuation.resume(returning:items)
                case let .failure(error):
                    continuation.resume(throwing: error)
                }
                
            }
        }
    }
    
    func insert(task: TaskModel, tasksListId: UUID) async throws {
        let completionHolder = CompletionHolder<Result<(), Error>>(completion: nil)
        insertTaskRequests.append(completionHolder)
        
        return try await withCheckedThrowingContinuation { continuation in
            completionHolder.completion =  { result in
                switch result {
                case .success:
                    continuation.resume(returning:())
                case let .failure(error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}


extension TaskItemInfo: Equatable where Image == Int{
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.done == rhs.done &&
        lhs.icon == rhs.icon
    }
}
