//
//  XCTest+Helpers.swift
//  ActivityListUITests
//
//  Created by Maksim Linich on 28.03.24.
//

import XCTest

extension XCTestCase {
     func trackMemoryLeak(_ object: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        self.addTeardownBlock { [weak object] in
            XCTAssertNil(object, "Memory leak issue", file: file, line: line)
        }
    }
}
