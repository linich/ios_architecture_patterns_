//
//  XCTestCase+ErrorChecking.swift
//  ActivityListDataLayerTests
//
//  Created by Maksim Linich on 5.04.24.
//

import XCTest

extension XCTestCase {
    func expect<E: Error & Equatable>(receiveError expectedError: E, onAction action: @escaping () async throws -> (Void), file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Loading tasks list")
        Task {
            defer { exp.fulfill() }
            
            do {
                try await action()
                XCTFail("Expected receive an error \(expectedError), but got result instead.", file: file, line: line)
            } catch let error as E {
                XCTAssertEqual(error,  expectedError, file: file, line: line)
            } catch {
                XCTFail("Expected reveive TasksListRepositoryError error, but got \(error) instead", file: file, line: line)
            }
        }
        wait(for: [exp], timeout: 1.0)
    }
}
