//
//  Database.swift
//  ToDoList_UIKit
//
//  Created by Даниил Суханов on 11.07.2023.
//

import Foundation
import SQLite
import OSLog

enum DatabaseError: Error {
    case sameID
}

final class Database {
    private let db: Connection
    static let nameTable = "TodoItem"
    static let baseDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    fileprivate let logger = Logger(category: String(describing: Database.self))
    let url: URL
    
    init(_ name: String, filepath: URL = Database.baseDirectory) {
        url = filepath.appending(component: name)
        logger.info("\(String.logFormat()) Подключение к базе данных: \(self.url.path())")
        db = try! Connection(url.path())
        try? createTables()
    }
    
    private func createTables() throws {
        try db.run(
            Table(Database.nameTable).create { table in
                table.column(Expression<String>("id"), primaryKey: true)
                table.column(Expression<String>("text"))
                table.column(Expression<Int>("importance"))
                table.column(Expression<Double?>("deadline"))
                table.column(Expression<Int>("isMake"))
                table.column(Expression<Double>("createdDate"))
                table.column(Expression<Double?>("changedDate"))
            }
        )
    }
    
    func getItems() -> [TodoItem] {
        var result = [TodoItem]()
        logger.info("\(String.logFormat()) получение данных")
        do {
            for row in try db.prepare(Table(Database.nameTable)) {
                guard let item = TodoItem.parse(sql: row) else {
                    logger.debug("\(String.logFormat()) не удалось преобразовать item")
                    continue
                }
                result.append(item)
            }
        } catch {
            logger.debug("\(String.logFormat()) произошла ошибка! error: \(error)")
        }
        return result
    }
    
    func insert(_ item: TodoItem) throws {
        let request = "INSERT INTO \(Database.nameTable) \(TodoItem.titlesSqlite) VALUES \(item.sqlReplaceStatement)"
        logger.info("\(String.logFormat()) добавление нового элемента")
        do {
            try db.prepare(request).run()
        } catch {
            logger.debug(
                "\(String.logFormat()) Не удалось добавить предмет \(item.sqlReplaceStatement), так как произошла ошибка: \(error.localizedDescription)"
            )
            throw DatabaseError.sameID
        }
    }
    
    func update(_ item: TodoItem) {
        let set = zip(TodoItem.titles, item.getValues()).map {
            "\($0.0) = \($0.1)"
        }.joined(separator: ", ")
        logger.info("\(String.logFormat()) обновление элемента")
        let request = """
        UPDATE \(Database.nameTable)
        SET \(set)
        WHERE id = "\(item.id)"
        """
        try! db.prepare(request).run()
    }
    
    func delete(_ item: TodoItem) {
        delete(item.id)
    }
    
    func delete(_ id: String) {
        logger.info("\(String.logFormat()) удаление элемента")
        let request = """
        DELETE FROM \(Database.nameTable)
        WHERE id = "\(id)"
        """
        try! db.prepare(request).run()
    }
    
}
