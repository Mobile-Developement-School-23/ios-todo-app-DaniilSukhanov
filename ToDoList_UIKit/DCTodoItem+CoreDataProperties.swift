//
//  DCTodoItem+CoreDataProperties.swift
//  ToDoList_UIKit
//
//  Created by Даниил Суханов on 14.07.2023.
//
//

import Foundation
import CoreData

extension DCTodoItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DCTodoItem> {
        return NSFetchRequest<DCTodoItem>(entityName: "DCTodoItem")
    }

    @NSManaged public var changedDate: Date?
    @NSManaged public var createdDate: Date
    @NSManaged public var deadline: Date?
    @NSManaged public var id: String
    @NSManaged public var importance: Int16
    @NSManaged public var isMake: Bool
    @NSManaged public var text: String

}

extension DCTodoItem : Identifiable {

}
