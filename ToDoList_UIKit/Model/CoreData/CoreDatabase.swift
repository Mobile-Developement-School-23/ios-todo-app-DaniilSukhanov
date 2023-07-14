//
//  CoreDatabase.swift
//  ToDoList_UIKit
//
//  Created by Даниил Суханов on 13.07.2023.
//

import Foundation
import CoreData
import UIKit
import OSLog

final class CoreDatabase: ObjDatabase {
    let container: NSPersistentContainer
    fileprivate let logger = Logger(category: String(describing: CoreDatabase.self))
    
    init() {
        let container = NSPersistentContainer(name: "DataModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        self.container = container
    }
    
    func getItems() -> [TodoItem] {
        do {
            return try container.viewContext.fetch(DCTodoItem.fetchRequest()).compactMap {
                TodoItem.parse(coreDataObj: $0)
            }
        } catch {
            logger.info("\(String.logFormat()) не удалось получить данные: \(error)")
            return .init()
        }
    }
    
    func insert(_ item: TodoItem) throws {
        let request = DCTodoItem.fetchRequest()
        request.predicate = .init(format: "id = %@", item.id)
        do {
            if try container.viewContext.fetch(request).count != 0 {
                throw DatabaseError.sameID
            }
        } catch {
            logger.info("\(String.logFormat()) не удалось выполнить команду: \(error)")
            throw DatabaseError.sameID
        }
        _ = item.getCoreDataObj(context: container.viewContext)
        do {
            try container.viewContext.save()
        } catch {
            logger.info("\(String.logFormat()) не удалось сохранить: \(error)")
        }
    }
    
    func update(_ item: TodoItem) {
        let request = DCTodoItem.fetchRequest()
        request.predicate = .init(format: "id = %@", item.id)
        let items: [DCTodoItem]
        do {
            items = try container.viewContext.fetch(request)
        } catch {
            logger.info("\(String.logFormat()) не удалось выполнить команду: \(error)")
            return
        }
        if items.isEmpty {
            return
        }
        let updateItem = items.first!
        updateItem.changedDate = item.changedDate
        updateItem.deadline = item.deadline
        updateItem.importance = .init(item.importance.rawValue)
        updateItem.text = item.text
        updateItem.isMake = item.isMake
        do {
            try container.viewContext.save()
        } catch {
            logger.info("\(String.logFormat()) не удалось сохранить: \(error)")
        }
    }
    
    func delete(_ item: TodoItem) {
        delete(item.id)
    }
    
    func delete(_ id: String) {
        let request = DCTodoItem.fetchRequest()
        request.predicate = .init(format: "id = %@", id)
        let list: [DCTodoItem]
        do {
            list = try container.viewContext.fetch(request)
        } catch {
            logger.info("\(String.logFormat()) не удалось выполнить команду: \(error)")
            return
        }
        if list.count == 0 {
            return
        }
        container.viewContext.delete(list[0])
        do {
            try container.viewContext.save()
        } catch {
            logger.info("\(String.logFormat()) не удалось сохранить: \(error)")
        }
        
    }
}
