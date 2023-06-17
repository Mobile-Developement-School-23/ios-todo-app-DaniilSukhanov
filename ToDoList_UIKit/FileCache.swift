//
//  FileCache.swift
//  ToDoList
//
//  Created by Даниил Суханов on 10.06.2023.
//

import Foundation

class FileCache {
    private(set) var items = Set<TodoItem>()
    private let fileManager = FileManager.default
    
    // Добавление TodoItem с перезаписью
    func append(_ item: TodoItem) {
        if items.contains(item) {
            items.remove(item)
        }
        items.insert(item)
        
    }
    
    // Удаление TodoItem по id
    func remove(id: String) {
        guard let item = items.first(where: { $0.id == id }) else {
            return
        }
        items.remove(item)
    }
    
    // MARK: -JSON
    
    // Сохранение всех TodoItems в json файл
    func saveJSON(url: URL) -> Bool {
        let data = items.map { item in
            item.json as! [String: Any]
        }
        guard let json = try? JSONSerialization.data(withJSONObject: data) else {
            return false
        }
        guard (try? json.write(to: url)) != nil else {
            return false
        }
        return true
    }
    
    // Загрузка всех TodoItems в json файл
    func loadJSON(url: URL) -> Bool {
        guard let data = try? Data(contentsOf: url) else {
            return false
        }
        guard let items = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            return false
        }
        for item in items {
            guard let todoItem = TodoItem.parse(json: item) else {
                continue
            }
            append(todoItem)
        }
        return true
    }
}

// MARK: -CSV

extension FileCache {
    // Сохранение всех TodoItems в csv файл
    func saveCSV(url: URL) -> Bool {
        let data = items.map { item in
            item.csv
        }
        let string = data.reduce(into: TodoItem.titles.joined(separator: ";")) {
            $0 += "\n" + $1
        }
        guard (try? string.write(to: url, atomically: false, encoding: .utf8)) != nil else {
            return false
        }
        return true
    }
    
    // Загрузка всех TodoItems в csv файл
    func loadCSV(url: URL) -> Bool {
        guard let string = try? String(contentsOf: url) else {
            return false
        }
        let titles = TodoItem.titles.joined(separator: ";")
        for row in string.components(separatedBy: ";") where row != titles {
            guard let item = TodoItem.parse(csv: row) else {
                continue
            }
            append(item)
        }
        return true
    }
}
