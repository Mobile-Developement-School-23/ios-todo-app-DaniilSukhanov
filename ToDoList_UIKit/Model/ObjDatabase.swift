//
//  ObjDatabase.swift
//  ToDoList_UIKit
//
//  Created by Даниил Суханов on 13.07.2023.
//

import Foundation

protocol ObjDatabase {
    init()
    func getItems() -> [TodoItem]
    func insert(_ item: TodoItem) throws
    func update(_ item: TodoItem)
    func delete(_ item: TodoItem)
    func delete(_ id: String)
}
