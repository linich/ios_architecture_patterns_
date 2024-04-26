//
//  ImageServiceStub.swift
//  ActivityListDomainTests
//
//  Created by Maksim Linich on 26.04.24.
//

import ActivityListDomain

internal class ImageServiceStub: ImageServiceProtocol {
    typealias Image = Int
    typealias ImageKind = ActivityType
    
    func getImage(byKind kind: ActivityType) -> Int {
        return kind.hashValue
    }
}
