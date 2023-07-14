//
//  TodoItem.swift
//  ToDoList
//
//  Created by Даниил Суханов on 10.06.2023.
//

import Foundation
import OSLog
import SQLite
import CoreData

struct TodoItem: Hashable {
    enum Importance: Int {
        // unimportant - неважная, usual - обычная, important - важная
        case unimportant, usual, important
    }
    
    let id: String
    let text: String
    let importance: Importance
    let deadline: Date?
    let isMake: Bool
    let createdDate: Date
    let changedDate: Date?
    fileprivate static let logger = Logger(category: String(describing: TodoItem.self))
    
    // в такой последовательности должны передавать данные для csv
    static let titles = ["id", "text", "importance", "deadline", "isMake", "createdDate", "changedDate"]
    static let separator = ";"
    
    init(text: String, importance: Importance,
         isMake: Bool, createdDate: Date = .now,
         deadline: Date? = nil, changedDate: Date? = nil, id: String = UUID().uuidString) {
        self.id = id
        self.text = text
        self.importance = importance
        self.deadline = deadline
        self.isMake = isMake
        self.createdDate = createdDate
        self.changedDate = changedDate
    } 

    // Нужно для FileCache
    static func == (obj1: Self, obj2: Self) -> Bool {
        return obj1.id == obj2.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    func modifier(
        text: String? = nil,
        deadline: Date? = nil,
        isMake: Bool? = nil,
        importance: Importance? = nil,
        changedDate: Date? = nil
    ) -> TodoItem {
        TodoItem(
            text: text ?? self.text,
            importance: importance ?? self.importance,
            isMake: isMake ?? self.isMake,
            createdDate: createdDate,
            deadline: deadline ?? self.deadline,
            changedDate: changedDate ?? .now,
            id: id
        )
    }
}

// MARK: -JSON
extension TodoItem {
    static func parse(json: Any) -> TodoItem? {
        guard let json = json as? [String: Any] else {
            return nil
        }
        return toTodoItem(data: json)
    }

    var json: Any {
        toDictionary()
    }

    private static func toTodoItem(data: [String: Any]) -> TodoItem? {
        guard let text = data["text"] as? String else {
            logger.debug("\(String.logFormat()) неудалось получить text")
            return nil
        }
        guard let isMake = data["isMake"] as? Bool else {
            logger.debug("\(String.logFormat()) неудалось получить isMake")
            return nil
        }
        guard let createdDate = data["createdDate"] as? Double else {
            logger.debug("\(String.logFormat()) неудалось получить createdDate")
            return nil
        }
        var importance: Importance
        if data.keys.contains("importance") {
            guard let value = data["importance"] as? Int else {
                logger.debug("\(String.logFormat()) неудалось получить importance")
                return nil
            }
            guard let value = Importance(rawValue: value) else {
                logger.debug("\(String.logFormat()) неудалось получить importance")
                return nil
            }
            importance = value
        } else {
            importance = .usual
        }
        if !data.keys.contains("id") {
            logger.debug("\(String.logFormat()) неудалось получить id")
            return nil
        }
        guard let id = data["id"] as? String else {
            logger.debug("\(String.logFormat()) неудалось получить id")
            return nil
        }
        return TodoItem(
            text: text,
            importance: importance,
            isMake: isMake,
            createdDate: createdDate.toDate(),
            deadline: (data["deadline"] as? Double)?.toDate(),
            changedDate: (data["changedDate"] as? Double)?.toDate(),
            id: id
        )
    }
    
    private func toDictionary() -> [String : Any] {
        var result = [String: Any]()
        result["id"] = id
        result["text"] = text
        if importance != .usual {
            result["importance"] = importance.rawValue
        }
        if let deadline {
            result["deadline"] = deadline.timeIntervalSinceReferenceDate
        }
        result["isMake"] = isMake
        result["createdDate"] = createdDate.timeIntervalSinceReferenceDate
        if let changedDate {
            result["changedDate"] = changedDate.timeIntervalSinceReferenceDate
        }
        return result
    }
}

// MARK: -CSV
extension TodoItem {
    static func parse(csv: String) -> TodoItem? {
        let components = csv.components(separatedBy: TodoItem.separator)
        if components.count < 7 {
            return nil
        }
        let id = components[0]
        let text = components[1]
        let idImportance = Int(components[2])
        if idImportance == nil && components[2] != "" {
            return nil
        }
        let importance = Importance(rawValue: idImportance ?? Importance.usual.rawValue)
        guard let importance else {
            return nil
        }
        let deadline = Double(components[3])?.toDate()
        if !["true", "false"].contains(components[4]) {
            return nil
        }
        let isMake = components[4] == "true" ? true : false
        let createdData = Double(components[5])?.toDate()
        guard let createdData else {
            return nil
        }
        let changedData = Double(components[6])?.toDate()
        return TodoItem(
            text: text,
            importance: importance,
            isMake: isMake,
            createdDate: createdData,
            deadline: deadline,
            changedDate: changedData,
            id: id
        )
    }
    
    var csv: String {
        let dict = toDictionary()
        let data: [String] = TodoItem.titles.map {
            let element = dict[$0]
            var result: String
            if let value = element as? String {
                result = value
            } else if let value = element {
                result = String(describing: value)
            } else {
                result = ""
            }
            return result
        }
        return data.joined(separator: TodoItem.separator)
    }
}

extension Double {
    func toDate() -> Date {
        return Date(timeIntervalSinceReferenceDate: self)
    }
}

// MARK: - SQLite
fileprivate extension String {
    func escape() -> Self {
        return "\"\(self)\""
    }
}

extension TodoItem {
    static let titlesSqlite = "(\(TodoItem.titles.joined(separator: ", ")))"
    var sqlReplaceStatement: String {
        "(\(getValues().joined(separator: ", ")))"
    }
    
    func getValues() -> [String] {
        var result = [String]()
        result.append(id.escape())
        result.append(text.escape())
        result.append(.init(importance.rawValue))
        if let deadline {
            result.append(.init(deadline.timeIntervalSinceReferenceDate))
        } else {
            result.append("NULL")
        }
        result.append(.init(isMake ? 1 : 0))
        result.append(.init(createdDate.timeIntervalSinceReferenceDate))
        if let changedDate {
            result.append(.init(changedDate.timeIntervalSinceReferenceDate))
        } else {
            result.append("NULL")
        }
        return result
    }
    
    static func parse(sql row: Row) -> TodoItem? {
        return .init(
            text: row[Expression<String>("text")],
            importance: Importance(rawValue: row[Expression<Int>("importance")]) ?? .usual,
            isMake: row[Expression<Int>("isMake")] == 0 ? false : true,
            createdDate: row[Expression<Double>("createdDate")].toDate(),
            deadline: row[Expression<Double?>("deadline")]?.toDate(),
            changedDate: row[Expression<Double?>("deadline")]?.toDate(),
            id: row[Expression<String>("id")]
        )
    }
}

// MARK: - CoreData

extension TodoItem {
    static func parse(coreDataObj: DCTodoItem) -> TodoItem? {
        .init(
            text: coreDataObj.text,
            importance: Importance(rawValue: Int(coreDataObj.importance)) ?? .usual,
            isMake: coreDataObj.isMake,
            createdDate: coreDataObj.createdDate,
            deadline: coreDataObj.deadline,
            changedDate: coreDataObj.changedDate,
            id: coreDataObj.id
        )
    }
    
    func getCoreDataObj(context: NSManagedObjectContext) -> DCTodoItem {
        let result = DCTodoItem(context: context)
        result.id = id
        result.deadline = deadline
        result.importance = Int16(importance.rawValue)
        result.text = text
        result.isMake = isMake
        result.changedDate = changedDate
        result.createdDate = createdDate
        return result
    }
}
