//
//  TodoItem.swift
//  ToDoList
//
//  Created by Даниил Суханов on 10.06.2023.
//

import Foundation

struct TodoItem: Hashable {
    enum Importance: Int {
        // unimportant - неважная, usual - обычная, important - важная
        case unimportant, usual, important
        
        static func getImportance(id: Int?) -> Importance? {
            switch id {
            case 0: return .unimportant
            case 1: return .usual
            case 2: return .important
            case .none: return .usual
            default: return nil
            }
        }
    }
    
    let id: String
    let text: String
    let importance: Importance
    let deadline: Date?
    let isMake: Bool
    let createdDate: Date
    let changedDate: Date?
    
    // в такой последовательности должны передавать данные для csv
    static let titles = ["id", "text", "importance", "deadline", "isMake", "createdData", "changedData"]
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
            return nil
        }
        guard let isMake = data["isMake"] as? Bool else {
            return nil
        }
        guard let createdDate = data["createdData"] as? Double else {
            return nil
        }
        var importance: Importance
        if data.keys.contains("importance") {
            guard let value = data["importance"] as? Int else {
                return nil
            }
            guard let value = Importance.getImportance(id: value) else {
                return nil
            }
            importance = value
        } else {
            importance = .usual
        }
        if !data.keys.contains("id") {
            return nil
        }
        guard let id = data["id"] as? String else {
            return nil
        }
        return TodoItem(
            text: text,
            importance: importance,
            isMake: isMake,
            createdDate: createdDate.toDate(),
            deadline: (data["deadline"] as? Double)?.toDate(),
            changedDate: (data["changedData"] as? Double)?.toDate(),
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
        result["createdData"] = createdDate.timeIntervalSinceReferenceDate
        if let changedDate {
            result["changedData"] = changedDate.timeIntervalSinceReferenceDate
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
        let importance = Importance.getImportance(id: idImportance)
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



