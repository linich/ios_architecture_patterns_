//
//  SharedTestHelper.swift
//  ActivityList
//
//  Created by Maksim Linich on 1.04.24.
//

import Foundation

func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0)
}

func anyURL() -> URL {
    return URL(string: "http://any-url.com")!
}

func anyDate() -> Date {
    return Date.now
}

func anyUUID() -> UUID {
    return UUID()
}
