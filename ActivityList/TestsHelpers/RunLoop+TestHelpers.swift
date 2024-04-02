//
//  RunLoop+TestHelpers.swift
//  ActivityList
//
//  Created by Maksim Linich on 2.04.24.
//

import Foundation

public extension RunLoop {
    func runForDistanceFuture() {
        RunLoop.current.run(until: Date.init(timeIntervalSinceNow: 0.002))
    }
}
