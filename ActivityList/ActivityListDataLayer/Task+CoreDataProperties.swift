//
//  Task+CoreDataProperties.swift
//  ActivityListDataLayer
//
//  Created by Maksim Linich on 25.03.24.
//
//

import Foundation
import CoreData


extension Task {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Task> {
        return NSFetchRequest<Task>(entityName: "Task")
    }

    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var icon: String?
    @NSManaged public var taskList: TaskList?

}

extension Task : Identifiable {

}
