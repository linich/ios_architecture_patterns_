//
//  ErrorProneStore.swift
//  ActivityListDataLayerTests
//
//  Created by Maksim Linich on 5.04.24.
//

import Foundation
import CoreData

internal let ErrorProneStoreType = NSPersistentStore.StoreType(rawValue: "ActivityListDataLayerTests.ErrorProneStore")

internal class ErrorProneStore: NSIncrementalStore {
    override func loadMetadata() throws {
        let data = [
            NSStoreTypeKey: ErrorProneStoreType.rawValue,
            NSStoreUUIDKey: ""
            
        ]
        metadata = data
    }
    
    func createError() -> Error  {
         return NSError(domain: NSCocoaErrorDomain, code: NSPersistentStoreOperationError, userInfo: nil)
    }
    
    override func execute(_ request: NSPersistentStoreRequest, with context: NSManagedObjectContext?) throws -> Any {
        throw createError()
    }
    
    override func newValuesForObject(with objectID: NSManagedObjectID, with context: NSManagedObjectContext) throws -> NSIncrementalStoreNode {
        throw createError()
    }
    
    override func newValue(forRelationship relationship: NSRelationshipDescription, forObjectWith objectID: NSManagedObjectID, with context: NSManagedObjectContext?) throws -> Any {
        throw createError()
    }
    
    override func obtainPermanentIDs(for array: [NSManagedObject]) throws -> [NSManagedObjectID] {
        throw createError()
    }
}
